# Scientific User Guide

## 1. Scope

INTEGRA-PBPK-Engine provides a unified R interface for modeling, simulation, sensitivity analysis, uncertainty analysis, and exposure reconstruction across supported chemicals.

The examples in this guide use PFBS, the first implemented chemical. Use `pbpk_models()` to inspect available models and their supported capabilities.

## 2. Physiological and chemical parameters

The package distinguishes physiological parameters from chemical-specific parameters.

```r
physiology <- pbpk_physiology(chemical = "PFBS", age = 38, bw = 68, sex = "female")
chemical <- pbpk_chemical_parameters(chemical = "PFBS")
```

Parameter tables contain names, raw values, effective values, units, categories, and information about the source of individual values.

Raw parameter overrides use `parameters`; direct solver-effective overrides use `effective_parameters`.

```r
edited <- pbpk_physiology(
  chemical = "PFBS",
  bw = 70,
  parameters = c(fu = 0.015),
  effective_parameters = c(V_liv = 2.10, Q_kid = 65)
)
```

Raw and effective parameter values are not interchangeable. Derived variables may change when an upstream parameter is changed.

## 3. Forward dosimetry

`pbpk_forward()` predicts time-dependent internal concentrations and amounts following defined exposure events.

An exposure event includes:

| Field | Meaning |
|---|---|
| `time` | Event time in hours |
| `var` | Target model state or input rate |
| `value` | Dose, rate or multiplier |
| `method` | Event operation, such as `replace`, `add` or `mult` |
| `unit` | Optional explicit physical unit |
| `dose_interval_h` | Optional interval for a bolus entered using a rate unit |

For PFBS, `m_oral` and `m_inhalation` are rate states with native units of micrograms per hour. `m_stomach` and `m_dermal` are mass states with native units of micrograms.

Examples:

```r
continuous <- data.frame(time = 0, var = "m_oral", value = 37.5, method = "replace", unit = "ng/kg/day")

bolus <- data.frame(time = 0, var = "m_stomach", value = 2.625, method = "add", unit = "ug")
```

The continuous event remains active as a rate until modified. The bolus directly adds mass at its specified time.

For rate-unit input to a bolus state, specify the applicable interval:

```r
daily_bolus <- data.frame(
  time = 0,
  var = "m_stomach",
  value = 37.5,
  method = "add",
  unit = "ng/kg/day",
  dose_interval_h = 24
)
```

The interval is needed to convert the stated rate into an individual bolus mass. A single bolus at time zero is not equivalent in temporal profile to a continuous rate over an extended period, even if the total mass is the same.

Supported mass-unit labels include ng, ug and mg; normalized and per-time variants are available for the appropriate target states. An explicitly unit-labelled event should be preferred over a value whose units must be inferred.

```r
run <- pbpk_forward(chemical = "PFBS", events = continuous, times = seq(0, 672, by = 24), method = "deterministic", bw = 70)

run$exposure_events$submitted
run$exposure_events$applied
run$exposure_events$normalization_bw_kg
```

Always inspect the applied schedule, especially when body weight normalization or parameter overrides are used.

## 4. Deterministic and Bayesian simulation

A deterministic simulation uses the specified calibrated parameterization.

```r
det <- pbpk_forward(chemical = "PFBS", events = continuous, times = seq(0, 672, by = 24), method = "deterministic")
```

Bayesian simulation uses sampled model parameterization:

```r
bayes <- pbpk_forward(chemical = "PFBS", events = continuous, times = seq(0, 672, by = 24), method = "bayesian", n = 3L, seed = 21L)
```

The `n` argument specifies the requested number of draws. The returned trajectories should be interpreted as model realizations, not repeated observed human measurements.

Use `run$results$trajectories` to inspect model trajectories and `run$effective_parameters` to examine the parameterization used.

## 5. Lower-level simulation

`pbpk_simulate()` provides a lower-level deterministic simulation interface.

Unlike `pbpk_forward()`, it accepts events expressed in the solver's native units rather than unit-labelled dose events.

```r
rate <- 0.00008 * 70 / 24
native_events <- data.frame(time = 0, var = "m_oral", value = rate, method = "replace")

sim <- pbpk_simulate(chemical = "PFBS", events = native_events, times = seq(0, 672, by = 24), bw = 70, outputs = "all")
```

