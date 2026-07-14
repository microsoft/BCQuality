---
bc-version: [20..]
domain: privacy
keywords: [strsubstno, error, telemetry, pii, prebuild, text-variable]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pass a Label directly as the first Error argument

## Description

Error method trace telemetry includes the AL error string only when the first `Error` argument is a `Label` or `TextConst`. Wrapping a label in `StrSubstNo`, or concatenating labels or text, produces a dynamic `Text` first argument. In that case the actual string is not emitted as the telemetry message; the platform emits its generic guidance instead. CodeCop AA0231 flags both shapes because the label identity and data-classification context are lost.

## Best Practice

Declare the complete message as a `Label` or `TextConst` and pass it directly to `Error`, followed by substitution values. The client receives the formatted message while telemetry can retain the static message template without using the dynamic values as its message. See `error-direct-substitution-safe-for-telemetry.md`.

See sample: `avoid-strsubstno-prebuild-before-error.good.al`.

## Anti Pattern

`Error(StrSubstNo(CustomerInvalidErr, Customer."No."))` and `Error(HeaderErr + DetailErr)` both make the first argument dynamic. They reduce error telemetry quality; they do not cause that composed string to be logged verbatim as the telemetry message.

See sample: `avoid-strsubstno-prebuild-before-error.bad.al`.
