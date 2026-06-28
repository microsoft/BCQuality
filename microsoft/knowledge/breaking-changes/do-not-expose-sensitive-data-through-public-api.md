---
bc-version: [all]
domain: breaking-changes
keywords: [sensitive-data, secrettext, token, credential, public-api, access-boundary]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not widen access to expose sensitive data through a public API

## Description

Every member you make publicly reachable becomes a contract you must keep — and when that member returns a secret, the contract leaks the secret. Widening access to a credential happens in several shapes: a public getter that returns a raw token or password, an event whose parameter carries a secret to every subscriber, or a global variable holding a key that an extension can read. Once such a surface ships, removing it is itself a breaking change, so the exposure is hard to walk back. Sensitive material — tokens, passwords, connection secrets, `SecretText` values, security internals — must stay inside `internal` or `local` members. Public surfaces should expose only non-sensitive business data. LLMs often add a convenient `GetToken()` getter without recognizing it as a permanent security boundary breach.

## Best Practice

Keep secrets in `internal` or `local` members, and prefer the `SecretText` type so the value cannot be read back or logged. Where callers genuinely need a credential, pass it inward (a setter) rather than handing it outward (a getter). Public API should return only non-sensitive data — a masked reference, a status, a business identifier — never the raw secret. Treat each public member as a lasting commitment and keep the security-sensitive surface as small as possible.

See sample: `do-not-expose-sensitive-data-through-public-api.good.al`.

## Anti Pattern

A public `GetAccessToken()` that returns the raw token (or an event parameter carrying a credential to all subscribers), turning a secret into a de-facto public API any dependent can consume. Detection: a non-`local` procedure, event parameter, or global variable that surfaces a token, password, key, or other credential. Keep the secret internal and expose only non-sensitive data.

See sample: `do-not-expose-sensitive-data-through-public-api.bad.al`.
