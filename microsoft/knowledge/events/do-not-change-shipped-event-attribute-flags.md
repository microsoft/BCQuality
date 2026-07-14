---
bc-version: [all]
domain: events
keywords: [event-attribute, includesender, globalvaraccess, isolated-event, compatibility, integration-event, business-event, appsourcecop, as0021, as0101]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not change shipped event attribute flags

## Description

`IncludeSender` and, on Integration events, `GlobalVarAccess` have been event-contract flags since runtime 1.0. Removing sender or global access breaks subscribers, so AppSourceCop AS0021 prevents changing those flags from `true` to `false`. On runtime 9.0 and later (Business Central 2022 release wave 1, BC20), `Isolated` also controls transaction, error, and rollback behavior; AS0101 prevents adding, removing, or changing that argument.

## Best Practice

Keep every available attribute argument exactly as shipped. If new subscribers need different sender/global exposure, publish a new event with the desired flags. Apply the same rule to `Isolated` only on BC20 or later, where that argument exists. Raise both events while the original contract is supported, and choose preferred flags only when designing a new event.

See sample: `do-not-change-shipped-event-attribute-flags.good.al`.

## Anti Pattern

Changing a shipped event's `IncludeSender` or `GlobalVarAccess` to modernize its design, including replacing `IncludeSender` with an explicit parameter. On BC20 or later, adding, removing, or toggling `Isolated` is equally contract-significant. Even a change that leaves old subscribers compiling can alter observable execution or exposure; version the event instead.

See sample: `do-not-change-shipped-event-attribute-flags.bad.al`.
