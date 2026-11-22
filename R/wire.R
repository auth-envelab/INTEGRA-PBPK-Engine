# Transport plain data between the client and the engine. Numeric columns use
# fixed-width little-endian values to preserve precision and missing values.
# The protocol accepts only the tags and fixed output classes named below.
.wire_result_classes <- c("pbpk_study_results", "pbpk_study_fit", "pbpk_xu_posterior",
                          "pbpk_analysis_results", "pbpk_result_tables")

.wire_error <- function() stop("Invalid or unsupported PBPK data in the request or response.", call. = FALSE)

.wire_strings <- function(x) unname(as.list(as.character(x)))

.wire_decode_strings <- function(x) {
  if (!is.list(x) || !is.null(names(x))) .wire_error()
  vapply(x, function(item) {
    if (is.null(item)) return(NA_character_)
    if (!is.character(item) || length(item) != 1L || is.na(item)) .wire_error()
    item
  }, character(1L), USE.NAMES = FALSE)
}

.wire_text <- function(x) is.character(x) && length(x) == 1L && !is.na(x)

.wire_count <- function(x) {
  if (!is.numeric(x) || length(x) != 1L || !is.finite(x) ||
      x < 0 || x != floor(x) || x > .Machine$integer.max) .wire_error()
  as.integer(x)
}

.wire_fields <- function(node, required, optional = character()) {
  fields <- names(node)
  if (!is.list(node) || is.null(fields) || anyNA(fields) || anyDuplicated(fields) ||
      !all(required %in% fields) || !all(fields %in% c(required, optional))) .wire_error()
}

.wire_base64 <- function(bytes) {
  if (length(bytes) == 0L) "" else as.character(jsonlite::base64_enc(bytes))
}

.wire_bytes <- function(text) {
  if (!.wire_text(text)) .wire_error()
  if (!nzchar(text)) return(raw())
  # base64_enc() may wrap long lines. Strip only permitted MIME whitespace.
  clean <- gsub("[\r\n]", "", text, perl = TRUE)
  n <- nchar(clean, type = "bytes")
  if (n %% 4L != 0L || grepl("[^A-Za-z0-9+/=]", clean, perl = TRUE, useBytes = TRUE)) .wire_error()
  pad <- if (endsWith(clean, "==")) 2L else if (endsWith(clean, "=")) 1L else 0L
  first_pad <- regexpr("=", clean, fixed = TRUE)[1L]
  if (first_pad > 0L && first_pad != n - pad + 1L) .wire_error()
  bytes <- jsonlite::base64_dec(clean)
  if (length(bytes) != n / 4 * 3 - pad) .wire_error()
  bytes
}

pbpk_wire_pack <- function(x) {
  encode <- function(value, depth) {
    if (depth > 40L) .wire_error()
    if (is.null(value)) return(list(t = "null"))
    encode_items <- function(items) unname(lapply(items, encode, depth = depth + 1L))
    if (is.data.frame(value)) {
      table <- unclass(value)
      return(list(t = "table", tbl = inherits(value, "tbl_df"), rows = nrow(value),
                  names = .wire_strings(names(table)), cols = encode_items(table)))
    }
    label <- names(value)
    metadata <- list()
    if (is.factor(value)) {
      metadata$levels <- .wire_strings(levels(value))
      metadata$ordered <- is.ordered(value)
      value <- as.integer(value)
    } else if (inherits(value, "Date")) {
      metadata$date <- TRUE
      value <- as.double(value)
    } else if (inherits(value, "POSIXct") || inherits(value, "POSIXlt")) {
      when <- as.POSIXct(value)
      tz <- attr(when, "tzone", exact = TRUE)
      metadata$zone <- if (length(tz) && .wire_text(tz[1L])) tz[1L] else ""
      value <- as.double(when)
    } else if (is.list(value) && is.null(dim(value))) {
      cls <- attr(value, "class", exact = TRUE)
      if (!is.null(cls) && !(length(cls) == 1L && cls %in% .wire_result_classes)) .wire_error()
      # Drop class before iterating so private lazy result accessors never run.
      out <- list(t = "list", items = encode_items(unclass(value)))
      if (!is.null(cls)) out$cls <- cls
      if (!is.null(label)) out$names <- .wire_strings(label)
      return(out)
    } else if (is.object(value)) {
      .wire_error()
    }
    if (!is.null(dim(value))) .wire_error()
    kind <- typeof(value)
    if (!kind %in% c("logical", "integer", "double", "character", "raw")) .wire_error()
    data <- switch(kind,
      character = .wire_strings(value),
      raw = .wire_base64(value),
      logical = .wire_base64(as.raw(ifelse(is.na(value), 2L, as.integer(value)))),
      integer = .wire_base64(writeBin(unname(value), raw(), size = 4L, endian = "little")),
      double = .wire_base64(writeBin(unname(value), raw(), size = 8L, endian = "little")))
    out <- c(list(t = kind, data = data), metadata)
    if (!is.null(label)) out$names <- .wire_strings(label)
    out
  }
  encode(x, 0L)
}

