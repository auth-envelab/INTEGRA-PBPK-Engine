# Only explicitly supplied arguments cross the service boundary. Omitted defaults
# belong to the selected service version and are applied by the engine.
.client_arguments <- function(call, frame) {
  supplied <- names(as.list(call)[-1L])
  if (!length(supplied)) return(list())
  mget(supplied, envir = frame, inherits = FALSE)
}

.client_config <- function() {
  url <- getOption("IntegraPBPKengine.url", Sys.getenv("INTEGRA_PBPK_URL"))
  if (!is.character(url) || length(url) != 1L || is.na(url) || !nzchar(url)) {
    stop("Set options(IntegraPBPKengine.url = ...) to the PBPK service URL supplied by its operator.", call. = FALSE)
  }
  # Restrict cleartext HTTP to a literal loopback address or localhost. The
  # service prefix may contain URL-safe path segments. Credentials use headers.
  host <- "(?:[A-Za-z0-9.-]+|\\[[0-9A-Fa-f:]+\\])"
  suffix <- "(?::[0-9]{1,5})?(?:/[A-Za-z0-9._~-]+)*/?"
  local <- grepl(paste0("^http://(?:localhost|127\\.0\\.0\\.1|\\[::1\\])", suffix, "\\z"), url, perl = TRUE)
  secure <- grepl(paste0("^https://", host, suffix, "\\z"), url, perl = TRUE)
  if (!local && !secure) stop("Use an HTTPS service URL, or HTTP on localhost, 127.0.0.1 or [::1]. Supply credentials separately.", call. = FALSE)
  token <- getOption("IntegraPBPKengine.token", Sys.getenv("INTEGRA_PBPK_TOKEN"))
  if (!is.character(token) || length(token) != 1L || is.na(token) || !nzchar(token) || grepl("[[:cntrl:][:space:]]", token)) {
    stop("Set the service access token before sending data. It must be a single string without whitespace or control characters.", call. = FALSE)
  }
  timeout <- getOption("IntegraPBPKengine.timeout", 0)
  if (!is.numeric(timeout) || length(timeout) != 1L || !is.finite(timeout) || timeout < 0 || timeout > .Machine$integer.max || timeout != floor(timeout)) {
    stop("The request timeout must be a nonnegative whole number of seconds.", call. = FALSE)
  }
  list(url = sub("/$", "", url), loopback = local, token = token, timeout = as.integer(timeout))
}

.client_call_transport <- function(operation, args = list()) {
  cfg <- .client_config()
  request <- list(operation = operation, arguments = pbpk_wire_pack(args))
  json <- jsonlite::toJSON(request, auto_unbox = TRUE, null = "null", na = "null", digits = NA)
  handle <- curl::new_handle(post = TRUE, postfields = charToRaw(enc2utf8(as.character(json))),
    followlocation = FALSE, ssl_verifypeer = TRUE, ssl_verifyhost = 2L, connecttimeout = 20L,
    timeout = cfg$timeout, verbose = FALSE, accept_encoding = "")
  if (cfg$loopback) curl::handle_setopt(handle, proxy = "")
  headers <- list("Content-Type" = "application/json", Accept = "application/json", Expect = "")
  if (nzchar(cfg$token)) headers[["Authorization"]] <- paste("Bearer", cfg$token)
  curl::handle_setheaders(handle, .list = headers)
  response <- tryCatch(curl::curl_fetch_memory(paste0(cfg$url, "/v1/call"), handle = handle),
    error = function(e) stop("Could not complete the PBPK request. Check the service address, availability, TLS configuration and timeout.", call. = FALSE))
  status <- response$status_code
  if (status %in% c(401L, 403L)) stop("The PBPK service rejected the credentials. Check your access token.", call. = FALSE)
  if (status >= 300L && status < 400L) stop("The service returned a redirect. Set the service URL to its final address.", call. = FALSE)
  body <- tryCatch(jsonlite::fromJSON(rawToChar(response$content), simplifyVector = FALSE), error = function(e) NULL)
  if (status != 200L) {
    message <- if (is.list(body) && is.character(body$error) && length(body$error) == 1L) body$error else "Service request failed."
    message <- substr(gsub("[[:cntrl:]]", " ", message), 1L, 512L)
    if (nzchar(cfg$token)) message <- gsub(cfg$token, "[redacted]", message, fixed = TRUE)
    stop(sprintf("PBPK service (HTTP %d): %s", status, message), call. = FALSE)
  }
  if (!is.list(body) || !identical(names(body), "result")) stop("Unexpected PBPK response. Check the client and service versions.", call. = FALSE)
  pbpk_wire_unpack(body$result, response = TRUE)
}

# Transport is unchanged for requests which do not return scientific runs.
.client_call <- function(operation, args = list(), ...) {
  recorded <- c("pbpk_forward", "pbpk_simulate", "pbpk_reconstruct", "pbpk_study_results", "pbpk_pfbs_posterior", "pbpk_sensitivity", "pbpk_uncertainty")
  if (!operation %in% recorded) return(.client_call_transport(operation, args, ...))
  args$include_run_record <- TRUE
  response <- .client_call_transport(operation, args, ...)
  required <- c("record_format", "value", "run_record")
  if (!is.list(response) || is.data.frame(response) || anyDuplicated(names(response)) ||
      !all(required %in% names(response)) || !identical(response[["record_format"]], "integra.run.1") ||
      !is.list(response[["run_record"]]) || is.data.frame(response[["run_record"]])) {
    stop("This client needs the private engine build that provides run records.", call. = FALSE)
  }
  value <- response[["value"]]
  if (is.data.frame(value) || !is.list(value)) attr(value, "run_record") <- response[["run_record"]] else value$run_record <- response[["run_record"]]
  value
}
