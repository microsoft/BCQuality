---
bc-version: [all]
domain: security
keywords: [access, internal, internalsvisibleto, recordref, codeunit-run, security-boundary, authorization]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Access Internal is API hygiene, not an authorization boundary

## Description

`Access = Internal` controls compile-time symbol visibility. It does not prevent runtime access through mechanisms such as `RecordRef`, `TransferFields`, or `Codeunit.Run`, and `internalsVisibleTo` deliberately grants compile-time access to named companion apps. Microsoft explicitly documents that access modifiers cannot be used as a security boundary.

## Best Practice

Use `internal` to keep implementation details out of the supported API, but enforce sensitive operations with permissions, entitlements, and explicit authorization checks appropriate to the operation. Treat `internalsVisibleTo` as a same-publisher development/testability relationship, not as a trust grant for secrets or elevated data access.

See sample: `internal-access-is-not-a-security-boundary.good.al`.

## Anti Pattern

Placing privileged work in an internal codeunit and claiming that other extensions cannot invoke it, or exposing an app to a different publisher through `internalsVisibleTo` because `internal` is assumed to protect the underlying operation. The access modifier narrows supported callers; it does not authenticate runtime callers.

See sample: `internal-access-is-not-a-security-boundary.bad.al`.