pbpk_wire_unpack <- function(node, response = FALSE) {
  decode <- function(value, depth) {
    if (depth > 40L || !is.list(value) || !.wire_text(value[["t", exact = TRUE]])) .wire_error()
    tag <- value[["t", exact = TRUE]]
    decode_items <- function(items) {
      if (!is.list(items) || !is.null(names(items))) .wire_error()
      lapply(items, decode, depth = depth + 1L)
    }
    if (tag == "null") {
      .wire_fields(value, "t")
      return(NULL)
    }
    if (tag == "table") {
      .wire_fields(value, c("t", "rows", "tbl", "names", "cols"))
      n <- .wire_count(value$rows)
      if (!is.logical(value$tbl) || length(value$tbl) != 1L || is.na(value$tbl)) .wire_error()
      headers <- .wire_decode_strings(value$names)
      if (anyNA(headers) || anyDuplicated(headers)) .wire_error()
      columns <- decode_items(value$cols)
      if (length(columns) != length(headers)) .wire_error()
      # A zero-column table cannot establish an HBM record count on its own.
      if (!response && !length(columns) && n > 0L) .wire_error()
      for (column in columns) {
        if (is.null(column) || is.data.frame(column) || length(column) != n) .wire_error()
      }
      names(columns) <- headers
      row_names <- if (n > 0L) c(NA_integer_, -n) else integer()
      out <- structure(columns, class = "data.frame", row.names = row_names)
      if (value$tbl) out <- tibble::as_tibble(out, .name_repair = "minimal")
      return(out)
    }
    if (tag == "list") {
      .wire_fields(value, c("t", "items"), c("names", "cls"))
      out <- decode_items(value$items)
      if ("cls" %in% names(value)) {
        cls <- value$cls
        if (!response || !.wire_text(cls) || !cls %in% .wire_result_classes) .wire_error()
        class(out) <- cls
      }
    } else {
      if (!tag %in% c("logical", "integer", "double", "character", "raw")) .wire_error()
      extra <- switch(tag, integer = c("levels", "ordered"), double = c("zone", "date"), character())
      .wire_fields(value, c("t", "data"), c("names", extra))
      if (tag == "character") {
        out <- .wire_decode_strings(value$data)
      } else {
        if (tag == "raw" && !response) .wire_error()
        bytes <- .wire_bytes(value$data)
        if (tag %in% c("integer", "double")) {
          size <- if (tag == "integer") 4L else 8L
          if (length(bytes) %% size != 0L) .wire_error()
          out <- readBin(bytes, what = tag, size = size, n = length(bytes) %/% size, endian = "little")
        } else if (tag == "logical") {
          byte_values <- as.integer(bytes)
          if (any(byte_values > 2L)) .wire_error()
          out <- c(FALSE, TRUE, NA)[byte_values + 1L]
        } else {
          out <- bytes
        }
      }
      if ("levels" %in% names(value) || "ordered" %in% names(value)) {
        if (!all(c("levels", "ordered") %in% names(value)) ||
            !is.logical(value$ordered) || length(value$ordered) != 1L || is.na(value$ordered)) .wire_error()
        levels <- .wire_decode_strings(value$levels)
        if (anyDuplicated(levels) || any(out < 1L | out > length(levels), na.rm = TRUE)) .wire_error()
        out <- structure(out, levels = levels, class = if (value$ordered) c("ordered", "factor") else "factor")
      }
      if ("date" %in% names(value)) {
        if (!identical(value$date, TRUE) || "zone" %in% names(value)) .wire_error()
        class(out) <- "Date"
      }
      if ("zone" %in% names(value)) {
        zone <- value$zone
        if (!.wire_text(zone) || !zone %in% c("", "UTC", "GMT", OlsonNames())) .wire_error()
        out <- structure(out, class = c("POSIXct", "POSIXt"), tzone = zone)
      }
    }
    if ("names" %in% names(value)) {
      labels <- .wire_decode_strings(value$names)
      if (length(labels) != length(out)) .wire_error()
      names(out) <- labels
    }
    out
  }
  decode(node, 0L)
}
