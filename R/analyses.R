# The chemical-only call returns the selected analysis archive. A method or
# target scenario requests a fresh numerical calculation from the private core.
pbpk_sensitivity <- function(chemical = NULL, method = NULL, scenario = "chronic_bw", profile = "standard", n = NULL, workers = 1L, rerun = FALSE, design = "full", model = NULL) {
  user_call <- sys.call()
  definition <- sys.function()
  frame <- environment()
  caller <- parent.frame()
  args <- .client_analysis_arguments("sensitivity", definition, user_call, frame, caller)
  .client_analysis_request("sensitivity", args)
}

pbpk_uncertainty <- function(chemical = NULL, method = NULL, scenario = "chronic_bw", profile = "standard", n = NULL, n_phys = NULL, workers = 1L, rerun = FALSE, design = "full", model = NULL) {
  user_call <- sys.call()
  definition <- sys.function()
  frame <- environment()
  caller <- parent.frame()
  args <- .client_analysis_arguments("uncertainty", definition, user_call, frame, caller)
  .client_analysis_request("uncertainty", args)
}

.client_analysis_arguments <- function(kind, definition, call, frame, caller) {
  matched <- match.call(definition, call, envir = caller)
  args <- .client_arguments(matched, frame)
  first <- args[["chemical"]]
  old_methods <- if (kind == "sensitivity") c("local", "morris", "sobol") else c("posterior", "crossed")
  if (!is.character(first) || length(first) != 1L || is.na(first) || !nzchar(first) || is.na(pmatch(first, old_methods))) return(args)

  # An unnamed method as the first positional argument was supported before the
  # chemical-first interface. Rematch argument POSITIONS, reusing already forced
  # values. This also handles forwarded dots and expressions with side effects.
  ordered <- as.list(match.call(function(...) NULL, call, envir = caller))[-1L]
  positions <- as.list(seq_along(ordered))
  names(positions) <- names(ordered)
  indexed_call <- as.call(c(list(quote(analysis)), positions))
  current <- unlist(as.list(match.call(definition, indexed_call))[-1L], use.names = TRUE)
  labels <- names(ordered)
  if (!is.null(labels) && nzchar(labels[[current[["chemical"]]]])) return(args)
  if (!is.null(labels) && any(nzchar(labels) & startsWith("method", labels))) return(args)
  legacy <- if (kind == "sensitivity") {
    function(method, scenario, profile, n, workers, chemical, model, rerun, design) NULL
  } else {
    function(method, scenario, profile, n, n_phys, workers, chemical, model, rerun, design) NULL
  }
  old <- unlist(as.list(match.call(legacy, indexed_call))[-1L], use.names = TRUE)
  reordered <- args[match(unname(old), unname(current))]
  names(reordered) <- names(old)
  reordered
}

.client_analysis_request <- function(kind, args) {
  supplied <- names(args)
  target <- !is.null(args$method) || any(c("scenario", "profile") %in% supplied) || !is.null(args$n) || !is.null(args$n_phys)
  if ("rerun" %in% supplied && (!is.logical(args$rerun) || length(args$rerun) != 1L || is.na(args$rerun))) {
    stop("rerun must be TRUE or FALSE.", call. = FALSE)
  }
  if ("design" %in% supplied) {
    if (!is.character(args$design) || length(args$design) != 1L || is.na(args$design)) stop("Supply one analysis design: preview or full.", call. = FALSE)
    args$design <- match.arg(args$design, c("full", "preview"))
  }
  if (target) {
    if (isTRUE(args$rerun) || "design" %in% supplied) stop("Choose a targeted calculation with method/scenario, or a whole-analysis rerun with rerun and design.", call. = FALSE)
    args$rerun <- NULL
    if (is.null(args$method)) args$method <- if (kind == "sensitivity") "local" else "posterior"
    for (field in intersect(c("method", "scenario", "profile"), names(args))) {
      value <- args[[field]]
      if (!is.character(value) || length(value) != 1L || is.na(value) || !nzchar(value)) stop("Supply one ", field, " for this calculation.", call. = FALSE)
    }
  } else {
    if ("design" %in% supplied && !isTRUE(args$rerun)) stop("Use rerun = TRUE with a preview or full design.", call. = FALSE)
    for (field in c("method", "n", "n_phys")) args[[field]] <- NULL
    # Always flag archive/suite requests so the service can also recognize
    # method-free targeted requests from clients built before this revision.
    args$rerun <- isTRUE(args$rerun)
  }
  result <- .client_call(paste0("pbpk_", kind), args)
  if (target) return(result)
  if (!is.list(result) || !identical(result$analysis, kind) || !is.list(result[[kind]]) || !is.data.frame(result$manifest)) {
    stop("The service did not return the expected ", kind, " archive. Check that the public client and private service have both been updated.", call. = FALSE)
  }
  structure(result, class = paste0("pbpk_", kind, "_results"))
}

