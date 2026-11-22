\name{IntegraPBPKengine-package}
\alias{IntegraPBPKengine-package}
\alias{IntegraPBPKengine}
\docType{package}
\title{R client for the INTEGRA PBPK service}
\description{
This package transmits model requests to an operator-configured service and
returns the resulting R data structures. The public package contains the
client interface, data transport and display functions. The operator holds
the model solver and analysis programs on the service computer.
}
\details{
Set \code{options(IntegraPBPKengine.url = ...)} or the environment variable
\env{INTEGRA_PBPK_URL} to a service base URL supplied by the operator. Set
\env{INTEGRA_PBPK_TOKEN} to your access token; the alternative R option is
\code{IntegraPBPKengine.token}. The client creates a fresh request for the
configured service and requires HTTPS for hosts other than loopback.
For a local owner test use the URL and token from the owner test script.
\code{options(IntegraPBPKengine.timeout = 600L)} sets an optional request
timeout in seconds; zero permits long numerical runs.

Inputs, including submitted HBM columns, are sent to the service operator.
Supply only fields intended for that operator. End users can inspect the
published workflows, returned data, tables, equations and diagram.
The service must be reachable for model calls and lazy draw-table retrieval.
Downloaded PDFs, text and already returned tables remain available locally.
}
\examples{
\dontrun{
library(IntegraPBPKengine)
options(IntegraPBPKengine.url = Sys.getenv("INTEGRA_PBPK_URL"))
pbpk_models()
phys <- pbpk_physiology("PFBS", age = 30, bw = 70)
events <- data.frame(time = 0, var = "m_stomach", value = 1, method = "add")
forward <- pbpk_forward("PFBS", events, 0:24, effective_parameters = c(V_liv = 2.1))
}
}
