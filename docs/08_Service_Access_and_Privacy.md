# Service Connection and Data Handling

## Connection

INTEGRA model calculations require a compatible computation service.

Configure the service URL and access token using the connection information supplied for your installation.

```r
options(IntegraPBPKengine.url = Sys.getenv("INTEGRA_PBPK_URL"))
options(IntegraPBPKengine.token = Sys.getenv("INTEGRA_PBPK_TOKEN"))
```

Remote service connections require HTTPS.

## Data handling

Model inputs are transmitted to the configured service for processing.

When using human biomonitoring data, submit only the fields needed for the analysis. Avoid including names, personal identifiers, or other unnecessary sensitive information.

Users should follow applicable research ethics, confidentiality requirements, and data-protection procedures.

## Results

INTEGRA returns model predictions, numerical results, and relevant run metadata to R.

Results can be inspected, analyzed, and saved locally using standard R functions.

## Support

When reporting software issues, provide the package version, operation, error message, and an anonymized example where possible.

Do not publish credentials or identifiable HBM records in GitHub issues.