.client_print_analysis <- function(x, ...) {
  cat(x$chemical, x$analysis, "analysis\n")
  print(table(x$manifest$section, x$manifest$profile), ...)
  if (!is.null(x$recomputed)) cat("Recomputed design:", x$recomputed$design, "\n")
  invisible(x)
}

print.pbpk_sensitivity_results <- function(x, ...) .client_print_analysis(x, ...)
print.pbpk_uncertainty_results <- function(x, ...) .client_print_analysis(x, ...)

# Select available archive rows by column schema. This keeps plotting usable
# when a new chemical supplies a different list of scenarios or endpoints.
.client_analysis_plot_rows <- function(groups, profiles, preferred_tables, required, scenario, endpoint) {
  for (profile in profiles) {
    tables <- groups[[profile]]
    if (length(names(tables))) tables <- tables[unique(c(intersect(preferred_tables, names(tables)), names(tables)))]
    for (tab in tables) {
      if (!is.data.frame(tab) || !all(required %in% names(tab))) next
      chosen <- tab[tab$scenario %in% scenario & tab$endpoint %in% endpoint, , drop = FALSE]
      if (nrow(chosen)) return(chosen)
    }
  }
  stop("There is no archived plot for this scenario, endpoint and profile.", call. = FALSE)
}



# Only the selected collection of result tables is inspected. A missing rerun
# endpoint stays missing even if an archived estimate exists for that endpoint.
.client_plot_context <- function(x, kind, source, profile, scenario, endpoint) {
  scalar_text <- function(value) is.character(value) && length(value) == 1L && !is.na(value) && nzchar(value)
  if (!scalar_text(scenario) || !scalar_text(endpoint) || (!is.null(profile) && !scalar_text(profile))) {
    stop("Select one scenario, endpoint and optional profile for this plot.", call. = FALSE)
  }
  if (source == "auto") source <- if (is.null(x$recomputed)) "archive" else "recomputed"
  if (source == "recomputed" && is.null(x$recomputed)) stop("This object contains no recomputed analysis. Request a rerun first.", call. = FALSE)
  groups <- if (source == "archive") x[[kind]] else x$recomputed$results
  profiles <- profile
  if (is.null(profiles)) {
    preferred <- if (kind == "sensitivity" && scenario == "chronic_bw" && endpoint == "urine_lastday_ug") c("closure", "standard") else "standard"
    profiles <- unique(c(intersect(preferred, names(groups)), names(groups)))
  }
  origin <- if (source == "archive") "archive" else paste(c("recomputed", x$recomputed$design), collapse = " ")
  list(groups = groups, profiles = profiles, source = source, origin = origin, scenario = scenario, endpoint = endpoint)
}

.client_plot_no_rows <- function(context, method) {
  stop("No ", context$origin, " plot is available for ", context$scenario, " / ", context$endpoint,
       " using ", paste(method, collapse = " or "), " in ", paste(context$profiles, collapse = ", "), ".", call. = FALSE)
}

.client_plot_matching_rows <- function(table, context, columns) {
  if (!is.data.frame(table) || !all(c("scenario", "endpoint", columns) %in% names(table))) return(NULL)
  table[table$scenario %in% context$scenario & table$endpoint %in% context$endpoint, , drop = FALSE]
}

.client_plot_tables <- function(group, context, method, preferred) {
  if (context$source == "recomputed") {
    leaf <- group[[method]][[context$scenario]]
    if (is.list(leaf) && !is.data.frame(leaf)) leaf <- leaf$summary
    return(list(leaf))
  }
  group[unique(c(intersect(preferred, names(group)), names(group)))]
}

.client_plot_count_label <- function(n) {
  counts <- range(n[is.finite(n)])
  if (counts[1L] == counts[2L]) return(as.character(counts[1L]))
  paste(counts, collapse = "-")
}

