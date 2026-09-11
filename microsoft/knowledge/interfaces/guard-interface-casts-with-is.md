---
bc-version: [25..]
domain: interfaces
keywords: [interface, is-operator, as-operator, type-test, cast, variant, runtime-error]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Guard optional interface casts with `is`

## Description

From runtime 14.0, AL can type-test an interface or `Variant` with `is` and cast it to another interface with `as`. The test is non-throwing, but `as` raises a runtime error when the underlying codeunit does not implement the target interface. This matters when an extended capability is optional or implementations can come from other extensions.

## Best Practice

Use `is` to establish that the value supports the target interface before using `as`. Cast directly only where the target implementation is an invariant guaranteed by the surrounding contract.

See sample: `guard-interface-casts-with-is.good.al`.

## Anti Pattern

Using `as` unconditionally for an optional extended interface. An otherwise valid implementation of the base interface then fails at runtime merely because it does not implement the additional contract.

See sample: `guard-interface-casts-with-is.bad.al`.

## Reference

[Understand type testing and casting operators for interfaces](https://learn.microsoft.com/en-us/training/modules/business-central-interfaces/type-testing)
