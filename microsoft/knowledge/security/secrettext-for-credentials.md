---
bc-version: [23..]
domain: security
keywords: [secrettext, credentials, api-key, token, debugger, unwrap]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use SecretText for credentials, API keys, and tokens

## Description

`SecretText` is the AL data type for values that should never appear in a debugger session, in a log, or in a variable watch. The compiler rejects direct string-literal assignment and implicit conversion back to `Text` or `Code`, but permits `Text` and `Code` values to become `SecretText`. A helper returning a literal as `Text` can therefore feed a `SecretText` destination: the destination type does not prove the value's source. That conversion is not itself a vulnerability. Use `SecretText` for parameters, return values, and local variables that carry actual API keys, tokens, passwords, connection strings, or other sensitive credentials.

## Best Practice

Declare credential-carrying parameters and variables as `SecretText` from retrieval to consumption (typically an HTTP header or URI). When a retrieval API requires `Text`, keep that temporary value and its conversion inside a `[NonDebuggable]` procedure returning `SecretText`; do not convert the protected value back to `Text` during transit. On BC 24 and later, use the `SecretText` overload of `IsolatedStorage.Get` when retrieving stored secrets. See sample: [`secrettext-for-credentials.good.al`](secrettext-for-credentials.good.al).

## Anti Pattern

Holding an actual credential in unprotected `Text` or `Code` transit makes it visible in the debugger and in any error that prints it. Establish its sensitivity and use rather than inferring them from a name such as `Token` or from a fixed string alone. Non-secret identifiers and synthetic test values are not evidence of exposed production secrets. A protected retrieval conversion is not an unprotected transit defect. When the same value is visibly sent through an HTTP URI, header, or body, `secrettext-with-httpclient.md` is the more specific primary rule. See sample: [`secrettext-for-credentials.bad.al`](secrettext-for-credentials.bad.al).

Reference: [SecretText](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-secret-text).