.client_sensitivity_figure <- function(x, context, method) {
  metrics <- c(sobol = "ST", morris = "mu_star", local = "elasticity")
  methods <- if (is.null(method)) names(metrics) else match.arg(method, names(metrics))
  labels <- c(sobol = "Total Sobol index", morris = "Morris mean absolute elementary effect", local = "Normalized local elasticity")
  for (profile in context$profiles) {
    group <- context$groups[[profile]]
    for (selected in methods) {
      metric <- metrics[[selected]]
      tables <- .client_plot_tables(group, context, selected, c(selected, if (selected == "sobol") "sobol_urine"))
      for (table in tables) {
        rows <- .client_plot_matching_rows(table, context, c("parameter", metric))
        if (!NROW(rows)) next
        if ("method" %in% names(rows)) rows <- rows[rows$method %in% selected, , drop = FALSE]
        if (!nrow(rows)) next
        p <- length(unique(rows$parameter))
        size <- paste0("p = ", p, " parameters")
        if (selected == "sobol") {
          n <- if ("N" %in% names(rows)) rows$N else rows$n
          if (!length(n) || !any(is.finite(n))) next
          largest <- max(n[is.finite(n)])
          rows <- rows[is.finite(n) & n == largest, , drop = FALSE]
          size <- paste0("base N = ", largest)
          if ("n_replicates" %in% names(rows) && any(is.finite(rows$n_replicates))) {
            size <- paste0(size, ", replicates = ", .client_plot_count_label(rows$n_replicates))
          }
        } else if (selected == "morris") {
          n <- if ("n" %in% names(rows)) rows$n else rows$n_valid
          if (length(n) && any(is.finite(n))) size <- paste0(if ("n" %in% names(rows)) "trajectories = " else "valid trajectories = ", .client_plot_count_label(n))
        }
        values <- rows[[metric]]
        eligible <- which(is.finite(values))
        if (!length(eligible)) stop("The selected sensitivity result contains no finite ", metric, " values.", call. = FALSE)
        ranking <- if (selected == "local") abs(values[eligible]) else values[eligible]
        chosen <- rev(utils::head(eligible[order(ranking, decreasing = TRUE)], 8L))
        return(list(value = values[chosen], label = as.character(rows$parameter[chosen]), xlab = labels[[selected]],
                    main = paste(x$chemical, "sensitivity", context$origin, sep = " | "),
                    sub = paste(profile, selected, context$scenario, context$endpoint, size, sep = " | ")))
      }
    }
  }
  .client_plot_no_rows(context, methods)
}

# Some archive summaries contain one exposure scenario and therefore omit its
# column. Accept the scenario only when the table key or recorded source names
# it explicitly. The full archive may contain summaries for different scenarios.
.client_archive_scenario <- function(table, key, manifest, profile, scenario) {
  if (!is.data.frame(table) || "scenario" %in% names(table) || !"endpoint" %in% names(table)) return(table)
  files <- character()
  if (all(c("section", "profile", "table", "source") %in% names(manifest))) {
    keep <- manifest$section %in% "uncertainty" & manifest$profile %in% profile & manifest$table %in% key
    files <- basename(gsub("\\\\", "/", as.character(manifest$source[keep])))
  }
  token <- function(value) paste0("_", gsub("[^[:alnum:]]+", "_", tolower(value)), "_")
  if (any(grepl(token(scenario), token(c(key, files)), fixed = TRUE))) table$scenario <- rep(scenario, nrow(table))
  table
}

