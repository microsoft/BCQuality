---
bc-version: [all]
domain: security
keywords: [keyvault, azure, secrets, rotation, audit]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer Azure Key Vault for production secrets

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

Azure Key Vault is an external secret store that supports central management, rotation, and access auditing. The Business Central system application exposes integration APIs that retrieve Key Vault secrets at runtime. IsolatedStorage, by contrast, is a per-tenant local encrypted store with no central rotation or audit story.

## Best Practice

For production workloads that require secret rotation, access auditing, and separation between secret custodians and app developers, Azure Key Vault SHOULD be the store of record. Retrieve secrets into a SecretText variable on demand, cache only as long as the call requires, and never persist the retrieved plaintext anywhere the extension does not control. IsolatedStorage MAY be used when a per-tenant local encrypted store is all that is required.

## Anti Pattern

Treating IsolatedStorage as the long-term home for secrets in a multi-tenant production extension where secret rotation, central revocation, or access auditing are required.

