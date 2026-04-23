---
bc-version: [all]
domain: security
keywords: [guid, tenant-id, aad, environment, hardcoded]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Hardcoded GUIDs are only safe for well-known system identifiers

## Description

AL code sometimes carries hardcoded GUIDs. Some are platform-defined, stable across tenants and versions, and legitimately constant — the Base Application's ApplicationId (`{437dbf0e-84ff-417a-965d-ed2bb9650972}`) is the canonical example. Others identify a specific tenant, a specific Azure Active Directory application, or a specific environment; these look identical at the source-code level but are environment-bound and break the moment the extension is deployed anywhere else. Shipping an environment-specific GUID as a constant effectively locks the extension to one environment, and the failure mode in other tenants is usually an authentication error with no code-level signal pointing at the literal.

## Best Practice

Hardcoded GUIDs are acceptable for well-known system identifiers that are stable across environments — document the identifier with a comment that names what it refers to. For tenant IDs, AAD application IDs, API subscription IDs, and any value that varies by deployment, retrieve at runtime from IsolatedStorage, configuration tables, or the platform APIs that expose the current tenant context.

See sample: `do-not-hardcode-environment-specific-guids.good.al`.

## Anti Pattern

`TenantId := '{12345678-1234-1234-1234-123456789012}';` or `AadApplicationId := '{87654321-...}';` inline in a codeunit. The extension authenticates in one environment and fails in every other; debugging starts from an AAD error message that does not mention the literal.

See sample: `do-not-hardcode-environment-specific-guids.bad.al`.
