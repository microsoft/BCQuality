---
bc-version: [16..]
domain: interfaces
keywords: [interface, defaultimplementation, enum-implements-interface, fallback, extensible-enum, implementation-property]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set DefaultImplementation on an enum so an unmapped value still resolves to an interface

## Description

An `enum` that `implements` an interface maps each declared value to a codeunit through the `Implementation` property. A declared value, including one supplied by an enum extension, can omit that mapping. Assigning that value to an interface variable then fails at runtime unless the enum provides `DefaultImplementation`. This property is for declared but unmapped values; an ordinal that is no longer declared is a different case covered by `handle-unknown-enum-ordinals-with-unknownvalueimplementation`.

## Best Practice

On any extensible enum that implements an interface, set `DefaultImplementation = <Interface> = <Codeunit>;` at the enum level, pointing at a safe implementation. Values with their own `Implementation` keep using it; declared values without one resolve to the default. Do not rely on this property for persisted ordinals that match no declared enum value.

See sample: `set-defaultimplementation-on-enum.good.al`.

## Anti Pattern

An extensible `enum ... implements <Interface>` where at least one value sets no `Implementation` and the enum declares no `DefaultImplementation`. Code that assigns that value to an interface variable and invokes a method throws at the call site, and because the enum is extensible the failing value can be introduced by a third party long after the consumer ships. Detection signal: an enum that implements an interface, has a `value(...)` with no `Implementation`, and no enum-level `DefaultImplementation`. Add a `DefaultImplementation` mapping to close the gap.

See sample: `set-defaultimplementation-on-enum.bad.al`.
