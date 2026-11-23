\name{pbpk_reconstruct}
\alias{pbpk_reconstruct}
\title{Reconstruct individual intake from measured serum}
\description{Estimate individual constant oral intake from quantified serum for the selected duration. Age defaults to 30 years and body weight defaults to 70 kg if absent.}
\usage{
pbpk_reconstruct(chemical = NULL, hbm, method = NULL, n = NULL, seed = 1L,
                             exposure_days = 3652.5, parameters = NULL,
    coefficient_dose = NULL,
                             n_posterior = 0L, model = NULL,
    effective_parameters = NULL)
}
\arguments{
\item{chemical}{Registered chemical identifier. The initial service supports PFBS. See \code{pbpk_models()}.}
\item{hbm}{One individual serum measurement per row, in \code{serum_ng_mL}, or a numeric serum vector in ng/mL. Optional columns include \code{age_years}, \code{body_weight_kg}, \code{sex}, \code{hematocrit}, \code{gfr_mL_min} and other record metadata. The complete supplied table is transmitted to the chosen service.}
\item{method}{Reconstruction mode: \code{"deterministic"}, \code{"bayesian_tk"} or \code{"bayesian_tk_physiology"}.}
\item{n}{Sample count for a replay, sensitivity design or Bayesian method.}
\item{seed}{Random seed where the selected method supports sampling.}
\item{exposure_days}{Duration of the assumed constant oral intake, in days.}
\item{parameters}{Named numeric vector of edits. For a model input supply the original input units. Derived-only entries use their effective units.}
\item{coefficient_dose}{Optional separate coefficient calculation, in ng/kg/day.}
\item{n_posterior}{Posterior replay size. In reconstruction this is the backward-compatible draw argument.}
\item{model}{Chemical selector supported by the corresponding operation.}
\item{effective_parameters}{Named numeric vector of edits in solver units. See the parameter tables for names and units. Each selected parameter is supplied once.}
}
\value{A tibble containing the original HBM fields, assumed physiology, status, replayed serum in ng/mL and reconstructed intake in \code{intake_ug_kg_day} (micrograms/kg/day). Bayesian results contain a row for each record and draw.}
\seealso{\code{\link{IntegraPBPKengine-package}}}

\section{Reproducing a run}{
Use \code{attr(result, "run_record")} on returned scientific tables and
\code{result$run_record} on scientific list results. The record carries the chemical,
the model revision, engine version, parameter set and parameter-data revision.
It identifies parameter overrides, demographic inputs and their sources, exposure assumptions,
and available sampling identifiers. For PFBS reconstruction the serum concentration is
in ng/mL and the body-weight-normalized intake is in ug/kg/day. A default of 30 years
or 70 kg can be distinguished from the same value explicitly supplied for an individual.
Save the original R result with \code{saveRDS()} to retain its record alongside the data.
}
