---
bc-version: [all]
domain: testing
keywords: [testpermissions, restrictive, disabled, permissions-mock, lower-permissions, super, permission-test, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Permission tests must actually lower the execution context

## Description

`TestPermissions` describes how a test runner should establish the permission context; the enum value does not itself assign the business permission set being tested. `Restrictive` is the default and starts from D365 Full Access, requiring the test to lower permissions. `Disabled` leaves the test running as `SUPER`. A test that expects access to be denied while still running with either broad context can pass or fail for the wrong reason and never exercise the intended boundary.

What matters is the effective permission context at the moment the protected operation runs, not which permission set object the test names. A test may establish that context through a composed role that includes the permission set under test rather than applying that set directly — that mirrors how the permission set actually reaches a user in production, where roles are assigned and permission sets are included. Such a test is adequate when it proves the boundary it claims: for an indirect (lowercase `imd`) grant, asserting `WritePermission()` is false before invoking the mediating codeunit shows that no direct access was granted and that the subsequent write succeeded only through code.

## Best Practice

Use `TestPermissions::Restrictive` for a permission-sensitive test and lower the current test user with the test framework's `"Permissions Mock"` or `"Library - Lower Permissions"` before invoking the protected operation. Assign a permission context that actually contains the rights the scenario tests — either the permission set itself or a role that includes it — and restore or stop the mock afterward. Use `Disabled` only for suites that do not assert permission behavior, or where the test lowers the context explicitly through the test libraries instead of relying on the runner. Do not require a test to apply the permission set under test directly when it reaches the same rights through a composed role and then asserts the boundary.

For web-service/API E2E suites driven through `Library - Graph Mgt` (or an equivalent client-request wrapper), the protected page or trigger executes on the separate web-service session identity, not on the test codeunit's own session. `Permissions Mock` and `Library - Lower Permissions` only lower the test session and therefore cannot reach the `ReadPermission`/`WritePermission` gates evaluated on that other session — applying them would not exercise anything real. `TestPermissions = Disabled` with no permission lowering is correct for this pattern; do not flag it as a missing-lowered-context gap. Genuinely exercising those gates would require a restricted user authenticating on the web-service session, which is a different (and out of scope) test setup.

See sample: `permission-tests-must-lower-the-execution-context.good.al`.

## Anti Pattern

Setting `TestPermissions = Disabled` or leaving the effective D365 Full Access context in place while asserting that a limited user is denied, or adding a `[TestPermissions(...)]` attribute without any runner/test-library code that applies the intended permission set. Do not report the mirror image: a test that lowers the context through a role including the permission set under test, and then asserts the boundary, has exercised that permission set and is not a coverage gap. Also do not report a `Library - Graph Mgt` (or equivalent web-service client) E2E suite that runs `TestPermissions = Disabled` with no permission lowering — the protected operation runs on the web-service session, which the test session's mock cannot reach, so lowering the test session would be a no-op.

See sample: `permission-tests-must-lower-the-execution-context.bad.al`.
