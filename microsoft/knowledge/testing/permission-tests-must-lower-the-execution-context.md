---
bc-version: [all]
domain: testing
keywords: [testpermissions, restrictive, disabled, permissions-mock, lower-permissions, super, permission-test]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Permission tests must actually lower the execution context

## Description

`TestPermissions` describes how a test runner should establish the permission context; the enum value does not itself assign the business permission set being tested. `Restrictive` is the default and starts from D365 Full Access, requiring the test to lower permissions. `Disabled` leaves the test running as `SUPER`. A test that expects access to be denied while still running with either broad context can pass or fail for the wrong reason and never exercise the intended boundary.

## Best Practice

Use `TestPermissions::Restrictive` for a permission-sensitive test and lower the current test user with the test framework's `"Permissions Mock"` or `"Library - Lower Permissions"` before invoking the protected operation. Assign the exact permission set the scenario claims to test and restore or stop the mock afterward. Use `Disabled` only for suites that do not assert permission behavior.

See sample: `permission-tests-must-lower-the-execution-context.good.al`.

## Anti Pattern

Setting `TestPermissions = Disabled` or leaving the effective D365 Full Access context in place while asserting that a limited user is denied, or adding a `[TestPermissions(...)]` attribute without any runner/test-library code that applies the intended permission set.

See sample: `permission-tests-must-lower-the-execution-context.bad.al`.
