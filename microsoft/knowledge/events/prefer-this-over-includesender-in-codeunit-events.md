---
bc-version: [25..]
domain: events
keywords: [this-keyword, includesender, sender, codeunit, self-reference, integration-event, type-safety]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer this over IncludeSender in codeunit events

## Description

Some publishers set `IncludeSender` to `true` on `[IntegrationEvent]` or `[BusinessEvent]` so subscribers receive the publishing object as an implicit sender parameter. From Business Central 2024 release wave 2, a codeunit can instead pass itself explicitly with the `this` keyword as a normal, strongly-typed `Sender` parameter. Explicit passing is clearer at both the publisher and the subscriber: the sender appears in the signature, it is concretely typed to the publishing codeunit, and it avoids the implicit-parameter mechanics of `IncludeSender`. Reserve `IncludeSender = true` for cases where the sender genuinely cannot be passed explicitly. This guidance applies to code targeting Business Central 2024 release wave 2 or later, where the `this` keyword is available.

## Best Practice

Declare the publisher `[IntegrationEvent(false, false)]` with an explicit `Sender: Codeunit "…"` parameter and raise it with `this`, for example `OnBeforeProcessOrder(OrderNo, this);`. Subscribers then receive a typed sender they can call directly.

See sample: `prefer-this-over-includesender-in-codeunit-events.good.al`.

## Anti Pattern

Relying on `[IntegrationEvent(true, …)]` solely to hand subscribers the publisher instance, where a codeunit could pass `this` explicitly as a typed parameter. Detection: `IncludeSender = true` on a codeunit event whose only purpose is to expose the sender, in code targeting Business Central 2024 release wave 2 or later.

See sample: `prefer-this-over-includesender-in-codeunit-events.bad.al`.
