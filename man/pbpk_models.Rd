\name{pbpk_models}
\alias{pbpk_models}
\alias{pbpk_physiology}
\alias{pbpk_chemical_parameters}
\title{Inspect available models and their parameterization}
\description{Retrieve available chemicals, individual physiological parameters and chemical parameters from the selected service.}
\usage{
pbpk_models(chemical = NULL)

pbpk_physiology(chemical, age = NULL, bw = NULL, sex = NULL, parameters = NULL,
                            effective_parameters = NULL)

pbpk_chemical_parameters(chemical, age = NULL, bw = NULL, sex = NULL,
                                     parameters = NULL, effective_parameters = NULL)
}
\arguments{
\item{chemical}{Registered chemical identifier. The initial service supports PFBS. See \code{pbpk_models()}.}
\item{age}{Age in years. The individual PFBS dosimetry default is 30 years.}
\item{bw}{Body weight in kg. The default is 70 kg and remains fixed across a person's draws.}
\item{sex}{Physiological sex, for example \code{"female"} or \code{"male"}. The default physiological reference is male.}
\item{parameters}{Named numeric vector of edits. For a model input supply the original input units. Derived-only entries use their effective units.}
\item{effective_parameters}{Named numeric vector of edits in solver units. See the parameter tables for names and units. Each selected parameter is supplied once.}
}
\value{A tibble. Parameter tables include units, raw inputs, effective values and the assumed individual profile.}
\seealso{\code{\link{IntegraPBPKengine-package}}}
