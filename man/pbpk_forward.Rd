\name{pbpk_forward}
\alias{pbpk_forward}
\alias{pbpk_simulate}
\title{Run a forward exposure simulation}
\description{Send timed exposure events and individual parameters to the configured service. Bayesian simulations accept joint sampling controls.}
\usage{
pbpk_forward(chemical, events, times, method = c("deterministic", "bayesian"),
                         n = NULL, seed = 1L, age = NULL, bw = NULL, sex = NULL,
                         parameters = NULL, initial = NULL, rtol = 1e-8, atol = 1e-10,
                         maxsteps = 50000L, solver = "lsoda",
    effective_parameters = NULL)

pbpk_simulate(events, times, parameters = NULL, initial = NULL,
    outputs = c("C_pls_ven", "m_URN", "m_Feces"), chemical = NULL, rtol = 1e-8,
    atol = 1e-10, maxsteps = 50000L, solver = c("lsoda", "radau"), age = NULL,
    bw = NULL, sex = NULL, effective_parameters = NULL, model = NULL)
}
\arguments{
\item{chemical}{Registered chemical identifier. The initial service supports PFBS. See \code{pbpk_models()}.}
\item{events}{Data frame with columns \code{time}, \code{var}, \code{value} and \code{method}; times are in hours. An oral bolus adds micrograms to \code{m_stomach}. A continuous oral intake replaces \code{m_oral} in micrograms/hour.}
\item{times}{Strictly increasing nonnegative observation times in hours.}
\item{method}{Forward mode: \code{"deterministic"} or \code{"bayesian"}.}
\item{n}{Sample count for a replay, sensitivity design or Bayesian method.}
\item{seed}{Random seed where the selected method supports sampling.}
\item{age}{Age in years. The individual PFBS dosimetry default is 30 years.}
\item{bw}{Body weight in kg. The default is 70 kg and remains fixed across a person's draws.}
\item{sex}{Physiological sex, for example \code{"female"} or \code{"male"}. The default physiological reference is male.}
\item{parameters}{Named numeric vector of edits. For a model input supply the original input units. Derived-only entries use their effective units.}
\item{initial}{Optional named initial states in model units.}
\item{rtol}{Relative solver tolerance.}
\item{atol}{Absolute solver tolerance.}
\item{maxsteps}{Maximum integrator steps per interval.}
\item{solver}{ODE solver supported by the private engine.}
\item{effective_parameters}{Named numeric vector of edits in solver units. See the parameter tables for names and units. Each selected parameter is supplied once.}
\item{outputs}{Requested state/auxiliary names or \code{"all"}.}
\item{model}{Chemical selector supported by the corresponding operation.}
}
\value{Forward results contain all state and auxiliary trajectories, the effective parameters, the assumed inputs and Bayesian draws or summaries as applicable. The low-level simulator returns the selected trajectories in a tibble.}
\seealso{\code{\link{IntegraPBPKengine-package}}}

\section{Exposure units and the applied schedule}{
The native event columns are \code{time}, \code{var}, \code{value} and \code{method}.
The low-level \code{pbpk_simulate()} entry point accepts native solver units only.
To enter a dose in other units with \code{pbpk_forward()}, add a \code{unit} column. Time is in hours.
PFBS accepts ng, ug (micrograms) and mg, including amounts per kg and rates per hour or day.
For example, set \code{var = "m_oral"}, \code{method = "replace"}, \code{value = 1} and
\code{unit = "ng/kg/day"} for continuous oral intake. Add a zero-rate replacement to stop intake.
For an oral bolus use \code{var = "m_stomach"}, \code{method = "add"} and a mass unit
such as \code{"ng/kg"}. For a bolus expressed as an average daily rate, provide its
\code{dose_interval_h} and a separate event row for each administration. At 70 kg, one
24-hour interval at 1 ng/kg/day corresponds to a 0.070 ug oral bolus. For PFBS the
other exposure targets are \code{m_inhalation} (rate) and \code{m_dermal} (depot mass).
A multiplicative event uses \code{unit = "1"}. Normalized events use the effective
body weight that the model uses for the simulation. Inspect \code{exposure_events$submitted},
\code{exposure_events$applied} and \code{exposure_events$normalization_bw_kg} in the result.
The list component \code{run_record} holds the model and parameter revisions, applied
overrides, demographic inputs and sampling details.
}
