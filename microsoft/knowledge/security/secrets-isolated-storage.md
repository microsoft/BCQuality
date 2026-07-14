---
bc-version: [all]
domain: security
keywords: [isolatedstorage, secrets, api-key, oauth-token, connection-string, table-field, credentials]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A secret belongs in IsolatedStorage, never in a table field

## Description

API keys, OAuth tokens, client secrets, and connection strings must not be stored in an ordinary table `Text` field — not even on a hidden setup table. A regular field is exposed through record reads, page display, RapidStart and Excel export, report datasets, and surfaces in `DataClassification` review; anyone with table permission can read it. The correct home is `IsolatedStorage`, which is invisible to database queries, API pages, and configuration packages. The storage-*location* decision is the rule here; how to scope and encrypt the value once it is in IsolatedStorage is covered separately.

## Best Practice

Persist every credential in `IsolatedStorage`, write it at the point of capture, and read it only when needed. Prefer `SetEncrypted` when the value fits its documented length limit. On BC24 and later, carry the value through the `SecretText` overloads; on earlier releases, keep any required `Text` handling inside a `[NonDebuggable]` boundary. Choose the `DataScope` that matches the credential's lifetime. See `isolatedstorage-datascope-module-vs-company`, `isolatedstorage-setencrypted-for-sensitive-values`, and `secrettext-for-credentials` for those separate concerns.

## Anti Pattern

A "Setup" or "Connection" table carrying a `Text` field named `API Key`, `Password`, or `Client Secret`. The value is now readable by any object with table permission, ships in RapidStart packages and Excel exports, and appears in record snapshots — a credential disclosure that no amount of encryption-in-transit elsewhere makes up for. Reviewer signal: a secret-shaped field declared on a table instead of an `IsolatedStorage` call.
