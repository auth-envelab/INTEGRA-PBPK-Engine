# Service Access, Architecture and Privacy

## Architecture

INTEGRA-PBPK-Engine separates the public R interface from the numerical PBPK implementation.

The public package performs request preparation, transport, interpretation and presentation of returned results. The private engine performs scientific computations under the control of the service operator.

This distinction permits a stable user-facing interface without distributing the original PFBS model implementation.

## What is included publicly?

The GitHub repository includes package metadata, public R functions, documentation, plotting helpers and examples.

Anyone can read the public R client source code.

## What is not distributed?

The public release excludes private model implementation source, native solver source, private service code, internal research scripts and unpublished data assets.

These components are maintained separately by the operator.

## Scientific transparency

The public interface provides access to model parameters, equations, compartment descriptions and simulated outputs.

Consequently, the public repository does not promise that the model's scientific structure is secret. It protects the original implementation files by retaining them outside the distributed package.

## Service requirements

Scientific model requests require an available compatible service.

Version 0.6.0 documentation does not specify a universal public endpoint or authentication procedure. These must be defined by the operator before general-access numerical use is advertised.

Service installation and deployment are outside the public R package.

## HBM privacy

Human biomonitoring inputs may contain sensitive information. The public package is not a guarantee of privacy for data sent to a separately hosted service.

Before uploading real individual-level HBM information, users should understand the service operator's data processing, authentication, storage, logging and retention arrangements.

Where appropriate, de-identify inputs and follow applicable ethical and data-protection requirements.

## Reproducibility

The returned run record documents model revisions and selected execution assumptions.

Users should preserve an appropriate versioned record of their scientific inputs and outputs without adding confidential or personal information to a public repository.

## Reporting vulnerabilities

Do not post credentials, private datasets, service configuration secrets or private model source in public GitHub issues.

Contact the repository maintainers through their official security-reporting channel when available.
