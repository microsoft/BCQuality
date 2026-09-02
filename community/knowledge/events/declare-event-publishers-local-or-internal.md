---
bc-version: [all]
domain: events
keywords: [event-publisher, access-modifier, local, internal, integration-event, business-event, subscriber, breaking-change]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Declare event publishers local or internal

> Contributions welcome — open a PR to refine or extend this article.

## Description

The access modifier on an `[IntegrationEvent]` or `[BusinessEvent]` publisher controls who may *raise* the procedure, not who may *subscribe* to it. A subscriber in a dependent extension binds through the object named in its `[EventSubscriber(...)]` attribute, so the only accessibility a foreign subscriber needs is on the *object* — a codeunit left at its default public access. The publisher procedure itself can and should stay `local` or `internal`. Publishing an event is an invitation to subscribe, not an invitation to call: an omitted access modifier makes the publisher public, which hands every dependent extension the ability to fire the event on its own. The signature-compatibility consequences of a shipped publisher are covered separately by `treat-local-and-internal-events-as-subscriber-contracts`.

## Applies to

Ordinary `[IntegrationEvent]` and `[BusinessEvent]` publishers. `[InternalEvent]` has its own module-only visibility semantics, and external business events are out of scope.

## Best Practice

Give an event publisher the narrowest access modifier that still lets the code owning the operation raise it:

- `local` when only the declaring object raises the event. This is the common case and the default choice.
- `internal` when another object in the same app raises it — typically an internal implementation codeunit raising an event declared on a public facade codeunit. The facade object stays public so dependent extensions can name it in `[EventSubscriber(...)]`; the publisher stays `internal` so only the implementation decides when the event fires.
- `public` only when a *different app* must raise the event — a hub or event-bus codeunit in a foundation app that sibling apps signal through, where `internal` cannot reach across the app boundary. This is a deliberate caller contract, not a concession to subscribers, and it is maintained like any other public API.

Subscribers are unaffected by any of these choices. A non-public publisher also keeps the freedom to add a parameter later, which a public publisher gives up — see `add-new-event-parameters-at-the-end`.

See sample: `declare-event-publishers-local-or-internal.good.al`.

## Anti Pattern

An event publisher declared with no access modifier — or widened to public — in the belief that dependent extensions need that to subscribe. They do not. Two consequences follow. Any dependent extension can now call the publisher directly, firing every subscriber outside the owning routine's control flow, on state the publisher never prepared and with an `IsHandled` answer nobody reads. And because the publisher is a public procedure, it is a caller contract: narrowing it back to `local` or `internal` after release is itself a breaking change, so the mistake is not cheaply reversible.

Detection: an `[IntegrationEvent]` or `[BusinessEvent]` publisher that is public although every raiser is in its own app — typically raised only from its declaring object. A publisher deliberately made public so another app can raise it is not this anti-pattern; do not report it. When the surrounding repository or API context does not reveal whether an external raiser is intended, treat the public modifier as intentional rather than reporting it.

The mirror-image anti-pattern belongs to the reviewer, human or agent: recommending that a publisher be made public so extensions can subscribe, or reporting a `local`/`internal` publisher as unreachable dead code. Both readings mistake raising for subscribing. Neither should be raised as a finding.

See sample: `declare-event-publishers-local-or-internal.bad.al`.
