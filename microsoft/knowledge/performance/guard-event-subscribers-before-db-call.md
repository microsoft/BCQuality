---
bc-version: [all]
domain: performance
keywords: [event-subscriber, guard, db-call, frequently-fired, validate]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Guard event subscribers with cheap checks before any database call

## Description

Event subscribers fire on every event matching their signature — for `OnAfterValidateEvent` on a hot field like `Sales Line.Quantity`, that is every quantity edit by every user. Per the upstream guidance, "Keep event subscriber code lightweight" and "Avoid database operations in frequently-fired events — guard with cheap checks first." A `Get` or `FindFirst` at the top of such a subscriber pays a database round-trip on every fire, including the calls for which the subscriber's work was not needed.

## Best Practice

Open the subscriber with an in-memory predicate that filters out the calls the subscriber does not handle — record type, document type, status, parameter-passed flags. Only after the cheap guard passes should the body issue a database call, and only with `SetLoadFields` for the columns the body actually reads.

See sample: [`guard-event-subscribers-before-db-call.good.al`](guard-event-subscribers-before-db-call.good.al).

## Anti Pattern

`[EventSubscriber(...'OnAfterValidateEvent', 'Quantity', ...)] local procedure ... var Item: Record Item; begin Item.Get(Rec."No."); if Item.HasCustomPricing() then ...;` — `Item.Get` runs on every quantity change, including changes to lines whose `Type` is not `Item`. A pre-check `if Rec.Type <> Rec.Type::Item then exit;` ahead of the `Get` removes most of the calls.

See sample: [`guard-event-subscribers-before-db-call.bad.al`](guard-event-subscribers-before-db-call.bad.al).
