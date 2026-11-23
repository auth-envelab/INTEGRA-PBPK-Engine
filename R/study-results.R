pbpk_study_results <- function(chemical, rerun = FALSE, n_posterior = 500L, study_dir = NULL,
                               study = NULL, cohorts = 1L, seed = NULL) {
  # Omitting study_dir uses the operator's configured observations. An explicit
  # NULL selects the published summary comparison. Study data locations are managed by the service.
  if (!missing(study_dir) && !is.null(study_dir)) {
    stop("Omit study_dir for the configured observations, or use NULL for published summaries.", call. = FALSE)
  }
  call <- match.call()
  frame <- environment()
  .client_call("pbpk_study_results", .client_arguments(call, frame))
}
