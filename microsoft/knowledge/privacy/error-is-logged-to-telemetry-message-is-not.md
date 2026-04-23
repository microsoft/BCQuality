---
bc-version: [all]
domain: privacy
keywords: [error, message, confirm, notification, telemetry, pii]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Error logs to telemetry; Message, Confirm, and Notification do not

## Description

The privacy concern with user-facing text is not what the authenticated user sees — it is what the platform exports to telemetry. Error is captured automatically; Message, Confirm, StrMenu, and Notification are not. Reviews that flag PII in any user-facing dialog over-report. Reviews that ignore PII in Error under-report. The distinction is the delivery surface, not the presence of a person's name on screen.

## Best Practice

Free-text business content — customer names, email addresses, document numbers — is acceptable in Message, Confirm, and Notification. Treat Error text as if it will be read by telemetry consumers, because it will be. Use localized Labels with the fewest possible PII placeholders, or system identifiers (SystemId, primary key values) rather than personal data.

See sample: `error-is-logged-to-telemetry-message-is-not.good.al`.

## Anti Pattern

Embedding customer emails, phone numbers, addresses, or names directly into Error strings — either as literals or via pre-built StrSubstNo output — because "the user will see this anyway." The user also sees Message and Confirm, but those are not logged. Error is.

See sample: `error-is-logged-to-telemetry-message-is-not.bad.al`.
