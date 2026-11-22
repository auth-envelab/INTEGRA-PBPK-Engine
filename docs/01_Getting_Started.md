# Getting Started

## 1. System requirements

INTEGRA-PBPK-Engine 0.6.0 is distributed as an R source package.

Users require a working R installation, access to CRAN for package dependencies, and connectivity to a compatible INTEGRA PBPK service for scientific requests.

The R client does not require the user to compile or install the private PFBS engine.

## 2. Install the package

Following public release:

```r
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
devtools::install_github("auth-envelab/INTEGRA-PBPK-Engine", ref = "v0.6.0", upgrade = "never")
library(IntegraPBPKengine)
packageVersion("IntegraPBPKengine")
```

The expected package version is `0.6.0`.

The latest development branch may differ from the tagged scientific release. Prefer a version tag for reproducible scientific work.

## 3. Connect to the numerical service

The package delegates scientific calculations to a separately operated INTEGRA service.

Before requesting model results, obtain the current service connection instructions from the operator. These may include an endpoint URL, authentication requirements, a compatible service version, and any request limits.

The private owner's development address `127.0.0.1` is not a public endpoint and is not a valid remote address for an unrelated user's computer.

The 0.6.0 repository does not currently specify a publicly hosted endpoint or a universal credential mechanism. Connection instructions must be completed and validated before advertising unrestricted public numerical access.

## 4. Identify available models

Once service access is configured:

```r
library(IntegraPBPKengine)

models <- pbpk_models()
print(models)

pfbs <- pbpk_models(chemical = "PFBS")
```

In version 0.6.0, PFBS is the registered model.

## 5. Inspect the physiological configuration

```r
phys <- pbpk_physiology(chemical = "PFBS", age = 30, bw = 70, sex = "male")
head(phys)
```

The default reference age is 30 years and the default body weight is 70 kg when these inputs are omitted. The effective physiological profile should be inspected when scientific work depends on subject-specific assumptions.

## 6. Run a first simulation

```r
events <- data.frame(time = 0, var = "m_oral", value = 37.5, method = "replace", unit = "ng/kg/day")

run <- pbpk_forward(
  chemical = "PFBS",
  events = events,
  times = seq(0, 24 * 28, by = 24),
  method = "deterministic",
  bw = 70
)

trajectory <- run$results$trajectories$deterministic

head(trajectory[c("time", "C_pls_ven")])
run$exposure_events$applied
```

Time is in hours. Venous plasma concentration is reported in ng/mL.

## 7. Inspect the run record

```r
run$run_record
```

The record documents the chemical, the model and parameter revisions, exposure assumptions, relevant defaults and overrides, and available simulation metadata.

## 8. Discover function help

Use the installed R help system:

```r
help(package = "IntegraPBPKengine")
?pbpk_forward
?pbpk_reconstruct
?pbpk_sensitivity
```

Read the [User Guide](02_User_Guide.md) before performing quantitative exposure reconstruction.
