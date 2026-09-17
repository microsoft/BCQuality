---
bc-version: [all]
domain: security
keywords: [integrationevent, var, guard, ishandled, bypass, security-check]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not expose security guards as `var` parameters on IntegrationEvent

## Description

A `var` parameter on an `[IntegrationEvent]` is a mutable hook: any subscriber can overwrite the value and the publisher will see the new value when control returns. That is the right shape for "let an extension contribute to a payload"; it is the wrong shape for "let an extension confirm a security decision". A `var HasAccess: Boolean` or `var SkipValidation: Boolean` lets any subscriber on the tenant flip the result of the publisher's permission check to `true` (or set "skip" to `true`) before the publisher reads it. The publisher's check becomes advisory, which is the same as not having a check.

## Best Practice

Keep the security decision inside the publisher, where it is not bypassable. Fire an `OnAfter*` informational event after the check completes, with the result passed by value (not `var`) so subscribers can react — log, audit, surface a warning — but cannot rewrite the outcome. When subscribers legitimately need to add their own checks, expose an `OnAfterCheckPermissions(...)` that can only tighten access (e.g., a subscriber can `Error()`), never loosen it. See sample: [`integrationevent-var-parameter-bypasses-security-guards.good.al`](integrationevent-var-parameter-bypasses-security-guards.good.al).

## Anti Pattern

`OnBeforeCheckPermissions(var HasAccess: Boolean; var SkipValidation: Boolean; TableNo: Integer)`, followed in the caller by `if SkipValidation then exit;`. Any subscriber sets `SkipValidation := true` and the check is gone. Reviewers should flag any `IntegrationEvent` whose signature contains a `var Boolean` whose name reads like a security decision (`HasAccess`, `IsAllowed`, `SkipValidation`, `BypassCheck`, `IsAuthorized`). See sample: [`integrationevent-var-parameter-bypasses-security-guards.bad.al`](integrationevent-var-parameter-bypasses-security-guards.bad.al).
