# INTEGRA-PBPK-Engine

**INTEGRA-PBPK-Engine** is an R interface for physiologically based pharmacokinetic (PBPK) modeling, supporting mechanistic dosimetry, scientific model evaluation, parameter exploration, uncertainty analysis, and exposure reconstruction.

The public R package is named **`IntegraPBPKengine`**. The GitHub repository is maintained under the **`auth-envelab`** organization.

**Version:** 0.6.0  
**Currently supported chemical:** Perfluorobutanesulfonic acid (PFBS)  
**Repository:** https://github.com/auth-envelab/INTEGRA-PBPK-Engine

## Overview

INTEGRA provides a common R interface for interacting with chemical-specific PBPK models. Its architecture separates the publicly distributed R client from the numerical model engine.

The PFBS implementation supports:

- Inspection of physiological and chemical parameterization.
- Deterministic and Bayesian forward dosimetry.
- User-defined exposure events and unit-labelled dosing.
- Calibration and conditional external-evaluation results.
- Posterior calibration-draw replay.
- Local, Morris, and Sobol sensitivity analysis.
- Posterior and crossed physiological–kinetic uncertainty analysis.
- Reconstruction of exposure from serum biomonitoring concentrations.
- Access to model equations and compartment diagrams.
- Reproducibility metadata accompanying scientific results.

The current release contains one registered chemical, PFBS. The client interface is designed to accommodate additional chemical models in future releases.

## Installation

Install from the public GitHub repository after version 0.6.0 has been released:

```r
if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
devtools::install_github("auth-envelab/INTEGRA-PBPK-Engine", ref = "v0.6.0", upgrade = "never")
library(IntegraPBPKengine)
packageVersion("IntegraPBPKengine")
```

Installation requires R and the package dependencies declared in `DESCRIPTION`.

**Important:** The installed package is an R client, not a locally distributed PBPK numerical engine. Scientific functions require access to a compatible running INTEGRA PBPK service. Installing from GitHub alone does not provide that service. No general-access public endpoint is included in this release documentation.

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

All examples require a configured compatible service for scientific requests.

## Scientific interpretation

The PFBS model is mechanistic and includes physiological compartments, tissue distribution, plasma binding, and renal and hepatobiliary disposition.

The Xu study supplies calibration evidence. Olsen is treated as a conditional evaluation, not as an entirely unconditioned external validation.

Model predictions depend on the exposure scenario, physiological assumptions, parameter selection, calibration uncertainty, and numerical settings. Predicted or reconstructed exposures should not be presented as directly measured exposure values.

## Software architecture

The public repository distributes the R client, help pages, documentation, and examples. The original PFBS model source, native solver implementation, private service, and owner-only research materials are not included.

The R client source is publicly inspectable. Model equations, parameter information, and diagrams exposed through public functions are part of the documented scientific interface.

## Citation

See Formal software citation metadata will be provided in a future release. for software citation metadata. Also cite the scientific model description and relevant underlying studies when using PFBS predictions in scientific publications.

## Availability

Release 0.6.0 is intended for public distribution of the R interface. Access to numerical services must be arranged separately by the service operator.
