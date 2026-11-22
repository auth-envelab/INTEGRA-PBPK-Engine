pbpk_models <- function(chemical = NULL) {
  if (is.null(chemical)) return(.client_call("pbpk_models"))
  .client_call("pbpk_models", list(chemical = chemical))
}

pbpk_physiology <- function(chemical, age = NULL, bw = NULL, sex = NULL, parameters = NULL,
                            effective_parameters = NULL) {
  call <- match.call()
  frame <- environment()
  .client_call("pbpk_physiology", .client_arguments(call, frame))
}

pbpk_chemical_parameters <- function(chemical, age = NULL, bw = NULL, sex = NULL,
                                     parameters = NULL, effective_parameters = NULL) {
  call <- match.call()
  frame <- environment()
  .client_call("pbpk_chemical_parameters", .client_arguments(call, frame))
}

pbpk_studies <- function(chemical = NULL, model = NULL) {
  call <- match.call()
  frame <- environment()
  .client_call("pbpk_studies", .client_arguments(call, frame))
}







pbpk_simulate <- function(events, times, parameters = NULL, initial = NULL, outputs = c("C_pls_ven", "m_URN", "m_Feces"), chemical = NULL, rtol = 1e-8, atol = 1e-10, maxsteps = 50000L, solver = c("lsoda", "radau"), age = NULL, bw = NULL, sex = NULL, effective_parameters = NULL, model = NULL) {
  call <- match.call()
  frame <- environment()
  .client_call("pbpk_simulate", .client_arguments(call, frame))
}

pbpk_forward <- function(chemical, events, times, method = c("deterministic", "bayesian"),
                         n = NULL, seed = 1L, age = NULL, bw = NULL, sex = NULL,
                         parameters = NULL, initial = NULL, rtol = 1e-8, atol = 1e-10,
                         maxsteps = 50000L, solver = "lsoda", effective_parameters = NULL) {
  call <- match.call()
  frame <- environment()
  .client_call("pbpk_forward", .client_arguments(call, frame))
}

pbpk_reconstruct <- function(chemical = NULL, hbm, method = NULL, n = NULL, seed = 1L,
                             exposure_days = 3652.5, parameters = NULL, coefficient_dose = NULL,
                             n_posterior = 0L, model = NULL, effective_parameters = NULL) {
  user_call <- sys.call()
  if (!missing(chemical) && (is.data.frame(chemical) || is.numeric(chemical)) && !.client_named_chemical(user_call)) {
    # Rebind caller-supplied arguments using the original HBM-first signature.
    inputs <- as.list(sys.call())[-1L]
    return(do.call(.client_hbm_first, inputs, envir = parent.frame()))
  }
  call <- match.call()
  frame <- environment()
  .client_call("pbpk_reconstruct", .client_arguments(call, frame))
}

.client_hbm_first <- function(hbm, exposure_days, parameters, n_posterior, coefficient_dose, model, method, n, seed, effective_parameters) {
  call <- match.call()
  frame <- environment()
  .client_call("pbpk_reconstruct", .client_arguments(call, frame))
}

.client_named_chemical <- function(call) {
  labels <- names(as.list(call)[-1L])
  if (is.null(labels)) return(FALSE)
  # R permits unambiguous partial argument names. These count as named selectors.
  any(nzchar(labels) & startsWith("chemical", labels))
}

pbpk_pfbs_posterior <- function(chemical = "PFBS", n = 500L, seed = 20260928L) {
  args <- list(chemical = chemical)
  if (!missing(n)) args$n <- n
  if (!missing(seed)) args$seed <- seed
  .client_call("pbpk_pfbs_posterior", args)
}
