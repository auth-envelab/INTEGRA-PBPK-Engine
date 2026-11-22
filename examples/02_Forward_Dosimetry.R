# INTEGRA-PBPK-Engine 0.6.0
# Example 2: Deterministic and Bayesian forward dosimetry
# All concentration values are model predictions, not observed HBM data.

library(IntegraPBPKengine)

chemical <- "PFBS"
times_h <- seq(0, 24 * 28, by = 24)

events <- data.frame(time = 0, var = "m_oral", value = 37.5, method = "replace", unit = "ng/kg/day")

det <- pbpk_forward(chemical = chemical, events = events, times = times_h, method = "deterministic", age = 30, bw = 70, sex = "male")

bayes <- pbpk_forward(chemical = chemical, events = events, times = times_h, method = "bayesian", n = 3L, seed = 21L, age = 30, bw = 70, sex = "male")

trajectory <- det$results$trajectories$deterministic

plot(trajectory$time / 24, trajectory$C_pls_ven, type = "l", xlab = "Exposure time (days)", ylab = "Venous plasma PFBS (ng/mL)")

print(tail(trajectory[c("time", "C_pls_ven", "m_URN")]))
print(det$exposure_events$applied)
print(det$run_record)

message("Number of Bayesian trajectories: ", length(bayes$results$trajectories))
