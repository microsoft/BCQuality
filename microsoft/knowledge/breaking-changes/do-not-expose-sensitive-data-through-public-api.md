---
bc-version: [23..]
domain: breaking-changes
keywords: [sensitive-data, secrettext, token, credential, public-api, access-boundary]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not widen access to expose sensitive data through a public API

## Description

A public API that discloses an extension-owned credential to an unauthorized caller creates both a security problem and a lasting compatibility commitment. Examples include an unrestricted stored-token getter, a broadcast event carrying a secret, or an externally readable variable holding a key. A `SecretText` return type alone does not establish such a disclosure: a caller may supply its own credential to an authentication object and receive a protected authorization header for that same credential. Establish the source, intended recipient and protection of the value before alleging widened access.

## Best Practice

Keep extension-owned secrets encapsulated and authorize any operation that uses or releases them. Accepting a caller's credential inward as `SecretText`, or returning a `SecretText` transformation of that caller-owned value, is not by itself a leak. Keep that path secret-preserving; do not convert it to plain text or deliver it to unrelated subscribers or callers. Microsoft's public `Http Authentication Basic` illustrates this boundary: callers initialize it with credentials and receive authorization headers containing `SecretText`. For consumers that do not own or have authority to receive a stored secret, expose an intent-specific operation or non-sensitive result instead. Access modifiers narrow the supported API, but do not replace runtime authorization.

See sample: [`do-not-expose-sensitive-data-through-public-api.good.al`](do-not-expose-sensitive-data-through-public-api.good.al).

## Anti Pattern

An unrestricted public getter reads an extension-owned credential from storage and returns it to arbitrary dependent apps, or an event broadcasts it beyond its intended recipients. Keeping the returned value in `SecretText` does not authorize that transfer: recipients can still use it for authentication. Conversely, do not flag a caller-owned, secret-preserving conversion solely because its parameter or return type is `SecretText`.

See sample: [`do-not-expose-sensitive-data-through-public-api.bad.al`](do-not-expose-sensitive-data-through-public-api.bad.al).

## References

[Http Authentication Basic](https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/codeunit/system.restclient.http-authentication-basic) exposes public initialization and `GetAuthorizationHeaders(): Dictionary of [Text, SecretText]`.
