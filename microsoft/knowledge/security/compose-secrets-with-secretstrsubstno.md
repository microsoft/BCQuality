---
bc-version: [all]
domain: security
keywords: [secretstrsubstno, secrettext, composition]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Compose secrets with SecretStrSubstNo

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

SecretStrSubstNo is the SecretText analogue of StrSubstNo. The template is a regular string literal; substitution arguments may be SecretText; the return value is SecretText. Intermediate results of the composition are never materialized as plaintext.

## Best Practice

Format SecretText templates with SecretStrSubstNo. This is the correct primitive for building authorization headers, secret URIs, and any other formatted string that embeds a SecretText. Provide the static parts of the template as a regular string literal; only the substitutions carry the secret value.

See sample: `compose-secrets-with-secretstrsubstno.good.al`.

## Anti Pattern

Using StrSubstNo (or plain string concatenation) on a plain-Text token to build an authorization header. The result is a Text containing the secret in plaintext, visible in the debugger, inspectable in snapshot debug sessions, and captured by any logging the caller does not control. SecretText should have been used end-to-end.

See sample: `compose-secrets-with-secretstrsubstno.bad.al`.

