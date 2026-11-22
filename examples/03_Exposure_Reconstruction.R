# INTEGRA-PBPK-Engine 0.6.0
# Example 3: Synthetic serum concentration and inverse dosimetry
# This example does not use measured human biomonitoring observations.

library(IntegraPBPKengine)

chemical <- "PFBS"
exposure_days <- 28
intake_ng_kg_day <- 37.5

events <- data.frame(time = 0, var = "m_oral", value = intake_ng_kg_day, method = "replace", unit = "ng/kg/day")

forward <- pbpk_forward(chemical = chemical, events = events, times = seq(0, exposure_days * 24, by = 24), method = "deterministic", age = 30, bw = 70, sex = "male")

synthetic_serum <- tail(forward$results$trajectories$deterministic$C_pls_ven, 1L)

hbm <- data.frame(id = "synthetic_case", serum_ng_mL = synthetic_serum, age_years = 30, body_weight_kg = 70, sex = "male")

reconstructed <- pbpk_reconstruct(chemical = chemical, hbm = hbm, method = "deterministic", exposure_days = exposure_days)

print(reconstructed[c("id", "serum_ng_mL", "intake_ug_kg_day", "replayed_serum_ng_mL", "status")])
print(attr(reconstructed, "run_record"))

message("Synthetic input intake (ug/kg/day): ", intake_ng_kg_day / 1000)
