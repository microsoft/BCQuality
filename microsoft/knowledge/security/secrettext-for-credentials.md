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

`SecretText` is the AL data type for values that should never appear in a debugger session, in a log, or in a variable watch. The compiler enforces two guarantees: a string literal cannot be assigned directly to a `SecretText` variable, and a `SecretText` cannot be assigned back to a `Text` or `Code` without an explicit `Unwrap` call. Together these prevent the two common accidents — embedding a secret in source code, and quietly converting a secret to plain text where the debugger can read it. Use `SecretText` for parameters, return values, and local variables that carry API keys, tokens, passwords, connection strings, or any other value an attacker with debugger access should not see.

## Best Practice

Declare credential-carrying parameters and variables as `SecretText` from the call site that retrieves the secret all the way to the call site that consumes it (typically an HTTP header or URI). Never round-trip through `Text`. On BC 24 and later, use the `SecretText` overload of `IsolatedStorage.Get` when retrieving stored secrets. See sample: `secrettext-for-credentials.good.al`.

## Anti Pattern

Holding a credential in a `Text` variable (`BearerToken: Text`), concatenating it into a header, then passing it to `HttpClient`. The token is visible in the debugger and in any error that prints the variable, and the compiler offers no help because the type was wrong from the start. Reviewers should flag any local or parameter named like a secret (`ApiKey`, `Token`, `Password`, `ClientSecret`) whose type is `Text` or `Code`. See sample: `secrettext-for-credentials.bad.al`.
