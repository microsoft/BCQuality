---
bc-version: [26..28]
domain: security
keywords: [error, disclosure, logging, label]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Avoid sensitive data in error messages

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

Errors surfaced to end users are routinely forwarded to support systems, captured in bug reports, and exported to telemetry. Server names, database names, usernames, connection strings, file paths, and stack excerpts in an end-user error message leak infrastructure detail to untrusted consumers and help an attacker map the environment.

## Best Practice

Raise end-user errors using localized Labels that describe the condition without naming infrastructure. Emit the actual detail (exception text, endpoint, correlation id) through the application's internal logging channel, where audience and retention are controlled.

See sample: `samples/security/avoid-sensitive-data-in-error-messages/good.al`.

## Anti Pattern

Error('Failed to connect to Server=PROD-SQL01;Database=NAV;User=admin: %1', Ex.Message); — every support ticket now carries the server name, database name, and service account.

See sample: `samples/security/avoid-sensitive-data-in-error-messages/bad.al`.

