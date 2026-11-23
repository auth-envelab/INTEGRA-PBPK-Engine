# Reproducibility and Scientific Provenance

## 1. Why run records matter

Two simulations may produce different values because of different exposure schedules, body weights, model parameterizations, posterior draws, numerical settings or model revisions.

INTEGRA 0.6.1 attaches a scientific run record to supported outputs.

## 2. Inspect a forward simulation

```r
run <- pbpk_forward(chemical = "PFBS", events = events, times = times_h, method = "deterministic")

record <- run$run_record
print(record)
```

The record identifies the chemical, model and parameter revisions, relevant demographic assumptions, overrides, exposure information and sampling details.

Its contents depend on the type of analysis performed.

## 3. Inspect reconstruction metadata

For results returned as data frames:

```r
record <- attr(inverse, "run_record")
print(record)
```

Do not assume that data-frame attributes survive all transformations or exports. Preserve the run record separately when saving or combining results.

## 4. Record input assumptions

The PFBS default age is 30 years and default body weight is 70 kg.

Explicitly supplied values and automatically assumed defaults should be distinguished. When demographic information is missing from a biomonitoring input, document the resulting assumptions.

Always report the physical dose unit and the exposure-event schedule.

## 5. Preserve the numerical inputs

For a scientific analysis, save the following together:

| Item | Reason |
|---|---|
| Package version | Identifies client behavior |
| Model revision | Identifies the underlying model implementation |
| Parameter revision | Identifies parameter inputs and associated resources |
| Exposure events | Defines the actual dosing history |
| Output times | Defines observation/simulation points |
| Demographics | Defines the individual physiological profile |
| Raw parameter overrides | Defines changes to model input parameters |
| Effective parameter overrides | Defines direct solver-level changes |
| Method and analysis design | Defines the scientific calculation |
| Random seed and draw identifiers | Supports repeated stochastic calculations |
| Run record | Documents the executed request and assumptions |

## 6. Save results

```r
saveRDS(run, "forward-result.rds")
saveRDS(run$run_record, "forward-run-record.rds")
```

These commands save results locally; they do not upload them to INTEGRA or GitHub.

Avoid publishing files containing personally identifiable biomonitoring information.

## 7. Deterministic and Bayesian comparisons

For an interpretable comparison, preserve the same exposure schedule, time grid, demographic profile and overrides when comparing deterministic and Bayesian outputs.

A Bayesian ensemble includes draw-level variation and may not reproduce the deterministic trajectory.

Use fixed seeds when supported. A seed is useful but not necessarily sufficient to reproduce an analysis if model revisions, draw archives or numerical dependencies have changed.

## 8. Archived and recomputed analyses

Archived sensitivity and uncertainty outputs represent previously produced numerical designs.

Recomputed analyses can use different designs, sizes or settings. They should not be interpreted as identical to the archive unless the underlying settings are equivalent.

For plotting:

```r
plot(analysis_result, source = "archive")
plot(analysis_result, source = "recomputed")
```

The second call requires an available recomputed analysis.

## 9. Reporting exposure reconstruction

The returned intake represents a model-consistent estimate for a given serum level and assumed exposure history.

Report serum input concentrations, exposure duration, body-weight normalization, uncertainty treatment and replay diagnostics.

If synthetic or quantile-derived concentrations were used instead of individual measured HBM records, identify them explicitly as synthetic or derived values.

## 10. Version control

For reproducible analyses, install a tagged release:

```r
devtools::install_github("auth-envelab/INTEGRA-PBPK-Engine", ref = "v0.6.1", upgrade = "never")
```

The service revision should also be recorded. Installing an earlier package version does not automatically reproduce a different service revision.
