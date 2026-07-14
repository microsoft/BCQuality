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

An `enum` that `implements` an interface maps each value to a codeunit through the `Implementation` property. But an extensible enum can carry values that set no `Implementation` — values added later by an extension, or a value left intentionally blank. Assigning such a value to an interface variable and calling a method on it fails at runtime unless the enum provides a fallback. The enum-level `DefaultImplementation` property names the codeunit used whenever a value has no explicit `Implementation`, so resolution always yields a usable object. LLMs are generally unaware this property exists and leave the gap open.

## Best Practice

On any extensible enum that implements an interface, set `DefaultImplementation = <Interface> = <Codeunit>;` at the enum level, pointing at a safe implementation that does nothing harmful. Values with their own `Implementation` keep using it; declared values without one resolve to the default. For an ordinal that matches no currently declared value — for example persisted data left after an enum extension is uninstalled — runtime 7.0 and later can use `UnknownValueImplementation` as a distinct fallback. Do not recommend that property to apps targeting an earlier runtime.

See sample: `set-defaultimplementation-on-enum.good.al`.

## Anti Pattern

An extensible `enum ... implements <Interface>` where at least one value sets no `Implementation` and the enum declares no `DefaultImplementation`. Code that assigns that value to an interface variable and invokes a method throws at the call site, and because the enum is extensible the failing value can be introduced by a third party long after the consumer ships. Detection signal: an enum that implements an interface, has a `value(...)` with no `Implementation`, and no enum-level `DefaultImplementation`. Add a `DefaultImplementation` mapping to close the gap.

See sample: `set-defaultimplementation-on-enum.bad.al`.
