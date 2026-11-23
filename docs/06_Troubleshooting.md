# Troubleshooting

## Installation fails

Confirm that R is installed, that CRAN is accessible and that the repository name is spelled correctly.

```r
install.packages("devtools")
devtools::install_github("auth-envelab/INTEGRA-PBPK-Engine", ref = "v0.6.0", upgrade = "never")
```

Use the version tag to install a specific release.

If dependencies cannot be downloaded, check proxy settings, package-library permissions and the R version.

## The package installs but model calls fail

Installation and scientific execution are separate operations.

INTEGRA requires an accessible numerical service. Confirm that the operator supplied a valid connection configuration, that the service is running, and that it supports client version 0.6.0.

A localhost address refers to the computer running the current R session.

## A chemical is not recognized

Use:

```r
pbpk_models()
```

Version 0.6.0 registers PFBS.

## A dose is rejected

Inspect the event table and verify `time`, `var`, `value` and `method`.

When using explicitly labelled units, ensure the physical unit is supported for the chosen target state.

A bolus specified using a rate unit requires an appropriate `dose_interval_h`.

## Normalized exposure gives an unexpected value

Check the body weight resolved by the model and the applied event schedule:

```r
run$exposure_events$normalization_bw_kg
run$exposure_events$applied
```

A rate expressed in ng/kg/day is not numerically equivalent to a rate in micrograms/hour until it has been multiplied by body weight and converted into native units.

## A plot shows archived rather than new results

For recomputed analyses, use:

```r
plot(result, source = "recomputed")
```

For archived reference values:

```r
plot(result, source = "archive")
```

A result that has never been recomputed cannot be plotted with `source = "recomputed"`.

## A preview has unstable sensitivity indices

Small designs are intended primarily for functionality checks. Increase the numerical design to an appropriate scientific size before interpreting global indices quantitatively.

Do not interpret a preview as a converged final sensitivity analysis.

## Exposure reconstruction does not match the intended exposure

Check the assumed duration of exposure, measured serum units, age, body weight, sex, parameter overrides and method.

The reconstructed intake depends on these assumptions. Examine replayed serum predictions and diagnostic status fields.

## RStudio delays when expanding result objects

Archived draw tables may be loaded on demand from the service. Inspect the table index before accessing large tables, and avoid expanding large remote-backed objects unnecessarily.

## Results differ from a previous run

Compare the package version, model revision, parameter revision, exposure schedule, demographics, seeds and draw identifiers.

A matching package version does not guarantee identical results against a different service or model revision.

## Reporting a software problem

Include the public package version, operation, anonymized example inputs, error text and run-record fields that do not contain confidential information.

Do not post credentials or identifiable human biomonitoring records in public GitHub issues.
