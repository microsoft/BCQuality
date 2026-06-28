---
bc-version: [all]
domain: events
keywords: [event-naming, onbefore, onafter, conventions, discoverability, integration-event, publisher]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Name events by publisher position

## Description

An event name should tell a subscriber where in the publisher the event fires. The convention encodes the position: an event at the very start of a procedure or trigger is `OnBefore<Name>`; one at the very end is `OnAfter<Name>`; one in the middle names both the host routine and the local boundary, as `On<Name>OnBefore<Context>` or `On<Name>OnAfter<Context>`. Consistent, position-encoding names make events discoverable and predictable, and let developers and tooling reason about firing order without reading the publisher. Ad-hoc names such as `MyCustomEvent` or `BeforePost` hide where the event fires and break the conventions the ecosystem relies on.

## Best Practice

Name by position: `OnBeforePostSalesLine` and `OnAfterPostSalesLine` at the routine boundaries, and `OnPostSalesLineOnAfterCalcAmounts` for an event raised partway through `PostSalesLine` after an amount calculation. The name alone then tells a subscriber both the host routine and the exact point it runs.

See sample: `name-events-by-publisher-position.good.al`.

## Anti Pattern

Ad-hoc event names that omit the host routine or the before/after position (`MyCustomSalesEvent`, `BeforePost`, `SalesLineEvent`), leaving subscribers unable to tell when the event fires relative to the publisher's logic. Detection: publisher names that do not follow the `OnBefore`/`OnAfter<Routine>` or `On<Routine>OnBefore`/`OnAfter<Context>` patterns.

See sample: `name-events-by-publisher-position.bad.al`.
