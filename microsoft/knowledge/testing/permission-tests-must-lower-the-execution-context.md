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

A permission set can also be wrong in the other direction: it grants too little, for example a missing `tabledata` line or a missing insert right. A test that never lowers the context cannot see that, because it never runs the set. When a change adds or modifies a `permissionset` or `permissionsetextension`, add or update a test that lowers the context to that set (or to a set or role that includes it), runs an operation the set is meant to allow, and asserts the result of that operation within what the set grants. Removing a grant the operation needs from the set must make that test fail with a permission error. `"Permissions Mock".Set` assigns the set together with execute rights on all objects, so the test exercises the set's data permissions.

See sample: [`permission-tests-must-lower-the-execution-context.good.al`](permission-tests-must-lower-the-execution-context.good.al).

## Anti Pattern

Setting `TestPermissions = Disabled` or leaving the effective D365 Full Access context in place while asserting that a limited user is denied, or adding a `[TestPermissions(...)]` attribute without any runner/test-library code that applies the intended permission set. Changing a `permissionset` or `permissionsetextension` while no test, in the change or already in the test app, runs an allowed operation in a context lowered to it is the same gap from the other side. The gap is the missing coverage, not a missing test edit: when an existing test already lowers the context to the changed set (or to a set or role that includes it) and runs the operation the change is about, the change needs no new test. Do not report the mirror image: a test that lowers the context through a role including the permission set under test, and then asserts the boundary, has exercised that permission set and is not a coverage gap.

The sample shows the permission-set side: the change grants Insert so that users can run a setup action, and nothing runs that action under the set.

See sample: [`permission-tests-must-lower-the-execution-context.bad.al`](permission-tests-must-lower-the-execution-context.bad.al).
