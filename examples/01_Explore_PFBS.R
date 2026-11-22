# INTEGRA-PBPK-Engine 0.6.0
# Example 1: Explore the registered PFBS model
# Requires an accessible compatible INTEGRA numerical service.

library(IntegraPBPKengine)

chemical <- "PFBS"

models <- pbpk_models()
pfbs <- pbpk_models(chemical = chemical)

physiology <- pbpk_physiology(chemical = chemical, age = 30, bw = 70, sex = "male")
chemistry <- pbpk_chemical_parameters(chemical = chemical)

studies <- pbpk_studies(chemical = chemical)

print(models)
print(studies)
print(head(physiology))
print(head(chemistry))

# Generate public scientific model descriptions
pdf_path <- pbpk_equations(chemical = chemical, file = tempfile(fileext = ".pdf"), overwrite = TRUE)
mermaid_code <- pbpk_mermaid(chemical = chemical, plot = FALSE)

message("Annotated equations: ", pdf_path)
cat(substr(mermaid_code, 1L, 500L), "\n")
