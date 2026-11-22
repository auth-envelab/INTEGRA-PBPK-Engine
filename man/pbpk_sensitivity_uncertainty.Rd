\name{pbpk_sensitivity}
\alias{pbpk_sensitivity}
\alias{pbpk_uncertainty}
\alias{print.pbpk_sensitivity_results}
\alias{print.pbpk_uncertainty_results}
\alias{plot.pbpk_sensitivity_results}
\alias{plot.pbpk_uncertainty_results}
\alias{print.pbpk_analysis_results}
\alias{plot.pbpk_analysis_results}
\alias{print.pbpk_result_tables}
\alias{$.pbpk_result_tables}
\alias{[[.pbpk_result_tables}
\title{Retrieve or recompute sensitivity and uncertainty analyses}
\description{
Each function retrieves the corresponding chemical-specific archive by default.
Request a preview or full rerun of that analysis, or select one method and scenario.
}
\usage{
pbpk_sensitivity(chemical = NULL, method = NULL, scenario = "chronic_bw",
  profile = "standard", n = NULL, workers = 1L, rerun = FALSE,
  design = "full", model = NULL)
pbpk_uncertainty(chemical = NULL, method = NULL, scenario = "chronic_bw",
  profile = "standard", n = NULL, n_phys = NULL, workers = 1L,
  rerun = FALSE, design = "full", model = NULL)
\method{print}{pbpk_sensitivity_results}(x, ...)
\method{print}{pbpk_uncertainty_results}(x, ...)
\method{plot}{pbpk_sensitivity_results}(x, scenario = "chronic_bw",
  endpoint = "serum_ng_ml", profile = NULL, ...,
  source = c("auto", "archive", "recomputed"), method = NULL)
\method{plot}{pbpk_uncertainty_results}(x, scenario = "chronic_bw",
  endpoint = "serum_ng_ml", profile = NULL, ...,
  source = c("auto", "archive", "recomputed"), method = NULL)
}
\arguments{
\item{chemical}{Chemical identifier from \code{pbpk_models()}.}
\item{method}{Targeted numerical method. PFBS sensitivity supports \code{"local"}, \code{"morris"} and \code{"sobol"}. PFBS uncertainty supports \code{"posterior"} and \code{"crossed"}.}
\item{scenario}{Model exposure scenario. Supplying a scenario to an analysis function requests a targeted calculation.}
\item{profile}{Analysis profile. PFBS has \code{"standard"} and \code{"closure"} designs. A plot can select from available profiles when this is \code{NULL}.}
\item{n}{Method-specific trajectory, design or draw count for a targeted calculation.}
\item{n_phys}{Physiological draw count for a targeted crossed uncertainty calculation.}
\item{workers}{Requested number of numerical workers, subject to the configured service limit.}
\item{rerun}{Set to \code{TRUE} for a suite rerun of the selected analysis. A targeted calculation is requested through its method or scenario.}
\item{design}{Suite size for a rerun, either \code{"preview"} or \code{"full"}.}
\item{model}{Legacy alias for the chemical.}
\item{x}{A retrieved or recomputed sensitivity or uncertainty result.}
\item{source}{The default, \code{"auto"}, plots recomputed values when the result contains a rerun and archived values otherwise. Set this explicitly to compare the two sources. An unavailable selection raises an error.}
\item{endpoint}{Output identifier for plotting.}
\item{...}{Additional arguments passed to the print or plotting method.}
}
\value{
Archive and suite calls return a nested list of the corresponding results,
a table manifest, supporting material and draw tables retrieved on demand.
A suite rerun also returns its design, plan and recalculated results in
\code{recomputed}. Targeted sensitivity returns a table of parameter effects
or indices. Targeted uncertainty returns scientific outputs for the selected
ensemble, including draw-level results and summaries. List results store their run record
in \code{run_record}. For table results use \code{attr(result, "run_record")}.
}
\examples{
\dontrun{
sensitivity <- pbpk_sensitivity(chemical = "PFBS")
uncertainty <- pbpk_uncertainty(chemical = "PFBS")
preview <- pbpk_sensitivity(chemical = "PFBS", rerun = TRUE, design = "preview")
plot(preview)
plot(preview, source = "archive")
draws <- pbpk_uncertainty(chemical = "PFBS", method = "posterior", n = 3L)
}
}
