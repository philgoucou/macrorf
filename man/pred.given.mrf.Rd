\name{pred.given.mrf}
\alias{pred.given.mrf}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Macroeconomic Random Forest Prediction Function
%%  ~~function to do ... ~~
}
\description{This function predicts y for new data  using a previously estimated MRF object. This allows for prediction without re-estimating the model, and doing so in separate functions (which is customary for ML packages). While this addition is redundant for direct forecasting (which should all be done within MRF function for more efficient memory management), it allows for iterative (potentially multivariate) forecasting. However, in that scenario, straightforward residuals-based simulation methods (like in Milunovich (2019)) need to be used since the forecasting function is nonlinear. I recommend using out-of-bag residuals for that sake, which can be easily obtained from MRF's output (y[t]-X[t]beta[t]).
}
\usage{pred.given.mrf(mrf.output,newdata)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{mrf.output}{Some output from running MRF function (and setting oos.pos = c() and keep.forest=TRUE).}
  \item{y.pos}{A new vector/matrix of data excluding y, which is assumed to the first row of the matrix when you previously ran MRF function. Predictors matrix must have column names, both when you run this and the MRF function.}

%%     ~~Describe \code{x} here~~
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
\item{output}{Returns predictions.}
}


%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
data=matrix(rnorm(15*200),200,15)
colnames(data)=paste('X_',1:ncol(data),sep='')

#DGP
library(pracma)
X=data[,1:3]
y=crossprod(t(X),rep(1,3))*(1-0.5*I(c(1:200)>75))+rnorm(200)/2
trend=1:200
data.in=cbind(y,data,trend)
colnames(data.in)[1]='y'
mrf.output=MRF(data=data.in[-c(151:200),],y.pos=1,x.pos=2:4,S.pos=2:ncol(data.in),oos.pos=c(),trend.push=4,quantile.rate=0.3,keep.forest=TRUE)

pred.given.mrf(mrf.output,as.data.frame(data.in[151:200,-1]))

}
