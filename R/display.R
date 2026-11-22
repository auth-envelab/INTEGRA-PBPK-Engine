# These methods display returned observations and summaries using ordinary R graphics.
# The service supplies fitted values, intervals, rankings and diagnostic tables.
print.pbpk_study_results <- function(x, ...) {
  cat(x$chemical, "study comparisons\n")
  print(x$studies, ...)
  invisible(x)
}

plot.pbpk_study_results <- function(x, ...) {
  for (study in c(x$calibration, x$evaluation)) {
    fit <- study$deterministic
    endpoints <- unique(fit$observations$endpoint)
    if (!is.null(fit$community_serum)) endpoints <- c("Community serum", endpoints)
    for (endpoint in endpoints) graphics::plot(fit, endpoint = endpoint, ...)
    if (!is.null(study$bayesian)) graphics::plot(study$bayesian, ...)
  }
  invisible(x)
}

.client_plot <- function(defaults, extra) {
  do.call(graphics::plot, utils::modifyList(defaults, extra))
}

plot.pbpk_study_fit <- function(x, endpoint = x$observations$endpoint[1L], ...) {
  if (identical(endpoint, "Community serum")) {
    z <- x$community_serum
    if (is.null(z) || !nrow(z)) stop("A cohort serum table is required for this plot.", call. = FALSE)
    ix <- seq_len(nrow(z))
    ylim <- range(c(z$observed_lower_ng_mL, z$observed_upper_ng_mL, z$predicted_ng_mL), finite = TRUE)
    .client_plot(list(x = ix, y = z$predicted_ng_mL, ylim = ylim, xaxt = "n", xlab = "Sampling round",
                      ylab = paste0("Serum ", if (is.null(x$chemical_id)) "" else paste0(x$chemical_id, " "), "(ng/mL)"), pch = 4, col = "steelblue4", main = x$study), list(...))
    graphics::axis(1, at = ix, labels = z$round)
    graphics::segments(ix + 0.04, z$observed_lower_ng_mL, ix + 0.04, z$observed_upper_ng_mL)
    graphics::points(ix + 0.04, z$observed_lower_ng_mL, pch = 16)
    graphics::points(ix + 0.04, z$observed_upper_ng_mL, pch = 1)
    graphics::legend("topright", c("Predicted", "Observed lower", "Observed upper"), pch = c(4, 16, 1),
                     col = c("steelblue4", "black", "black"), bty = "n")
    return(invisible(x))
  }
  if (!is.character(endpoint) || length(endpoint) != 1L || is.na(endpoint)) stop("Choose one endpoint.", call. = FALSE)
  z <- x$observations[x$observations$endpoint == endpoint, , drop = FALSE]
  if (!nrow(z)) stop("The observations contain no rows for this endpoint.", call. = FALSE)
  bounded <- z$kind == "upper"
  measured <- ifelse(bounded, z$limit, z$observed)
  ylim <- range(c(measured, z$predicted), finite = TRUE)
  .client_plot(list(x = z$day, y = z$predicted, type = "n", ylim = ylim, xlab = "Study day",
                    ylab = paste0(endpoint, " (", z$unit[1L], ")"), main = x$study), list(...))
  for (group in unique(z$group)) {
    rows <- which(z$group == group)
    rows <- rows[order(z$day[rows])]
    graphics::lines(z$day[rows], z$predicted[rows], col = "steelblue4")
  }
  graphics::points(z$day, z$predicted, col = "steelblue4", pch = 1)
  graphics::points(z$day, measured, pch = ifelse(bounded, 6, 16))
  graphics::legend("topright", c("Predicted", "Observed", "Upper bound"), pch = c(1, 16, 6),
                   col = c("steelblue4", "black", "black"), bty = "n")
  invisible(x)
}

