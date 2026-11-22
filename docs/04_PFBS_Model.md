# PFBS Model: Scientific Scope and Interpretation

## Chemical scope

Perfluorobutanesulfonic acid (PFBS) is a short-chain perfluoroalkyl sulfonic acid. The current INTEGRA release contains a human PFBS physiologically based pharmacokinetic model.

Version 0.6.0 registers PFBS as the available chemical.

## Model representation

The implementation includes 60 dynamic state variables and 67 auxiliary model outputs, covering systemic circulation, tissue distribution, exposure uptake and elimination.

Important represented mechanisms include:

- Oral and gastrointestinal uptake.
- Pulmonary and dermal exposure pathways.
- Circulation between arterial and venous blood and organs.
- Distribution into red blood cells, tissue interstitial compartments and tissue cellular compartments.
- Plasma binding and tissue partitioning.
- Renal filtration and net urinary elimination.
- Hepatic transport, biliary secretion and gastrointestinal return.

The model includes mechanistic compartments and transport processes rather than relying exclusively on a one-compartment response factor.

The registered model, the annotated equations and the compartment diagram can be inspected through the public R interface.

## Exposure pathways and units

For native model events, oral and inhalation input rates are expressed in micrograms per hour, and relevant mass states are expressed in micrograms.

`pbpk_forward()` also supports explicitly labelled ng, ug and mg input units, including appropriate body-weight-normalized and time-normalized forms.

Simulation time is expressed in hours. Venous plasma concentration is available as `C_pls_ven` in ng/mL.

## Reference physiological assumptions

The default reference age is 30 years and the default body weight is 70 kg when not otherwise provided. Sex-dependent physiological values and effective organ flows and volumes depend on the selected individual profile.

Individual demographic inputs and overrides should be documented with every reported numerical prediction.

## Calibration: Xu

The Xu study provides the calibration basis for the PFBS parameterization.

The package supports retrieval of calibration results, deterministic replay, and replay of draws associated with the calibrated Bayesian parameter distribution.

Serum and urine observations have different roles in model assessment. Quantified observations and censored or upper-bound observations should be evaluated according to their measurement status and reporting limits.

The calibrated parameterization should not be described as equally constrained across every distributional tail or every endpoint.

## Conditional evaluation: Olsen

The Olsen study is included as a conditional evaluation using study-specific baseline and protocol information.

It is an external study comparison, but it should not be described as an unconditioned prediction in which all initial or subject-specific information is unknown to the model.

This distinction matters when interpreting calibration independence, predictive validity and possible sources of disagreement.

## Uncertainty and sensitivity

The package distinguishes parameter sensitivity from predictive uncertainty.

Local, Morris and Sobol methods evaluate parameter influence under specified model scenarios and design assumptions.

Posterior uncertainty reflects uncertainty in calibrated toxicokinetic parameters. Crossed calculations also investigate variability from physiological dimensions, according to the supported numerical design.

Uncertainty intervals describe model-based predictive distributions. They are not automatically equivalent to empirical population percentiles or measurement confidence intervals.

## Exposure reconstruction

Reverse dosimetry estimates the continuous oral exposure consistent with a specified serum concentration and exposure history.

The calculation uses the full PBPK model. Estimated intake is returned in micrograms per kilogram body weight per day.

The result is conditional on exposure duration, input serum level, physiological assumptions, chemical parameterization and the selected uncertainty method.

An estimated intake must not be described as a directly observed environmental exposure value.

## Reproducibility and model transparency

The public package allows model equations, parameters, compartment diagrams and output variables to be examined.

The original numerical implementation and private source code are retained by the service operator. The public functions do not distribute the native solver source.

Scientific interpretation must distinguish accessible model descriptions from access to implementation source.

## Scientific reporting

Publications using the package should identify:

- INTEGRA-PBPK-Engine version.
- Chemical and model revision.
- Parameter revision and calibration selection.
- Physiological assumptions.
- Exposure route, units and duration.
- Deterministic or probabilistic methodology.
- Number of draws and random seed, where applicable.
- Modeled endpoint and its units.
- Relevant calibration or evaluation evidence.
- Interpretation limits of conditional evaluations and inverse estimates.

Use the available software citation metadata together with appropriate scientific references for the underlying studies.
