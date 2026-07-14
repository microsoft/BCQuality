---
bc-version: [18..]
domain: interfaces
keywords: [unknownvalueimplementation, unknown-enum-value, persisted-ordinal, enum-extension, extension-uninstall, interface-fallback]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Handle unknown enum ordinals with UnknownValueImplementation

## Description

An enum ordinal can remain in persisted data after the enum extension that declared it is uninstalled. The ordinal is then unknown: it matches no currently declared enum value. `DefaultImplementation` does not cover this case; it covers declared values that have no explicit interface implementation. `UnknownValueImplementation`, available from runtime 7.0 (Business Central 2021 release wave 1, BC18), provides the distinct interface implementation for an unknown ordinal.

## Best Practice

On BC18 or later, set `UnknownValueImplementation = <Interface> = <Codeunit>;` on an enum that implements an interface and can be persisted. Use an implementation that reports a clear domain error or safely contains the unknown state. Keep `DefaultImplementation` separately when declared but unmapped values also need a fallback.

See sample: `handle-unknown-enum-ordinals-with-unknownvalueimplementation.good.al`.

## Anti Pattern

Defining only `DefaultImplementation` and assuming it also handles a stored ordinal whose enum value has disappeared. After an enum extension is uninstalled, converting that unknown ordinal to the interface can produce a technical runtime error instead of controlled handling.

See sample: `handle-unknown-enum-ordinals-with-unknownvalueimplementation.bad.al`.
