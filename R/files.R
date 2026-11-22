.client_flag <- function(x, name) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) stop(name, " must be TRUE or FALSE.", call. = FALSE)
  x
}

.client_destination <- function(file, overwrite) {
  if (!is.character(file) || length(file) != 1L || is.na(file) || !nzchar(file) ||
      dir.exists(file) || !dir.exists(dirname(file))) stop("Choose a local filename in an existing directory.", call. = FALSE)
  if (file.exists(file) && !overwrite) stop("File exists. Choose another filename or set overwrite = TRUE.", call. = FALSE)
}

.client_save <- function(bytes, file, overwrite) {
  tmp <- tempfile(".integra-", tmpdir = dirname(file))
  on.exit(unlink(tmp), add = TRUE)
  writeBin(bytes, tmp)
  .client_destination(file, overwrite)
  # A completed file on the target volume can be installed in one rename.
  if (!file.exists(file) || overwrite) {
    if (file.rename(tmp, file)) return(invisible(normalizePath(file, mustWork = TRUE)))
  }
  stop("Could not install the completed file at the chosen destination.", call. = FALSE)
}

pbpk_equations <- function(chemical = NULL, file = NULL, overwrite = FALSE, model = NULL) {
  .client_flag(overwrite, "overwrite")
  args <- list()
  user_call <- sys.call()
  legacy <- !.client_named_chemical(user_call) && is.character(chemical) && length(chemical) == 1L && !is.na(chemical) &&
    grepl("[.]pdf$|[/\\\\]", chemical, ignore.case = TRUE)
  if (legacy) {
    destination <- chemical
    if (!is.null(file)) args$chemical <- file
    if (!is.null(model)) args$model <- model
    file <- destination
  } else {
    if (!missing(chemical)) args$chemical <- chemical
    if (!is.null(model)) args$model <- model
  }
  if (is.null(file)) {
    identifier <- if (is.null(model)) chemical else model
    if (is.null(identifier)) {
      registered <- .client_call("pbpk_models")
      if (nrow(registered) != 1L) stop("Choose a chemical for the equations PDF.", call. = FALSE)
      identifier <- registered$model[[1L]]
      args$chemical <- identifier
    }
    # Use only a filename-safe identifier for an automatically chosen local file.
    if (!is.character(identifier) || length(identifier) != 1L || is.na(identifier)) stop("Supply a chemical identifier.", call. = FALSE)
    label <- gsub("[^A-Za-z0-9_-]+", "-", identifier)
    file <- paste0(label, "-equations.pdf")
  }
  .client_destination(file, overwrite)
  bytes <- .client_call("pbpk_equations", args)
  if (!is.raw(bytes) || length(bytes) < 5L || !identical(bytes[seq_len(5L)], charToRaw("%PDF-"))) {
    stop("The PBPK service returned an invalid PDF.", call. = FALSE)
  }
  .client_save(bytes, file, overwrite)
}

pbpk_mermaid <- function(chemical, file = NULL, plot = FALSE, overwrite = FALSE,
                         detail = c("full", "organs", "states")) {
  .client_flag(plot, "plot")
  .client_flag(overwrite, "overwrite")
  if (!is.null(file)) .client_destination(file, overwrite)
  result <- .client_call("pbpk_mermaid", list(chemical = chemical, detail = match.arg(detail), plot = plot))
  code <- if (plot) result$code else result
  if (!is.character(code) || length(code) != 1L || is.na(code)) stop("The PBPK service returned invalid Mermaid text.", call. = FALSE)
  if (plot) {
    if (!is.list(result$images) || !length(result$images)) stop("The PBPK service returned an empty diagram.", call. = FALSE)
    for (image in result$images) {
      if (!is.raw(image)) stop("Invalid diagram image.", call. = FALSE)
      raster <- png::readPNG(image, native = TRUE)
      grid::grid.newpage()
      grid::grid.raster(raster)
    }
  }
  if (!is.null(file)) .client_save(charToRaw(enc2utf8(paste0(code, "\n"))), file, overwrite)
  code
}
