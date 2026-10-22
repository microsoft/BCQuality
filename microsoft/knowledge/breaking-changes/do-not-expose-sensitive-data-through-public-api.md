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

Every member you make publicly reachable becomes a contract you must keep. Returning an extension-owned credential to unauthorized recipients widens access to sensitive data, even if the value remains `SecretText`. Once such a surface ships, removing it is itself a breaking change. However, a `SecretText` return type alone is not a leak: a caller can supply its own credential and receive a protected transformation of that same value. Microsoft's public `Http Authentication Basic` accepts caller credentials and returns authorization headers containing `SecretText`.

## Best Practice

Keep extension-owned secrets encapsulated and use `SecretText` to preserve their protection. Prefer intent-specific operations or non-sensitive results when callers are not authorized to receive the credential. A caller-owned transformation must preserve both the secret's protection and its authorized recipient; a parameter or return type does not by itself establish ownership. Treat each public member as a lasting commitment and keep the security-sensitive surface as small as possible. Access modifiers do not replace runtime authorization.

See sample: [`do-not-expose-sensitive-data-through-public-api.good.al`](do-not-expose-sensitive-data-through-public-api.good.al).

## Anti Pattern

A public `GetAccessToken()` exposes an extension-owned stored credential without recipient authorization, or an event forwards it to unrelated subscribers. Establish the source and recipient rather than flagging every public `SecretText` return. Caller-owned, secret-preserving transformations do not justify disclosure of another owner's secret.

See sample: [`do-not-expose-sensitive-data-through-public-api.bad.al`](do-not-expose-sensitive-data-through-public-api.bad.al).

Reference: [Http Authentication Basic](https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/codeunit/system.restclient.http-authentication-basic).
