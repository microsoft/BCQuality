---
bc-version: [23..]
domain: security
keywords: [secretstrsubstno, secrettext, strsubstno, format, compose]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use SecretStrSubstNo to compose strings that contain secrets

## Description

`SecretStrSubstNo` is the secret-preserving counterpart of `StrSubstNo`. It inserts `SecretText` arguments into `%1`, `%2`, and similar placeholders and returns `SecretText` without materializing the result as plain text. It is the right tool for values such as a `Token %1` authorization header or a URI with an API key placeholder.

## Best Practice

Compose every secret-bearing string through `SecretStrSubstNo`, ensure the format contains a placeholder for each secret, and keep the result as `SecretText`. Pass it to `HttpRequestMessage.SetSecretRequestUri`, `HttpHeaders.Add`, or `HttpContent.WriteFrom`. See sample: `secretstrsubstno-for-composing-secrets.good.al`.

## Anti Pattern

Keeping a credential in `Text` and inserting it with `StrSubstNo`, or calling `SecretStrSubstNo` with a format that has no placeholder for the secret. The first exposes the value as plain text; the second silently omits it. See sample: `secretstrsubstno-for-composing-secrets.bad.al`.
