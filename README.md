# INTEGRA-PBPK-Engine

**INTEGRA-PBPK-Engine** is an R interface for physiologically based pharmacokinetic (PBPK) modeling, supporting mechanistic dosimetry, scientific model evaluation, parameter exploration, uncertainty analysis, and exposure reconstruction.

The public R package is named **`IntegraPBPKengine`**. The GitHub repository is maintained under the **`auth-envelab`** organization.

**Version:** 0.6.0  
**Repository:** https://github.com/auth-envelab/INTEGRA-PBPK-Engine

## About INTEGRA

INTEGRA-PBPK-Engine provides a unified R interface for physiologically based pharmacokinetic modeling, simulation, uncertainty analysis, and exposure reconstruction across supported chemicals.

PFBS is the first implemented chemical, with additional models planned for future releases.

## Installation

Install from the public GitHub repository after version 0.6.0 has been released:

```r
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
devtools::install_github("auth-envelab/INTEGRA-PBPK-Engine", ref = "v0.6.0", upgrade = "never")
library(IntegraPBPKengine)
packageVersion("IntegraPBPKengine")
```

Installation requires R and the package dependencies declared in `DESCRIPTION`.

Model calculations require a configured INTEGRA service connection.

## First scientific example

After an INTEGRA service has been configured and confirmed accessible:

```r
library(IntegraPBPKengine)

models <- pbpk_models()
print(models)

events <- data.frame(
  time = 0,
  var = "m_oral",
  value = 37.5,
  method = "replace",
  unit = "ng/kg/day"
)

result <- pbpk_forward(
  chemical = "PFBS",
  events = events,
  times = seq(0, 24 * 28, by = 24),
  method = "deterministic",
  age = 30,
  bw = 70,
  sex = "male"
)

trajectory <- result$results$trajectories$deterministic

plot(
  trajectory$time / 24,
  trajectory$C_pls_ven,
  type = "l",
  xlab = "Time (days)",
  ylab = "Venous plasma PFBS (ng/mL)"
)

result$exposure_events$applied
result$run_record
```

The example specifies continuous oral intake of 37.5 ng/kg/day. For a 70 kg individual, that corresponds to 0.109375 micrograms per hour.

## Documentation

| Resource | Description |
|---|---|
| [Getting Started](docs/01_Getting_Started.md) | Installation, setup and first simulation |
| [User Guide](docs/02_User_Guide.md) | Scientific workflows and interpretation |
| [Function Reference](docs/03_Function_Reference.md) | The 13 public functions |
| [PFBS Model](docs/04_PFBS_Model.md) | Model scope, structure and evaluation |
| [Reproducibility](docs/05_Reproducibility.md) | Run records, assumptions and uncertainty |
| [Troubleshooting](docs/06_Troubleshooting.md) | Common installation and simulation problems |
| [Release Checklist](docs/07_Release_Checklist.md) | Requirements for public distribution |
| [Service Access and Privacy](docs/08_Service_Access_and_Privacy.md) | Public-client and private-engine boundaries |

## Examples

- [Explore the PFBS model](examples/01_Explore_PFBS.R)
- [Forward dosimetry](examples/02_Forward_Dosimetry.R)
- [Exposure reconstruction](examples/03_Exposure_Reconstruction.R)
- [Sensitivity and uncertainty](examples/04_Sensitivity_Uncertainty.R)
