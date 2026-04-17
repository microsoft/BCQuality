---
bc-version: [26..28]
domain: security
keywords: [url, query-string, credentials, logging]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not put credentials in URLs

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

URL query strings and path segments are routinely captured in web-server access logs, browser history, proxy logs, platform telemetry, and exception traces. A credential placed anywhere in the URL therefore persists across systems the extension does not control, and is typically retained far longer than the secret's intended lifetime.

## Best Practice

Transport credentials in Authorization headers, carried as SecretText end-to-end (see use-secrettext-with-httpclient). Where the URI itself must carry a secret (for example, a pre-signed URL), build it with SecretStrSubstNo and pass it via SetSecretRequestUri so it is never materialized as Text.

See sample: `samples/security/do-not-put-credentials-in-urls/good.al`.

## Anti Pattern

Appending '?api_key=' + Key to a request URL, or embedding a token in a path segment, then calling HttpClient.Get with the resulting Text URL.

See sample: `samples/security/do-not-put-credentials-in-urls/bad.al`.

