---
bc-version: [20..]
domain: events
keywords: [event-attribute, includesender, globalvaraccess, isolated-event, compatibility, integration-event, business-event, appsourcecop, as0021, as0101]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not change shipped event attribute flags

## Description

`IncludeSender`, `GlobalVarAccess`, and `Isolated` affect a subscriber contract, not just publisher implementation. Removing sender or global access breaks subscribers; changing `Isolated` changes transaction, error, and rollback behavior. AppSourceCop AS0021 prevents changing exposed sender or globals from `true` to `false`, while AS0101 prevents adding, removing, or changing `Isolated`. The three-argument event form with `Isolated` is available from runtime 9.0 (Business Central 2022 release wave 1, BC20).

## Best Practice

Keep every attribute argument exactly as shipped. If new subscribers need different sender/global exposure or isolation semantics, publish a new event with the desired flags and raise both events while the original contract is supported. Choose preferred flags only when designing a new event.

See sample: `do-not-change-shipped-event-attribute-flags.good.al`.

## Anti Pattern

Changing a shipped event's attribute arguments to modernize its design, remove `GlobalVarAccess`, replace `IncludeSender` with an explicit parameter, or make the event isolated. Even a change that leaves old subscribers compiling can alter observable execution or exposure; version the event instead.

See sample: `do-not-change-shipped-event-attribute-flags.bad.al`.
