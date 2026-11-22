# Release Checklist — 0.6.0

## Public package structure

- [ ] `DESCRIPTION` identifies `IntegraPBPKengine` version 0.6.0.
- [ ] `NAMESPACE` exports the agreed 13 functions.
- [ ] Public `R/` files contain only client-side code.
- [ ] `man/` contains the function help files.
- [ ] The README, manuals and examples are present.
- [ ] `devtools::install_local()` succeeds from the repository root.
- [ ] `devtools::install_github()` succeeds after pushing and tagging the release.

## Confidentiality

- [ ] No private model R or C source appears in the repository.
- [ ] No compiled private model DLL is included.
- [ ] No `IntegraPBPKcore`, private service or owner build kit is included.
- [ ] No private calibration or study-data archive is included.
- [ ] No personal, confidential or sensitive dataset is included.
- [ ] Git staging and commit contents have been reviewed.
- [ ] No historical commit contains private source.
- [ ] The public interface exposes only the intended model information.

## Scientific verification

- [ ] The 13 public-function checks pass.
- [ ] All 26 PFBS scientific reference checks pass.
- [ ] Dose-unit conversion and native-unit equivalence tests pass.
- [ ] Default and explicit demographic assumptions are distinguishable.
- [ ] Archived versus recomputed analysis plots are verified.
- [ ] Forward simulation and reverse-dosimetry replay checks pass.
- [ ] The tested model and parameter revisions are recorded.

## Documentation

- [ ] Every public function is documented.
- [ ] Examples have been tested with a compatible service.
- [ ] Input and output units are explicit.
- [ ] Xu calibration is described accurately.
- [ ] Olsen evaluation is described as conditional.
- [ ] Predictive uncertainty is distinguished from measured population variability.
- [ ] Synthetic examples are not presented as measured HBM observations.
- [ ] Model limitations and interpretation requirements are stated.

## Service availability

- [ ] A supported service endpoint has been deployed.
- [ ] The client connection instructions have been independently tested.
- [ ] Authentication, if required, is documented without disclosing secrets.
- [ ] Request limits, uptime expectations and maintenance arrangements are documented.
- [ ] The public README accurately describes available functionality.
- [ ] If no public service exists, the release is labelled as a service-dependent client.

## Publishing

- [ ] Software author and contributor metadata have been verified.
- [ ] Software license and copyright information have been reviewed.
- [ ] `CITATION.cff` metadata are accurate.
- [ ] No DOI has been claimed unless actually assigned.
- [ ] The public repository URL is correct.
- [ ] The `v0.6.0` tag points to the tested release.
- [ ] The package can be installed from a fresh R library.
- [ ] A final confidentiality review has been performed before the first public push.

Do not publish the release until the applicable confidentiality and installation checks are complete.
