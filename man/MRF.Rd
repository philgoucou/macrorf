\name{MRF}
\alias{MRF}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Macroeconomic Random Forest
%%  ~~function to do ... ~~
}
\description{This prototype function runs MRF, where RF is employed to model time variation in a linear (macroeconomic) equation. The function contains utilities to conduct (i) plain forecasting, (ii) look at Generalized Time-Varying Parameters (in-sample or out-of-sample), (iii) calculate their credible regions, and (iv) computing various variable importance measures. It is still in development, please report any bugs or function features that could benefit from clearer explanations.
}
\usage{MRF(data,y.pos=1, S.pos=2:ncol(data),x.pos,oos.pos,
                minsize=10,mtry.frac=1/3,min.leaf.frac.of.x=1,VI=FALSE,
                ERT=FALSE,quantile.rate=NULL,S.priority.vec=NULL,
                random.x = FALSE,howmany.random.x=1,
                howmany.keep.best.VI=20,cheap.look.at.GTVPs=TRUE,
                prior.var=c(),prior.mean=c(),
                subsampling.rate=0.75,rw.regul=0.75,keep.forest=FALSE,
                block.size=12, trend.pos=max(x.pos),trend.push=1,fast.rw=TRUE,
                ridge.lambda=0.01,HRW=0,B=50,resampling.opt=2,printb=TRUE)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{data}{The data matrix, including all potential columns (y, X, S) and rows (both training and testing data)}
  \item{y.pos}{Column position of the prediction target}
  \item{x.pos}{Column positions of the linear part}
  \item{S.pos}{Column positions of variables entering the forest part (S_t in the paper)}
  \item{oos.pos}{Row positions of test set/out-of-sample observations}
  \item{minsize}{Minimal node size to attempt a split}
  \item{mtry.frac}{Fraction of all features S_t to consider at each split. A lower value (like 0.15) helps speeding things up and can be reasonable when S_t contains many correlated features.}
  \item{min.leaf.frac.of.x}{Minimal ratio of observations to regressors in a node. Given the ridge penalty and random-walk shrinkage, there is no problem in letting this be one. Suggested values are (1,1.5,2) but those usually have very little influence.}
  \item{VI}{Set to TRUE if you want variable importance measures to be computed. That inevitably slow things down, so activate this option only if you need them.}
 \item{howmany.keep.best.VI}{For convenience, the function outputs "impS" data matrices which are the important S according to some VI criterion or another (there are 3 of them, see paper)."howmany.keep.best.VI" is how many variables should we keep by VI criteria.}
\item{cheap.look.at.GTVPs}{Plots GTVPs (if applicable) at the end of estimation.}
  \item{ERT}{ERT stands for "Extremely Randomized Tree". Activating this means splitting points (but not splitting variables) are chosen randomly. This brings extra regularization, and most importantly, speed. Option quantile rate determines how many random splits are considered. 1 means all of them, like usual RF. 0 is like pure ERT. All values in between are possible. This option is not used in the paper but can help exploratory work by speeding things up. Also, it could potentially help in forecasting via extra regularization -- as reported in the second paper referenced below.}
  \item{quantile.rate}{This option has a different meaning if ERT is activated. See above. Otherwise, this feature, for early splits, reduce the number of splitting point being considered for each S. 1 means all splitting points are considered. A value between 0 and 1 means we are considering a subset of quantiles of the splitting variable. For instance, quantile.rate=0.3 means one out of every tree (ordered) values is considered for splitting. The aim of this option is to speed things up without sacrificing much predictive ability.}
    \item{S.priority.vec}{RF randomly selects potential splitting variables at each step. However, in a large macro data sets, some types of variables could be over-represented, and some, underrepresented. The user can specify weights for all members of S using this option. Thus, one can down weight overrepresented group of regressors, if that makes sense to do so.}
\item{prior.mean}{MRF implements a ridge prior. The user can specify a prior.mean vector of length "x.pos"+1 which differs from c(0,0,0,0). For instance, this may help when a close-to unit root is suspected. An easy (and good) data-driven prior mean vector consists of OLS estimates of regressing X's on Y.}
\item{prior.var}{When using prior.mean, a prior variance vector must also be specified. Remember this alters the implicit value of "ridge.lambda". Also, the intercept should always have a larger variance.}
\item{subsampling.rate}{Subsampling rate for the ensemble}
\item{rw.regul}{Egalitarian Olympic podium random-walk shrinkage parameter (see paper). Should be between 0 (nothing) and 1.}
\item{printb}{If TRUE, print at which tree we are at in terms of computations.}
\item{ridge.lambda}{Ridge shrinkage parameter for the linear part.}
\item{HRW}{Seldomly use. See paper's appendix. Can be useful for very large "x.pos".}
\item{B}{How many trees in the ensemble?}
\item{resampling.opt}{0 is no resampling. 1 is plain subsampling. 2 is block subsampling (recommended when looking at GTVPs). 3 is Bayesian Bootstrap. 4 is Block Bayesian Bootstrap (may do better for forecasting).}
  \item{block.size}{Size of blocks for block sub-sampling (resampling.opt=2) and block bayesian bootstrap (resampling.opt=4)}
  \item{trend.pos}{Including a trend in S_t allows from exogenous structural change and breaks. However, it may be one out of 600+ candidates in S_t. To boost the probability of it being included, use this option to first indicated where the trend is in the data matrix.}
  \item{trend.push}{See above. Must be >=1. This option multiplies by "trend.push" the probability of the trend being included in the potential splitters set. 4 is a reasonable value with macro data. Note this can be used for anything (not necessarily a trend) that we may want to boost (in position trend.pos).}
\item{fast.rw}{When TRUE, "rw.regul"" is only considered in the prediction step (and not in the search for splits). This speeds things up dramatically with often little influence on results.}
\item{random.x}{Activating this lets the algorithm randomly select "howmany.random.x" regressor out of all those in "x.pos" for each tree. This is merely a predictive device, so GTVPs are not outputted in that case, and neither are VI measures.}
\item{howmany.random.x}{See above. Must be between 1 and the length of "x.pos".}
\item{keep.forest}{Saves all the tree structures. Switch to TRUE if you plan to forecast using the external function "pred.given.mrf".}


%%     ~~Describe \code{x} here~~
}
\details{
%%  ~~ If necessary, more details than the description above ~~
}
\value{
\item{betas}{GTVPs (posterior mean)}
\item{betas.draws}{Draws to construct credible regions from. Will have missing values by construction if subsampling is used (because of no-trespassing). Just use na.rm=TRUE in subsequent calculations.}
\item{pred}{Out-of-sample prediction for observations "oos.pos".}
\item{pred.ensemble}{All out-of-sample predictions (all trees separately).}
\item{VI_betas}{Variable importance for time variation in each coefficient.}
\item{VI_oob}{Out-of-bag variable importance}
\item{VI_oos}{Out-of-sample variable importance}
\item{YandX}{Data of the linear part, including Y first}
\item{important.S}{Matrix of important members of S according to VI measures}
\item{S.names}{All the S.names}
\item{betas.draws.raw}{These draws include betas_t even if t was used to build the tree.}
\item{betas.raw}{This is the mean of the above.}
\item{VI_betas.raw}{Variable importance, performed on the raw betas rather the non-trespassing ones.}
}

\references{
Original paper is https://arxiv.org/abs/2006.12724.
A policy document applying it is http://cirano.qc.ca/fr/sommaires/2020RP-18.}
\author{
Philippe Goulet Coulombe
}
\note{
This is merely a prototype. Please report any bug. A long time ago, the starting point for that code was https://github.com/andrebleier/cheapml.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
data=matrix(rnorm(15*200),200,15)

#DGP
library(pracma)
X=data[,1:3]
y=crossprod(t(X),rep(1,3))*(1-0.5*I(c(1:200)>75))+rnorm(200)/2
trend=1:200
data.in=cbind(y,data,trend)
mrf.output=MRF(data=data.in,y.pos=1,x.pos=2:4,S.pos=2:ncol(data.in),oos.pos=151:200,trend.push=4,quantile.rate=0.3)
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory (show via RShowDoc("KEYWORDS")):
% \keyword{ ~kwd1 }
% \keyword{ ~kwd2 }
% Use only one keyword per line.
% For non-standard keywords, use \concept instead of \keyword:
% \concept{ ~cpt1 }
% \concept{ ~cpt2 }
% Use only one concept per line.
