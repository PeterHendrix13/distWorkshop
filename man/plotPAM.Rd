% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotPAMs.R
\name{plotPAM}
\alias{plotPAM}
\title{Plot PAM}
\usage{
plotPAM(model, predictor, data, response = "RT", se = 2,
  area = FALSE, num_grid = 100,
  pallet = colorRampPalette(rev(brewer.pal(n = 7, name =
  "RdYlBu")))(500), levs = NA, rugx = TRUE, rugy = TRUE, main = NA,
  xlab = NA, ylab = NA, ...)
}
\arguments{
\item{model}{A PAM model.}

\item{predictor}{The predictor to be plotted. This predictor needs to be present in the fitted 
model, as well as in data.}

\item{data}{The data the PAM model was fit to. Needs to include the response variable in the task, 
as well as all predictors in these models. Note: this is the data frame in its raw format, 
not the data frame converted to the piece-wise exponential data format.}

\item{response}{The name of the response variable in data.}

\item{se}{The number of standard errors that is used for the significance test. Default: 2 (i.e., 95\% confidence intervals)}

\item{area}{Should the significance of the effect at different predictor values be plotted. Default: FALSE.}

\item{pallet}{A vector of color names that will be used for the contour plot.}

\item{levs}{A vector of values at which the contour lines will be plotted. By default, these 
values are selected automatically}

\item{rugx}{Should a rug be plotted for the x-axis? Default: TRUE}

\item{rugy}{Should a rug be plotted for the y-axis? Default: TRUE}
}
\description{
Plot the results of a PAM model (Bender & Scheipl, 2018)
}
\examples{
# Remove outliers
predictors = c("logFrequency", "Length", "logOLD20", "SND20") 
ld = removeOutliers(ld, predictors)
ld = na.omit(ld)

# Prepare data in exponential data format
ld$status = 1
cut_points = as.numeric(quantile(ld$RT[which(ld$RT <= 1085 & 
               ld$RT >= 500)],seq(0, 1, by = 0.02)))
ped = split_data(Surv(RT, status)~., data = ld, id = "id",
                   cut = cut_points)

# Run PAM (warning: computationally heavy)
pam_ld = gam(ped_status ~ s(tend) + 
             s(logFrequency) + ti(tend, logFrequency) + 
             s(Length) + ti(tend, Length) + 
             s(logOLD20) + ti(tend, logOLD20) + 
             s(SND20) + ti(tend, SND20),
             data = ped, offset = offset, family = poisson())

# Plot frequency effect
plotPAM(model = pam_ld, data = ld, predictor = "logFrequency")

}
\references{
Bender, A. & Scheipl, F. (2018). pammtools: Piece-wise 
exponential additive mixed modeling tools. arXiv:1806.01042
}
