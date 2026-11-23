\name{IntegraPBPKengine-package}
\alias{IntegraPBPKengine-package}
\alias{IntegraPBPKengine}
\docType{package}
\title{INTEGRA PBPK modeling interface}
\description{
INTEGRA-PBPK-Engine provides a unified R interface for physiologically
based pharmacokinetic modeling, simulation, sensitivity analysis,
uncertainty analysis, and exposure reconstruction.
}
\details{
Version 0.6.0 supports PFBS, with additional chemicals planned for
future releases.

Set \code{options(IntegraPBPKengine.url = ...)} or the environment
variable \env{INTEGRA_PBPK_URL} to the configured service URL.

Set \env{INTEGRA_PBPK_TOKEN} or
\code{options(IntegraPBPKengine.token = ...)} to the service access token.

Remote connections require HTTPS.

Submitted model inputs, including HBM data fields, are transferred
to the configured service.

An optional request timeout can be set using
\code{options(IntegraPBPKengine.timeout = 600L)}.
}
\examples{
\dontrun{
library(IntegraPBPKengine)

pbpk_models()

phys <- pbpk_physiology(
  chemical = "PFBS",
  age = 30,
  bw = 70
)
}
}
