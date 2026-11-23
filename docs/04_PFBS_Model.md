# PFBS Model

PFBS is the first chemical supported by INTEGRA-PBPK-Engine, introduced in version 0.6.1.

This page provides a brief guide to accessing PFBS model information through the package.

## Model information

```r
library(IntegraPBPKengine)

pbpk_models(chemical = "PFBS")

parameters <- pbpk_chemical_parameters(chemical = "PFBS")

physiology <- pbpk_physiology(chemical = "PFBS")

studies <- pbpk_studies(chemical = "PFBS")
```

## Equations and diagram

```r
equations <- pbpk_equations(
  chemical = "PFBS",
  file = tempfile(fileext = ".pdf"),
  overwrite = TRUE
)

diagram <- pbpk_mermaid(
  chemical = "PFBS",
  plot = FALSE
)
```

## Model applications

The package supports forward dosimetry, exposure reconstruction, calibration and evaluation results, sensitivity analysis, and uncertainty analysis for PFBS.

For examples, see the [User Guide](02_User_Guide.md) and the repository's `examples/` directory.

Detailed model structure, parameterization, calibration, evaluation, and scientific interpretation are addressed in the corresponding model publications.
