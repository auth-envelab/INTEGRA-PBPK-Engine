# INTEGRA-PBPK-Engine 0.6.1
# Example 4: Archived sensitivity, targeted numerical analyses and uncertainty
# Small n values are demonstration designs, not convergence claims.

library(IntegraPBPKengine)

chemical <- "PFBS"

sensitivity_archive <- pbpk_sensitivity(chemical = chemical)
uncertainty_archive <- pbpk_uncertainty(chemical = chemical)

plot(sensitivity_archive, source = "archive")
plot(uncertainty_archive, source = "archive")

morris <- pbpk_sensitivity(chemical = chemical, method = "morris", scenario = "chronic_bw", n = 1L)
posterior <- pbpk_uncertainty(chemical = chemical, method = "posterior", scenario = "chronic_bw", n = 3L)

print(head(morris))
print(posterior$summary)

# Optional numerical suites: may require substantially more computation.
run_previews <- FALSE

if (run_previews) {
  sensitivity_preview <- pbpk_sensitivity(chemical = chemical, rerun = TRUE, design = "preview")
  uncertainty_preview <- pbpk_uncertainty(chemical = chemical, rerun = TRUE, design = "preview")

  plot(sensitivity_preview, source = "recomputed", method = "morris")
  plot(uncertainty_preview, source = "recomputed", method = "posterior")

  print(sensitivity_preview$run_record)
  print(uncertainty_preview$run_record)
}
