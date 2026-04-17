---
bc-version: [26..28]
domain: security
keywords: [isolatedstorage, encryption, datascope, secrets]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use IsolatedStorage for module and company secrets

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

IsolatedStorage is a per-extension, per-tenant key-value store. DataScope::Module isolates values to the extension across the tenant; DataScope::Company scopes them to a single company within the tenant. The SetEncrypted method stores the value encrypted at rest; Set stores it in plaintext. SetEncrypted accepts inputs up to 215 characters (special characters may consume more space).

## Best Practice

Use IsolatedStorage.SetEncrypted to write secrets, IsolatedStorage.Contains to probe, and IsolatedStorage.Get into a SecretText destination to read. Choose DataScope::Company for per-company credentials (for example, a tenant-per-company service account) and DataScope::Module for extension-wide configuration.

See sample: `samples/security/use-isolated-storage-for-module-and-company-secrets/good.al`.

## Anti Pattern

Storing secrets in a Setup table column as plain Text, or using IsolatedStorage.Set (unencrypted) for values that authenticate the extension to an external service. Both shapes leave the secret readable by anyone with read rights on the underlying storage.

See sample: `samples/security/use-isolated-storage-for-module-and-company-secrets/bad.al`.

