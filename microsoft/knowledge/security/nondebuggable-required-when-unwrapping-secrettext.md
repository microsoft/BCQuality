---
bc-version: [23..]
domain: security
keywords: [nondebuggable, attribute, secrettext, unwrap, debugger]
technologies: [al]
countries: [w1]
application-area: [all]
---

# On-premises only: protect unavoidable SecretText.Unwrap calls

## Description

`SecretText.Unwrap()` is supported only for Business Central on-premises and exists for compatibility. It converts a protected value to plain `Text`, where debugger redaction no longer applies. `[NonDebuggable]` prevents the debugger from inspecting a procedure's parameters and locals, but it does not make the resulting `Text` safe to return, log, or pass through debuggable code.

## Best Practice

In SaaS, keep the value as `SecretText` and use secret-aware APIs instead of unwrapping. For an unavoidable on-premises legacy API that accepts only `Text`, keep the plain-text path as short as possible and mark every procedure in that path `[NonDebuggable]`. Do not return the unwrapped value. See sample: `nondebuggable-required-when-unwrapping-secrettext.good.al`.

## Anti Pattern

Calling `Unwrap()` in cloud-targeted code, or calling it in an on-premises procedure that is debuggable or returns the resulting `Text`. Both defeat the protection that `SecretText` provides. See sample: `nondebuggable-required-when-unwrapping-secrettext.bad.al`.
