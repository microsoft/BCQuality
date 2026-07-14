---
bc-version: [25..]
domain: events
keywords: [this-keyword, includesender, sender, codeunit, self-reference, integration-event, type-safety]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer this over IncludeSender in new codeunit events

## Description

When designing a new publisher, setting `IncludeSender` to `true` on `[IntegrationEvent]` or `[BusinessEvent]` gives subscribers the publishing object as an implicit sender parameter. From Business Central 2024 release wave 2, a codeunit can instead pass itself explicitly with the `this` keyword as a normal, strongly-typed `Sender` parameter. Explicit passing makes the sender visible and typed in the signature. This is new-event design guidance only: never change `IncludeSender` on an event that has already shipped.

## Best Practice

For a new event, declare the publisher `[IntegrationEvent(false, false)]` with an explicit `Sender: Codeunit "…"` parameter and raise it with `this`, for example `OnBeforeProcessOrder(OrderNo, this);`. Subscribers then receive a typed sender they can call directly.

See sample: `prefer-this-over-includesender-in-codeunit-events.good.al`.

## Anti Pattern

Designing a new codeunit event with `[IntegrationEvent(true, …)]` solely to hand subscribers the publisher instance, where `this` could be passed explicitly as a typed parameter. Do not apply this rule by mutating a shipped event's attribute flags.

See sample: `prefer-this-over-includesender-in-codeunit-events.bad.al`.
