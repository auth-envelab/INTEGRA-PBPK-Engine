\name{pbpk_equations}
\alias{pbpk_equations}
\alias{pbpk_mermaid}
\title{Obtain annotated equations and compartment diagrams}
\description{Request the owner-published annotated equations or editable Mermaid text. File paths and overwrite choices are local to the client and are not transmitted.}
\usage{
pbpk_equations(chemical = NULL, file = NULL, overwrite = FALSE, model = NULL)

pbpk_mermaid(chemical, file = NULL, plot = FALSE, overwrite = FALSE,
                         detail = c("full", "organs", "states"))
}
\arguments{
\item{chemical}{Registered chemical identifier. The initial service supports PFBS. See \code{pbpk_models()}.}
\item{file}{Destination on the client computer. For equations the default is a PDF in the working directory. Mermaid returns its text when no file is supplied.}
\item{overwrite}{Allow replacement of an existing local file.}
\item{model}{Chemical selector supported by the corresponding operation.}
\item{plot}{Draw the diagram supplied by the service on the current R graphics device.}
\item{detail}{The default \code{"full"} shows all model states. \code{"states"} is a synonym; \code{"organs"} selects the simplified overview.}
}
\value{The equations function invisibly returns the local PDF path. The Mermaid function returns a character string containing the complete diagram source.}
\seealso{\code{\link{IntegraPBPKengine-package}}}
