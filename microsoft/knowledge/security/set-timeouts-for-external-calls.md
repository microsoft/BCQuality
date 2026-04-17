---
bc-version: [26..28]
domain: security
keywords: [timeout, httpclient, availability, dos]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set timeouts for external calls

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

An HttpClient with no explicit timeout relies on defaults that may be long enough for a hung or slow endpoint to block a user session or a background task for minutes. A dependency that degrades therefore degrades the caller, and an intentionally slow endpoint is a cheap denial-of-service vector against the extension.

## Best Practice

Set HttpClient.Timeout to a bounded value (seconds, not minutes) that reflects the SLA of the dependency. Handle the timeout error without leaking endpoint details to end users (see avoid-sensitive-data-in-error-messages).

See sample: `set-timeouts-for-external-calls.good.al`.

## Anti Pattern

Issuing HttpClient requests without setting Timeout and without a timeout-handling branch. A slow dependency now has an unbounded blast radius inside the extension.

See sample: `set-timeouts-for-external-calls.bad.al`.

