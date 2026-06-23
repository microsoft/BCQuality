---
bc-version: [16..]
domain: interfaces
keywords: [interface, enum-implements-interface, polymorphism, implementation-property, case-statement, variant-behavior, dispatch]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer an interface with enum-backed implementation over a case statement for variant behaviour

## Description

When behaviour varies by a discrete "type" — a shipping method, a posting strategy, a payment provider — the obvious first draft is a `case` over an enum with one branch per variant. That branch logic gets copied to every call site, and every new variant means editing all of them. AL interfaces (Business Central 2020 release wave 1) combined with enum-with-implementation replace that with automatic dispatch: an `interface` declares the contract, an `enum` that `implements` it maps each value to a codeunit, and the consumer assigns the enum value to an interface variable and calls the method. Adding a variant becomes a new enum value plus a new implementation codeunit — zero consumer edits. LLMs trained on older AL reach for the `case` block by default and rarely model a variant set as an interface.

## Best Practice

Declare an `interface` with the method signatures only (no bodies). Define an `enum` that `implements` the interface and set `Implementation = <Interface> = <Codeunit>;` on each value, pointing at a codeunit that `implements` the same interface. In the consumer, declare a variable of the interface type, assign the enum value to it, and call the method — the platform dispatches to the codeunit mapped to that value. New variants plug in by adding an enum value and its implementation; existing call sites are untouched. The open/closed boundary lives at the enum, not scattered across `case` blocks.

See sample: `prefer-interface-over-case-branching.good.al`.

## Anti Pattern

A `case "Shipping Method" of` block that selects behaviour inline, duplicated across the call sites that need it. Each new method forces a synchronized edit to every block, and a missed branch is a silent gap. Detection signal: a `case` statement over an enum value whose branches choose between variant computations or strategies, especially when the same shape appears in more than one procedure. Replace the enum with one that `implements` an interface, move each branch body into an implementation codeunit, and let dispatch happen through an interface variable.

See sample: `prefer-interface-over-case-branching.bad.al`.