plot.pbpk_xu_posterior <- function(x, ...) {
  z <- x$summary[x$summary$kind == "point", , drop = FALSE]
  z <- z[order(z$day), ]
  bands <- c("predictive_p025", "predictive_p975", "latent_p025", "latent_p975")
  limits <- range(c(unlist(z[bands], use.names = FALSE), z$observed), finite = TRUE)
  .client_plot(list(x = z$day, y = z$observed, ylim = limits, type = "n", xlab = "Days after cessation",
                    ylab = paste0("Serum ", if (is.null(x$chemical_id)) "" else paste0(x$chemical_id, " "), "(ng/mL)"), main = if (is.null(x$study)) "Posterior replay" else paste(x$study, "posterior replay")), list(...))
  xx <- c(z$day, rev(z$day))
  graphics::polygon(xx, c(z$predictive_p025, rev(z$predictive_p975)), col = "aliceblue", border = NA)
  graphics::polygon(xx, c(z$latent_p025, rev(z$latent_p975)), col = "lightsteelblue", border = NA)
  graphics::lines(z$day, z$latent_median, col = "steelblue4", lwd = 2)
  graphics::points(z$day, z$observed, pch = 16)
  graphics::legend("topright", c("Observed", "Median", "95% latent", "95% predictive"),
                   pch = c(16, NA, 15, 15), lty = c(NA, 1, NA, NA),
                   col = c("black", "steelblue4", "lightsteelblue", "aliceblue"), bty = "n")
  invisible(x)
}

print.pbpk_analysis_results <- function(x, ...) {
  cat(x$chemical, "sensitivity and uncertainty\n")
  print(table(x$manifest$section, x$manifest$profile), ...)
  if (!is.null(x$recomputed)) cat("Recomputed design:", x$recomputed$design, "\n")
  invisible(x)
}

plot.pbpk_analysis_results <- function(x, scenario = "chronic_bw", endpoint = "serum_ng_ml", ...) {
  source <- if (identical(scenario, "chronic_bw") && identical(endpoint, "urine_lastday_ug")) {
    x$sensitivity$closure$sobol_urine
  } else x$sensitivity$standard$sobol
  scores <- source[source$scenario == scenario & source$endpoint == endpoint & is.finite(source$ST), , drop = FALSE]
  if (!nrow(scores)) stop("Choose a scenario and endpoint with Sobol results.", call. = FALSE)
  scores <- scores[scores$N == max(scores$N), , drop = FALSE]
  show <- utils::head(order(scores$ST, decreasing = TRUE), 8L)
  ens <- x$uncertainty$standard$ensembles
  ens <- ens[ens$scenario == scenario & ens$endpoint == endpoint, , drop = FALSE]
  previous <- graphics::par(mfrow = c(1, 2))
  on.exit(graphics::par(previous))
  graphics::dotchart(scores$ST[rev(show)], labels = scores$parameter[rev(show)], main = "Sensitivity",
                     xlab = "Total Sobol index", ...)
  if (nrow(ens)) {
    ix <- seq_len(nrow(ens))
    graphics::plot(ens$median, ix, yaxt = "n", pch = 16, xlim = range(ens$p025, ens$p975, finite = TRUE),
                   xlab = endpoint, ylab = "", main = "Uncertainty")
    graphics::segments(ens$p025, ix, ens$p975, ix)
    graphics::axis(2, at = ix, labels = ens$ensemble, las = 2, cex.axis = 0.7)
  } else {
    graphics::plot.new()
    graphics::text(0.5, 0.5, "No ensemble for this endpoint")
  }
  invisible(x)
}

`$.pbpk_result_tables` <- function(x, name) x[[name, exact = TRUE]]

`[[.pbpk_result_tables` <- function(x, i, ..., exact = TRUE) {
  entry <- unclass(x)[[i, exact = exact]]
  if (is.null(entry)) return(NULL)
  args <- list(profile = entry$profile[[1L]], table = entry$table[[1L]])
  if ("chemical" %in% names(entry)) args$chemical <- entry$chemical[[1L]]
  .client_call("result_table", args)
}

print.pbpk_result_tables <- function(x, ...) {
  entries <- unclass(x)
  if (length(entries)) {
    index <- do.call(rbind, entries)
    print(index[c("table", "rows")], ...)
  } else {
    cat("No draw tables available.\n")
  }
  invisible(x)
}

# Inspect the local table index. The table accessors retrieve data on demand.
str.pbpk_result_tables <- function(object, ...) {
  index <- unclass(object)
  cat("PBPK archive index (", length(index), " tables)\n", sep = "")
  if (length(index)) utils::str(as.character(names(index)), ...)
  invisible(NULL)
}
