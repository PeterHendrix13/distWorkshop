#' Plot PAM
#'
#' Plot the results of a PAM model (Bender & Scheipl, 2018)
#' @param
#' model A PAM model.
#' @param
#' predictor The predictor to be plotted. This predictor needs to be present in the fitted 
#' model, as well as in data.
#' @param
#' data The data the PAM model was fit to. Needs to include the response variable in the task, 
#' as well as all predictors in these models. Note: this is the data frame in its raw format, 
#' not the data frame converted to the piece-wise exponential data format.
#' @param
#' response The name of the response variable in data.
#' @param
#' se The number of standard errors that is used for the significance test. Default: 2 (i.e., 95\% confidence intervals)
#' @param
#' area Should the significance of the effect at different predictor values be plotted. Default: FALSE.
#' @param
#' pallet A vector of color names that will be used for the contour plot.
#' @param
#' rugx Should a rug be plotted for the x-axis? Default: TRUE
#' @param
#' rugy Should a rug be plotted for the y-axis? Default: TRUE
#' @param
#' levs A vector of values at which the contour lines will be plotted. By default, these 
#' values are selected automatically
#' 
#' @examples 
#' # Remove outliers
#' predictors = c("logFrequency", "Length", "logOLD20", "SND20") 
#' ld = removeOutliers(ld, predictors)
#' ld = na.omit(ld)
#' 
#' # Prepare data in exponential data format
#' ld$status = 1
#' cut_points = as.numeric(quantile(ld$RT[which(ld$RT <= 1085 & 
#'                ld$RT >= 500)],seq(0, 1, by = 0.02)))
#' ped = split_data(Surv(RT, status)~., data = ld, id = "id",
#'                    cut = cut_points)
#' 
#' # Run PAM (warning: computationally heavy)
#' pam_ld = gam(ped_status ~ s(tend) + 
#'              s(logFrequency) + ti(tend, logFrequency) + 
#'              s(Length) + ti(tend, Length) + 
#'              s(logOLD20) + ti(tend, logOLD20) + 
#'              s(SND20) + ti(tend, SND20),
#'              data = ped, offset = offset, family = poisson())
#' 
#' # Plot frequency effect
#' plotPAM(model = pam_ld, data = ld, predictor = "logFrequency")
#' 
#' @references 
#' Bender, A. & Scheipl, F. (2018). pammtools: Piece-wise 
#' exponential additive mixed modeling tools. arXiv:1806.01042
#' 
#' @export

# Plot PAM results        
plotPAM = function(model, predictor, data, response = "RT", 
                   se = 2, area = FALSE, num_grid = 100,
                   pallet = colorRampPalette(rev(brewer.pal(n = 7, name = "RdYlBu")))(500),
                   levs = NA, rugx = TRUE, rugy = TRUE, main = NA, xlab = NA, ylab = NA, 
                   ...) {
  
  # Get plot data
  tmp = tempfile()
  png(filename = tmp)
  po = plot(model,n = num_grid, n2 = num_grid)
  dev.off()
  unlink(tmp)
  
  selectmain = which(unlist(lapply(po,FUN = function(x){x$xlab==predictor})))
  selectint = which(unlist(lapply(po,FUN = function(x){x$ylab==predictor})))
  
  pomain = po[[selectmain]]$fit
  predname = po[[selectmain]]$xlab
  point =po[[selectint]]
  z = matrix(point$fit, length(point$x), length(point$y))
  for(i in 1:ncol(z)){
    z[,i] = z[,i] + pomain[i]
  }
  po = point

  # Define plot labels
  mainlab = ifelse(is.na(main), predictor, main)
  ylabel = ifelse(is.na(ylab), predictor, ylab)
  xlabel = ifelse(is.na(xlab), "time", xlab)


  # Semi-transparant plot for background
  zlimit = c(-max(abs(z), na.rm = T), max(abs(z), na.rm = T))
  image(po$x, po$y, z, zlim = zlimit, col = paste(pallet, "66", sep = ""), xlab = xlabel,
        ylab = ylabel, cex.lab = 1.1, main = mainlab, ...)
  
  # Non-transparant overlay for significant part of plot
  png(filename=tmp)
  a = vis.gam.return(model, view=c("tend", predname), n.grid = num_grid)
  dev.off()
  unlink(tmp)
  
  mat =  matrix(a$fit, num_grid, num_grid)
  matmin =  matrix(a$fit - se*a$se.fit, num_grid, num_grid)
  matmax =  matrix(a$fit + se*a$se.fit, num_grid, num_grid)
  for(i in 1:nrow(mat)) {
    matmin[i,] = matmin[i,] - mean(mat[i,], na.rm=T)
    matmax[i,] = matmax[i,] - mean(mat[i,], na.rm=T)
    mat[i,] = mat[i,] - mean(mat[i,], na.rm=T)
  }
  mat[which(is.na(z))] = NA
  
  z2 = z
  z3 = z2
  z3[which(matmin < 0 & matmax > 0)] = NA
  z2[which(apply(z3, 1, FUN = function(x){sum(x, na.rm = T)==0})),] = NA
  if(area) {
    z2 = z3
  }

  image(po$x, po$y, z2, col=pallet, add=TRUE, zlim = zlimit, ...)


  # Contour lines
  if(is.na(levs[1])) {
    contour(po$x, po$y, z, add=TRUE, col = "black", labcex = 0.8)
  } else {
    contour(po$x, po$y, z, add=TRUE, col = "black", labcex=0.8, levels = levs)  
  }
  
  # Add rug
  if(rugx) {
    suppressWarnings(rug(quantile(data[,response], seq(0, 1, by = 0.005), na.rm = TRUE),
      side = 1))
  }
  if(rugy) {
    suppressWarnings(rug(quantile(data[,predictor], seq(0, 1, by = 0.005), na.rm = TRUE),
      side = 2))
  }

}
