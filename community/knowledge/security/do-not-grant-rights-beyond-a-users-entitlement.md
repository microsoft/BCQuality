---
bc-version: [26..28]
domain: security
keywords: [entitlement, permissionset, license, clipping, sandbox-drift]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not grant rights beyond a user's entitlement

> **Seed article.** Ported from BC Code Intelligence to seed the community corpus. Community contributors are invited to expand or refine.

## Description

Entitlements are license-level caps on what a user can access, derived automatically from the BC license tier. Permission sets are application-level grants administered on top of the entitlement. A permission set can only grant within the entitlement's boundaries; grants beyond those boundaries are silently clipped at runtime. This means a permission set authored and validated in a developer sandbox (with a broad license) can appear to work correctly there and fail silently in a customer tenant where users hold a narrower entitlement.

## Best Practice

When designing a permission set that ships with an extension, consult the entitlement model for the target user population before finalizing the grants. Every object and tabledata right the set expects to grant should be reachable within the intended entitlement tier; if it is not, the set needs to be scoped to licenses that permit it, or the feature needs a different access path.

See sample: `do-not-grant-rights-beyond-a-users-entitlement.good.al`.

## Anti Pattern

Authoring permission sets in a sandbox with full-license context and shipping them without verifying which entitlement tier customer users actually hold. The sets look complete in test; on a real customer they silently lose rights at runtime and the symptom is "the feature does not work for some users" with no obvious authorization error.
