---
bc-version: [26..28]
domain: security
keywords: [https, httpclient, tls, plaintext]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Require HTTPS for external calls

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

HttpClient can issue requests over plaintext HTTP as easily as over HTTPS. A request sent over http:// is transmitted unencrypted, exposing the full URL (including query string), the request headers (including Authorization), and the bodies of both request and response to any on-path observer. This holds even when the payload itself is not marked sensitive — request signatures and session tokens are routinely captured and replayed.

## Best Practice

Call external services exclusively over https://. When the destination is configurable, validate at runtime that the scheme is https before issuing the request, and fail closed with a clear (non-disclosing) error otherwise.

See sample: `samples/security/require-https-for-external-calls/good.al`.

## Anti Pattern

Issuing HttpClient.Get('http://...'), or accepting an arbitrary user-supplied URL and passing it straight to HttpClient without scheme validation.

See sample: `samples/security/require-https-for-external-calls/bad.al`.

