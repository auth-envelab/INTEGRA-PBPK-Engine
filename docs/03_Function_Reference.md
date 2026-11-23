# Public Function Reference

## Package API

INTEGRA-PBPK-Engine 0.6.1 provides 13 public functions.

The installed R help files are authoritative for exact function signatures and optional argument defaults:

```r
help(package = "IntegraPBPKengine")
```

| Function | Purpose | Main output |
|---|---|---|
| `pbpk_models()` | Registered chemical models and capabilities | Model catalogue |
| `pbpk_physiology()` | Physiological parameterization | Parameter table |
| `pbpk_chemical_parameters()` | Chemical-specific parameterization | Parameter table |
| `pbpk_studies()` | Calibration/evaluation study register | Study table |
| `pbpk_study_results()` | Archived and recomputed study comparisons | Nested study results |
| `pbpk_pfbs_posterior()` | PFBS Xu posterior replay | Posterior replay and draw identifiers |
| `pbpk_sensitivity()` | Archived or recomputed sensitivity analysis | Table or analysis object |
| `pbpk_uncertainty()` | Archived or recomputed uncertainty analysis | Table or analysis object |
| `pbpk_forward()` | Deterministic/Bayesian forward dosimetry | Full trajectories and run record |
| `pbpk_simulate()` | Native-unit lower-level simulation | Trajectory table |
| `pbpk_reconstruct()` | Inverse PBPK exposure reconstruction | Individual intake estimates |
| `pbpk_equations()` | Annotated PBPK equations | PDF path |
| `pbpk_mermaid()` | Model compartment diagram | Mermaid text |

## Model and parameter functions

### pbpk_models

```r
pbpk_models()
pbpk_models(chemical = "PFBS")
```

Returns the available registered models and their supported methods, routes and outputs. The present release supports PFBS.

### pbpk_physiology

```r
pbpk_physiology(chemical = "PFBS", age = 38, bw = 68, sex = "female")
```

Displays raw and effective physiological parameters, units and parameter sources. User overrides may be supplied with `parameters` and `effective_parameters`.

### pbpk_chemical_parameters

```r
pbpk_chemical_parameters(chemical = "PFBS", parameters = c(fu = 0.015))
```

Provides chemical, partition, permeability and kinetic parameterization. Raw and effective values may differ because of physiological scaling and derived model relationships.

## Calibration and evaluation

### pbpk_studies

```r
pbpk_studies(chemical = "PFBS")
```

Lists the calibration and evaluation studies. PFBS includes Xu calibration and Olsen conditional evaluation.

### pbpk_study_results

```r
pbpk_study_results(chemical = "PFBS")
pbpk_study_results(chemical = "PFBS", study = "Olsen")
pbpk_study_results(chemical = "PFBS", rerun = TRUE, n_posterior = 0L)
```

Provides study-specific observations, predictions and numerical fit metrics where available. Recomputed results depend on the study's supported protocol.

### pbpk_pfbs_posterior

```r
pbpk_pfbs_posterior(chemical = "PFBS", n = 3L, seed = 20260928L)
```

Replays requested PFBS posterior draws associated with the Xu calibration. Supports draw identifiers and predictive summaries.

## Sensitivity and uncertainty

### pbpk_sensitivity

```r
pbpk_sensitivity(chemical = "PFBS")
pbpk_sensitivity(chemical = "PFBS", method = "morris", scenario = "chronic_bw", n = 1L)
pbpk_sensitivity(chemical = "PFBS", rerun = TRUE, design = "preview")
```

Methods for PFBS include `local`, `morris`, and `sobol`. Archive and suite requests return an analysis object; targeted calculations return method-specific results.

For analysis objects:

```r
plot(sensitivity_result, source = "archive")
plot(sensitivity_result, source = "recomputed", method = "morris")
```

`source = "auto"` selects recomputed results if present and otherwise uses archived results.

### pbpk_uncertainty

```r
pbpk_uncertainty(chemical = "PFBS")
pbpk_uncertainty(chemical = "PFBS", method = "posterior", scenario = "chronic_bw", n = 3L)
```

PFBS supports `posterior` and `crossed` uncertainty calculations. Available outputs include predictive summaries and draw-level values.

## Forward dosimetry

### pbpk_forward

```r
pbpk_forward(chemical = "PFBS", events = events, times = times_h, method = "deterministic", bw = 70)
pbpk_forward(chemical = "PFBS", events = events, times = times_h, method = "bayesian", n = 3L, seed = 21L)
```

Input events use `time`, `var`, `value`, and `method`. A `unit` column permits explicitly labelled doses and rates. Some conversions require `dose_interval_h`.

Returned data include `results$trajectories`, effective parameters, exposure-event information and a scientific `run_record`.

### pbpk_simulate

```r
pbpk_simulate(chemical = "PFBS", events = native_events, times = times_h, bw = 70, outputs = "all")
```

Lower-level simulation with native solver units. It does not accept the unit-labelled exposure-event mechanism of `pbpk_forward`.

## Inverse dosimetry

### pbpk_reconstruct

```r
pbpk_reconstruct(chemical = "PFBS", hbm = hbm, method = "deterministic", exposure_days = 365)
```

For PFBS, input serum values are expressed in ng/mL. Reconstructed intake is reported in micrograms/kg/day.

Methods are `deterministic`, `bayesian_tk`, and `bayesian_tk_physiology`.

The result contains subject-specific estimates, model-replayed serum predictions and diagnostic fields. Retrieve its run record with `attr(result, "run_record")`.

## Scientific model documentation

### pbpk_equations

```r
pbpk_equations(chemical = "PFBS", file = tempfile(fileext = ".pdf"), overwrite = TRUE)
```

Produces an annotated equations PDF.

### pbpk_mermaid

```r
pbpk_mermaid(chemical = "PFBS", plot = FALSE)
```

Provides a compartmental flowchart in Mermaid syntax. Optional plotting and file output are supported.

## Validation and error handling

Scientific requests should use registered chemicals, supported methods, finite and physically valid dose values, positive physiological inputs and appropriate units.

Service access is required. A failed connection should not be interpreted as a model prediction failure.

For exact arguments, run `?function_name` in RStudio.
