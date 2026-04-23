---
bc-version: [all]
domain: security
keywords: [secrets, credentials, hardcoded, label, apikey]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Never hardcode secrets in AL

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

A secret embedded in AL source — API key, password, connection string, token — lives forever: in the app package, in source control history, in every debugger session that sees the assignment, and in any log that captures the containing variable. Rotation is effectively impossible without a new release, and the blast radius covers every tenant the extension is installed in.

## Best Practice

Retrieve secrets at runtime from a protected store: Azure Key Vault for production workloads (see prefer-azure-key-vault-for-production-secrets) or IsolatedStorage for tenant-local encrypted values (see use-isolated-storage-for-module-and-company-secrets). Carry the retrieved value in a SecretText variable end-to-end (see use-secrettext-for-credentials).

See sample: `never-hardcode-secrets-in-al.good.al`.

## Anti Pattern

Assigning a secret literal to a Text, Code, or Label variable (including labels marked as constants). The secret is now part of the compiled app and indistinguishable from non-sensitive content to callers and tools.

See sample: `never-hardcode-secrets-in-al.bad.al`.

