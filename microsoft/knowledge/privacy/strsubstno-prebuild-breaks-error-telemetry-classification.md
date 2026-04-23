---
bc-version: [all]
domain: privacy
keywords: [strsubstno, error, telemetry, dataclassification, pii]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pre-building Error text with StrSubstNo defeats platform PII stripping

## Description

Error messages are captured by platform telemetry. When Error receives a format template and field references as substitution arguments (Error('... %1 ...', Customer."No.")), the platform inspects each field's DataClassification and omits sensitive values from telemetry automatically. When the caller pre-builds the message with StrSubstNo and then passes the resulting Text to Error, the platform sees a plain string with no field context and logs the whole thing verbatim — any PII already baked in is exported to telemetry.

## Best Practice

Pass the template and the field references directly to Error. Declare the template as a Label with a Comment describing each placeholder. The platform's field-aware classification logic then takes care of what reaches telemetry.

See sample: `strsubstno-prebuild-breaks-error-telemetry-classification.good.al`.

## Anti Pattern

Assigning the output of StrSubstNo to a Text variable and passing that variable to Error. Every substituted value is now part of an opaque string; the platform cannot classify it and logs everything.

See sample: `strsubstno-prebuild-breaks-error-telemetry-classification.bad.al`.