The distinction between labelled and native units is important: a numerical value without a physical unit is not sufficient to document a scientific dose.

## 6. Calibration and evaluation studies

Retrieve the study register:

```r
pbpk_studies(chemical = "PFBS")
```

The current register contains Xu, used for model calibration, and Olsen, used for conditional evaluation.

```r
studies <- pbpk_study_results(chemical = "PFBS")
olsen <- pbpk_study_results(chemical = "PFBS", study = "Olsen")
```

A deterministic study replay can be requested where supported:

```r
replay <- pbpk_study_results(chemical = "PFBS", rerun = TRUE, n_posterior = 0L)
replay$calibration$Xu$deterministic$metrics
replay$evaluation$Olsen$deterministic$metrics
```

Model-specific calibration and evaluation methods are described in the corresponding scientific publications.

## 7. PFBS posterior replay

```r
posterior <- pbpk_pfbs_posterior(chemical = "PFBS", n = 3L, seed = 20260928L)
posterior$summary
posterior$draw_ids
```

These samples correspond to the calibrated PFBS posterior associated with the Xu study.

## 8. Global sensitivity analysis

Sensitivity analysis identifies the contribution or local effect of parameters on specified endpoints and exposure scenarios.

Retrieve the archived analysis:

```r
s <- pbpk_sensitivity(chemical = "PFBS")
plot(s)
```

Run a small targeted Morris analysis:

```r
morris <- pbpk_sensitivity(chemical = "PFBS", method = "morris", scenario = "chronic_bw", n = 1L)
head(morris)
```

A sensitivity suite can be recomputed:

```r
preview <- pbpk_sensitivity(chemical = "PFBS", rerun = TRUE, design = "preview")
plot(preview, source = "recomputed", method = "morris")
```

A preview is a small numerical design for checking functionality. It is not necessarily adequate for precise global sensitivity inference.

For a rerun result, `plot()` chooses recomputed results by default. Use `source = "archive"` to inspect the archived reference.

## 9. Predictive uncertainty

Uncertainty calculations provide posterior or crossed physiological–kinetic predictive distributions.

```r
u <- pbpk_uncertainty(chemical = "PFBS")
plot(u)

posterior_u <- pbpk_uncertainty(chemical = "PFBS", method = "posterior", scenario = "chronic_bw", n = 3L)
posterior_u$summary
```

When recomputing a suite, the returned `recomputed` field contains the design, plan and numerical results.

Posterior parameter uncertainty and physiological variability should be distinguished when reporting results.

## 10. Exposure reconstruction from serum

`pbpk_reconstruct()` estimates intake values from serum concentrations using numerical inversion of the complete PBPK model.

For each input row, provide an individual serum concentration and available demographic information.

```r
hbm <- data.frame(
  id = "synthetic_example",
  serum_ng_mL = 0.01,
  age_years = 30,
  body_weight_kg = 70,
  sex = "male"
)

inverse <- pbpk_reconstruct(chemical = "PFBS", hbm = hbm, method = "deterministic", exposure_days = 365)
```

Supported reconstruction approaches:

| Method | Interpretation |
|---|---|
| `deterministic` | Fixed calibrated parameterization |
| `bayesian_tk` | Toxicokinetic parameter uncertainty |
| `bayesian_tk_physiology` | Toxicokinetic and physiological uncertainty |

The returned `intake_ug_kg_day` field is body-weight-normalized intake in micrograms per kilogram body weight per day. `replayed_serum_ng_mL` permits a direct forward-replay check.

Reconstructed values are model-derived exposure estimates, not independently observed intake measurements.

## 11. Model equations and diagrams

The package exposes scientific model documentation:

```r
equations <- pbpk_equations(chemical = "PFBS", file = tempfile(fileext = ".pdf"), overwrite = TRUE)

diagram <- pbpk_mermaid(chemical = "PFBS", plot = FALSE)
```

These functions provide the available model equations and compartment diagram for the selected chemical.

## 12. Reproducibility

Scientific results contain run records:

```r
run$run_record
attr(inverse, "run_record")
```

A reproducible report should state the chemical, model revision, parameter revision, exposure scenario, dose unit, demographics, model method, relevant sampling settings and output endpoint.

See [Reproducibility](05_Reproducibility.md).
