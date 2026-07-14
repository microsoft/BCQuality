---
bc-version: [14..]
domain: privacy
keywords: [errorinfo, errorinfo-message, errorinfo-dataclassification, errorinfo-errortype, errorinfo-detailedmessage, copy-details, telemetry]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Review each ErrorInfo text surface by its actual exposure

## Description

Runtime 3.0 (BC 14) provides `ErrorInfo.Message`, `DataClassification`, and `ErrorType`. `Message` is sent to telemetry; with `ErrorType::Client` it is also the primary client message, while `ErrorType::Internal` replaces it in the client with a generic message but still sends the specified text to telemetry. `DataClassification` classifies the content in `Message`; it does not make incorrectly classified personal data safe. Runtime 8.0 (BC 19) adds `DetailedMessage`, which is omitted from the primary message but included in the error dialog's **Copy details** content.

## Best Practice

Keep `Message` stable and classify its actual content. Choose `ErrorType` for client usability, not as a telemetry privacy boundary. On BC 19 and later, put only support-safe technical context in `DetailedMessage`, because a user can copy it from the dialog. The samples use only members available at the BC 14 article floor.

See sample: `errorinfo-telemetry-classification-and-errortype.good.al`.

## Anti Pattern

Marking a dynamic customer-bearing `Message` as `SystemMetadata`, or assuming `ErrorType::Internal` keeps it out of telemetry. On BC 19 and later, the same anti-pattern includes placing secrets or personal data in `DetailedMessage` because it is not the primary dialog text.

See sample: `errorinfo-telemetry-classification-and-errortype.bad.al`.
