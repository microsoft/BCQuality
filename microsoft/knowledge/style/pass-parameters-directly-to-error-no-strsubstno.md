---
bc-version: [all]
domain: style
keywords: [error, label, strsubstno, concatenation, telemetry, aa0216, aa0217]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pass Error parameters directly to the Label; do not pre-build with StrSubstNo or concatenation

## Description

`Error` accepts a Label and its substitution parameters directly (`Error(CustomerNotFoundErr, CustomerNo, DocumentNo)`). Pre-building the message via `StrSubstNo` and passing the resulting Text, or concatenating parts with `+` and passing the result, compiles but produces two distinct regressions. The localization pipeline can only translate the Label; a pre-built Text is passed through untouched, so non-English users see the English template. Platform telemetry inspects the Label's placeholder arguments for DataClassification; a pre-built Text is opaque, so PII in the arguments is logged verbatim (see `strsubstno-prebuild-breaks-error-telemetry-classification` in the privacy domain).

## Best Practice

Declare the Label with placeholders and pass arguments directly to Error: `Error(CustomerNotFoundErr, CustomerNo, DocumentNo)`. Use `Comment` on the Label to document each placeholder (see `include-comment-on-labels-with-placeholders`). `Error('')` is acceptable when the caller is responsible for the surfaced error.

See sample: `pass-parameters-directly-to-error-no-strsubstno.good.al`.

## Anti Pattern

`Error(StrSubstNo(CustomerNotFoundErr, CustomerNo))` — loses translation. `Error(CustomerNotFoundErr + ': ' + CustomerNo)` — loses translation, concatenates hard-coded delimiters. `Error('Customer ' + CustomerNo + ' not found')` — uses no Label at all.

See sample: `pass-parameters-directly-to-error-no-strsubstno.bad.al`.
