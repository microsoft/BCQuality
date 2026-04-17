---
bc-version: [26..28]
domain: security
keywords: [tryfunction, logging, audit, error]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not swallow security errors silently

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

Authentication failures, permission denials, and unexpected error paths in security-relevant code are the signals a reviewer or incident responder needs to see. A TryFunction whose failure is ignored without logging turns an attack or a misconfiguration into silent bad behaviour: the call returns false, the caller moves on, and no record of the event survives.

## Best Practice

Use TryFunctions to contain errors around security-relevant work, but always log the failure (category, GetLastErrorText, and enough context to identify the operation) before deciding whether to surface a user-facing error. Never discard a caught security error without a trace.

See sample: `do-not-swallow-security-errors-silently.good.al`.

## Anti Pattern

`if not TryAuthenticate() then exit;` with no logging and no user-facing error. An authentication-bypass attempt, a revoked credential, and a transient network glitch are now indistinguishable.

See sample: `do-not-swallow-security-errors-silently.bad.al`.

