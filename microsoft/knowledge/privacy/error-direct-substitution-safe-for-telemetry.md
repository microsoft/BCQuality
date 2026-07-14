---
bc-version: [20..]
domain: privacy
keywords: [error, strsubstno, direct-substitution, telemetry, classification, label]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use a Label or TextConst for the Error telemetry message

## Description

For Error method trace telemetry, the platform includes the AL error string only when `Error` receives a `Label` or `TextConst` as its first argument. Substitution values format the client message, but the static label supplies the telemetry message and preserves its classification context. A string literal, local `Text`, `StrSubstNo` result, or concatenation is not equivalent: telemetry substitutes generic guidance instead of that dynamic string.

## Best Practice

Define the complete error template as a `Label` with placeholder comments, pass the label directly as the first argument, and pass values separately. Independently review whether those values are appropriate to show to the current user.

See sample: `error-direct-substitution-safe-for-telemetry.good.al`.

## Anti Pattern

Assuming that any direct format string is telemetry-safe, or that a `StrSubstNo`/concatenated first argument is logged verbatim. The required telemetry shape is specifically a directly supplied `Label` or `TextConst`; see `avoid-strsubstno-prebuild-before-error.md`.
