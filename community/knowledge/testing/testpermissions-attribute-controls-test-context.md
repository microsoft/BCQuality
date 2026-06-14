---
bc-version: [all]
domain: testing
keywords: [testpermissions, permissions, restrictive, disabled, super, test-context, permission-set]
technologies: [al]
countries: [w1]
application-area: [all]
---

# TestPermissions attribute controls the permission set under which a test runs

## Description

The `TestPermissions` property on a test codeunit — or the `[TestPermissions]` attribute on an individual test function — controls which permission set the test executes under. When omitted, the test runs with the permissions of the calling user, typically SUPER in a development environment. Tests that pass under SUPER may fail for real users with standard permission sets.

## Best Practice

Set `TestPermissions = Restrictive` at the codeunit level. This runs every test with no permission sets assigned, catching missing `InherentPermissions` or `PermissionSet` grants before they reach production. Override at the function level with `[TestPermissions(TestPermissions::Disabled)]` only for tests that explicitly verify admin-level behavior.

See sample: `testpermissions-attribute-controls-test-context.good.al`.

## Anti Pattern

Omitting `TestPermissions` entirely, or setting `Disabled` at the codeunit level. Both cause every test to run as SUPER. Permission errors that real users would hit are invisible, and the test suite gives false confidence about the app's behavior under realistic conditions.

See sample: `testpermissions-attribute-controls-test-context.bad.al`.
