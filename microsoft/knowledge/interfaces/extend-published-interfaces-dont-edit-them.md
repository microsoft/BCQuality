---
bc-version: [16..]
domain: interfaces
keywords: [published-interface, interface-method, breaking-change, interface-extends, versioned-interface, appsourcecop, as0066]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Extend published interfaces; do not edit them

## Description

Adding a method to a shipped interface changes the contract every implementing codeunit must satisfy. Implementers can live in dependent extensions, so the addition breaks code the interface publisher cannot update; AppSourceCop reports AS0066. Interface inheritance is available from runtime 14.0 (Business Central 2024 release wave 2, BC25), but the original interface must remain unchanged.

## Best Practice

On BC25 or later, declare a new interface that `extends` the published interface and add the new method there. Existing implementers remain valid for the original contract, while new implementers opt in to the extended contract. For targets BC16 through BC24, where interface inheritance is unavailable, publish a new or versioned sibling interface instead.

See sample: `extend-published-interfaces-dont-edit-them.good.al`.

## Anti Pattern

Adding a procedure directly to an interface that has already shipped. Every dependent implementation must immediately add that procedure, so an otherwise compatible app update breaks its implementers.

See sample: `extend-published-interfaces-dont-edit-them.bad.al`.