.client_uncertainty_figure <- function(x, context, method) {
  # Preserve the archived four-ensemble comparison. For a replay use the
  # posterior and crossed summaries independently produced by the solver.
  methods <- if (is.null(method)) {
    if (context$source == "archive") c("ensembles", "posterior") else c("posterior", "crossed")
  } else match.arg(method, c("posterior", "crossed"))
  for (profile in context$profiles) {
    groups <- context$groups[[profile]]
    found <- list()
    for (selected in methods) {
      preferred <- switch(selected, ensembles = "ensembles", crossed = c("crossed", "ensembles"), posterior = c("posterior", "posterior_summary"))
      tables <- .client_plot_tables(groups, context, selected, preferred)
      if (context$source == "archive" && selected == "posterior") {
        # Prefer the pooled summary. The closure archive may contain only
        # population-specific posterior intervals, each shown with its own label.
        strata <- vapply(tables, function(table) "population" %in% names(table), logical(1))
        tables <- tables[order(strata)]
      }
      for (i in seq_along(tables)) {
        table <- tables[[i]]
        if (context$source == "archive") table <- .client_archive_scenario(table, names(tables)[i], x$manifest, profile, context$scenario)
        rows <- .client_plot_matching_rows(table, context, c("p025", "median", "p975"))
        if (!NROW(rows)) next
        if ("method" %in% names(rows)) rows <- rows[rows$method %in% selected, , drop = FALSE]
        if (context$source == "archive") {
          if (any(c("stratum", "stress_ensemble") %in% names(rows))) next
          if ("population" %in% names(rows) && selected != "posterior") next
          if (selected == "ensembles" && !"ensemble" %in% names(rows)) next
          if (selected == "posterior" && ("ensemble" %in% names(rows) || !any(c("n", "method") %in% names(rows)))) next
          if (selected == "crossed") {
            if ("ensemble" %in% names(rows)) rows <- rows[rows$ensemble %in% "combined", , drop = FALSE] else if (!"method" %in% names(rows)) next
          }
        }
        if (!nrow(rows)) next
        label <- if ("ensemble" %in% names(rows)) as.character(rows$ensemble) else rep(selected, nrow(rows))
        if (selected == "posterior" && "population" %in% names(rows)) label <- paste("posterior", rows$population)
        if (selected == "crossed" && context$source == "archive" && "ensemble" %in% names(rows)) label <- paste("crossed", label)
        n <- if ("n_total" %in% names(rows)) rows$n_total else rows$n
        if (length(n)) label <- ifelse(is.finite(n), paste0(label, " (n=", n, ")"), label)
        finite <- is.finite(rows$median) & is.finite(rows$p025) & is.finite(rows$p975)
        if (!any(finite)) stop("The selected uncertainty result contains no finite predictive intervals.", call. = FALSE)
        found[[selected]] <- data.frame(label = label[finite], value = rows$median[finite], lower = rows$p025[finite], upper = rows$p975[finite])
        break
      }
      if (context$source == "archive" && length(found)) break
    }
    if (length(found)) {
      return(list(rows = do.call(rbind, unname(found)), main = paste(x$chemical, "uncertainty", context$origin, sep = " | "),
                  sub = paste(profile, paste(names(found), collapse = " + "), context$scenario, context$endpoint, sep = " | ")))
    }
  }
  .client_plot_no_rows(context, methods)
}

plot.pbpk_sensitivity_results <- function(x, scenario = "chronic_bw", endpoint = "serum_ng_ml", profile = NULL, ..., source = c("auto", "archive", "recomputed"), method = NULL) {
  context <- .client_plot_context(x, "sensitivity", match.arg(source), profile, scenario, endpoint)
  figure <- .client_sensitivity_figure(x, context, method)
  defaults <- list(x = figure$value, labels = figure$label, main = paste(figure$main, figure$sub, sep = "\n"), xlab = figure$xlab)
  do.call(graphics::dotchart, utils::modifyList(defaults, list(...)))
  invisible(x)
}

plot.pbpk_uncertainty_results <- function(x, scenario = "chronic_bw", endpoint = "serum_ng_ml", profile = NULL, ..., source = c("auto", "archive", "recomputed"), method = NULL) {
  context <- .client_plot_context(x, "uncertainty", match.arg(source), profile, scenario, endpoint)
  figure <- .client_uncertainty_figure(x, context, method)
  rows <- figure$rows
  at <- seq_len(nrow(rows))
  # Reserve enough device space to print ensemble names and draw counts.
  margins <- graphics::par("mai")
  on.exit(graphics::par(mai = margins), add = TRUE)
  label_width <- max(graphics::strwidth(rows$label, units = "inches", cex = 0.7)) + 0.22
  graphics::par(mai = replace(margins, 2L, max(margins[2L], min(label_width, grDevices::dev.size("in")[1L] * .45))))
  defaults <- list(x = rows$value, y = at, yaxt = "n", pch = 16, xlim = range(rows$lower, rows$upper), xlab = endpoint, ylab = "", main = paste(figure$main, figure$sub, sep = "\n"))
  do.call(graphics::plot, utils::modifyList(defaults, list(...)))
  graphics::segments(rows$lower, at, rows$upper, at)
  graphics::axis(2, at = at, labels = rows$label, las = 2, cex.axis = 0.7)
  invisible(x)
}
