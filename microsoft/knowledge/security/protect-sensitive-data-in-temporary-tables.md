---
bc-version: [all]
domain: security
keywords: [temporary-table, data-protection, permission, cleanup]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Protect sensitive data in temporary tables

## Description

A temporary record holds data in session memory; reading the copy does not re-run authorization against its original persistent source. Ordinary source-table reads still enforce the caller's effective permissions before the copy is made. Copying such rows into a local temporary buffer does not itself bypass that check. The risk arises when elevated retrieval or a retained buffer delivers sensitive data to a caller outside the authorized scope.

## Best Practice

Trace the source read, effective permissions, buffer lifetime and recipient. A normal `Get` or `FindSet` under the caller's permissions can supply the authorization; do not require a redundant explicit `ReadPermission()` check solely because its result is copied to a local temporary table. When retrieval is elevated or a buffer is handed to another caller, preserve the operation's authorization and data scope rather than assuming the copy enforces them. Prefer local buffers for local work. For retained buffers, bound their lifetime and prevent reuse outside the authorized scope; for intentional output buffers, retain the authorized result until the caller consumes it rather than unconditionally deleting it on return.

See sample: [`protect-sensitive-data-in-temporary-tables.good.al`](protect-sensitive-data-in-temporary-tables.good.al).

## Anti Pattern

Returning elevated or previously authorized data from a temporary cache through a path that bypasses the caller check used by the normal retrieval path. A global or output buffer is not automatically a violation: identify the unauthorized recipient, missing scope check or stale sensitive data path. Missing an explicit check before an ordinary permission-enforced read into a local buffer is not that evidence.

See sample: [`protect-sensitive-data-in-temporary-tables.bad.al`](protect-sensitive-data-in-temporary-tables.bad.al).

## References

[Permissions property](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-permissions-property) explains that objects without extra permissions use the user's permissions; [temporary tables](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-temporary-tables) describes their in-memory lifetime.
