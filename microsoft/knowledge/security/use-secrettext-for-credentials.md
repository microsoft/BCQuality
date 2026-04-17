---
bc-version: [26..28]
domain: security
keywords: [secrettext, credentials, debugger, type]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use SecretText for credentials

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

SecretText is a compile-time-checked AL type for credentials, API keys, tokens, and similar sensitive values. The compiler rejects literal assignments to SecretText and blocks implicit conversion back to Text or Code, which prevents many accidental disclosures via logs, errors, and the debugger (regular and snapshot). A SecretText value remains opaque throughout its lifetime.

## Best Practice

Type every credential-carrying variable, procedure parameter, and return as SecretText. Compose values with SecretStrSubstNo (see compose-secrets-with-secretstrsubstno). For HttpClient integration, see use-secrettext-with-httpclient. When a secret must be extracted from a Text source, contain that conversion in a NonDebuggable procedure (see use-nondebuggable-when-parsing-secrets).

See sample: `use-secrettext-for-credentials.good.al`.

## Anti Pattern

Passing credentials around as Text or Code parameters. Every such variable is visible in the debugger and may be captured by error handlers, logs, and telemetry that treat Text as non-sensitive.

See sample: `use-secrettext-for-credentials.bad.al`.

