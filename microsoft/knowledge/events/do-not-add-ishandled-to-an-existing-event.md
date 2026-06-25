---
bc-version: [all]
domain: events
keywords: [ishandled, semantic-change, event-contract, backward-compatibility, onbefore, integration-event, subscribers]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not add IsHandled to an existing event

## Description

Adding a `var IsHandled: Boolean` parameter to an event that already shipped without one silently changes the event's purpose — from a plain notification into an overridable seam. Existing subscribers were written against a "notify" contract they never agreed to make skippable, so their behaviour can quietly become wrong or pointless. The safe move is to leave the existing event untouched and introduce a new `OnBefore…` event carrying `IsHandled` at the point you want to make overridable. Existing subscribers keep working against the original event; new subscribers opt into the override seam through the new one.

## Best Practice

Keep the existing event as-is and add a separate `OnBeforeX(…; var IsHandled: Boolean)` before the logic you want to make overridable. Two events with distinct, stable contracts are safer than one event whose meaning and signature were changed under its subscribers.

See sample: `do-not-add-ishandled-to-an-existing-event.good.al`.

## Anti Pattern

Mutating a shipped event — for example adding `var IsHandled` to `OnAfterCalculateTotal` — to retrofit override behaviour, which overloads the event's meaning and undermines existing subscribers. Detection: an `IsHandled` parameter added to a pre-existing event signature rather than introduced through a new dedicated `OnBefore` publisher.

See sample: `do-not-add-ishandled-to-an-existing-event.bad.al`.
