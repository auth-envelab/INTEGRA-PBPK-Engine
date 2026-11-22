\name{pbpk_study_results}
\alias{pbpk_study_results}
\alias{pbpk_studies}
\alias{pbpk_pfbs_posterior}
\alias{print.pbpk_study_results}
\alias{plot.pbpk_study_results}
\alias{plot.pbpk_study_fit}
\alias{plot.pbpk_xu_posterior}
\title{Inspect and replay calibration and evaluation studies}
\description{
List the studies for a chemical, retrieve its archived results, or replay its
fitted study protocols. The PFBS posterior function replays draws from the Xu calibration.
}
\usage{
pbpk_studies(chemical = NULL, model = NULL)
pbpk_study_results(chemical, rerun = FALSE, n_posterior = 500L,
  study_dir = NULL, study = NULL, cohorts = 1L, seed = NULL)
pbpk_pfbs_posterior(chemical = "PFBS", n = 500L, seed = 20260928L)
}
\arguments{
\item{chemical}{Chemical identifier from \code{pbpk_models()}.}
\item{model}{Legacy alias for the chemical in \code{pbpk_studies()}.}
\item{rerun}{Set to \code{TRUE} to recompute study predictions from the fitted parameters.}
\item{n_posterior}{Number of joint draws for a supported study posterior replay. Zero requests deterministic fits only. The Xu posterior replay requires at least two draws when enabled.}
\item{study_dir}{Omit to use the operator's configured study observations. Explicit \code{NULL} requests the published summary comparison where supported.}
\item{study}{Optional study identifier from \code{pbpk_studies()}. Omit for all studies.}
\item{cohorts}{Number of cohorts for a study replay. The PFBS deterministic study protocols use one cohort.}
\item{seed}{Seed for supported stochastic replays. The deterministic PFBS fit on its own accepts \code{NULL}.}
\item{n}{Number of joint PFBS calibration draws to replay.}
}
\value{
\code{pbpk_studies()} returns a study register. \code{pbpk_study_results()}
returns a nested list with calibration and evaluation branches. Each selected
study's deterministic fit contains its matched observations, predictions and
metrics. Its Bayesian component is present when available. The PFBS posterior
function returns the Xu calibration replay summary, draw identifiers and seed.
}
\examples{
\dontrun{
studies <- pbpk_study_results(chemical = "PFBS")
olsen <- pbpk_study_results(chemical = "PFBS", study = "Olsen", rerun = TRUE, n_posterior = 0L)
olsen$evaluation$Olsen$deterministic$metrics
}
}
