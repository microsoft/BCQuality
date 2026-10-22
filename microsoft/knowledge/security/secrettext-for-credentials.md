---
bc-version: [23..]
domain: security
keywords: [secrettext, credentials, api-key, token, debugger, unwrap, hardcoded, retrieval]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use SecretText for credentials, API keys, and tokens

## Description

`SecretText` protects sensitive values from the AL debugger. The compiler rejects a direct literal assignment to `SecretText` and implicit conversion back to `Text` or `Code`, but permits `Text` and `Code` values to become `SecretText`. Consequently, a helper that returns a source literal as `Text` can still feed a `SecretText` destination: the destination type does not prove that the credential was retrieved safely or remove it from source.

## Best Practice

Declare credential-carrying parameters, return values, and variables as `SecretText` from retrieval to consumption. When reviewing a credential flow, inspect a visible retrieval helper as well as its destination type. An authentication path that returns a fixed source literal instead of retrieving the configured credential needs a source-level fix: retrieve the value from the appropriate secure store or authentication provider. Changing only the receiving variable to `SecretText` does not fix that path.

On BC 24 and later, use the `SecretText` overload of `IsolatedStorage.Get` for stored secrets. If a retrieval API requires `Text`, keep that temporary value and its conversion inside a `[NonDebuggable]` procedure returning `SecretText`; do not round-trip back to `Text` during transit. A protected retrieval boundary is valid, not evidence of a plaintext-transit defect.

Establish that the value is used as a credential, not merely that its name contains `Token`, `Key`, or `Password`. Non-secret identifiers, empty sentinels, and fake credentials confined to tests or mocks are not leaked production secrets. A placeholder returned on a real authentication path can be a configuration/implementation problem, but its spelling alone does not prove disclosure or justify claiming that a live secret needs rotation.

See sample: [`secrettext-for-credentials.good.al`](secrettext-for-credentials.good.al).

## Anti Pattern

A fixed authentication value passes through a `Text` helper into a `SecretText` variable, and the proposed fix treats the protected destination or `[NonDebuggable]` attribute as sufficient. Neither corrects the fixed source. Identify that source and its use in authentication; distinguish an embedded real secret from a placeholder implementation instead of claiming that every fixed value is a leaked credential.

Unprotected `Text` or `Code` transit of an actual credential also exposes it to the debugger. When reporting that same transit defect at an HTTP URI, header, or body, `secrettext-with-httpclient.md` is the more specific primary rule; it does not replace checking a visible credential source.

See sample: [`secrettext-for-credentials.bad.al`](secrettext-for-credentials.bad.al).

## References

- [SecretText: retrieval, transit, and consumption](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-secret-text)
