---
bc-version: [all]
domain: events
keywords: [ishandled, initialization, deterministic, onbefore, reset, integration-event, control-flow]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Initialize IsHandled to false before publishing

## Description

A routine that raises an `OnBefore…` integration event with a `var IsHandled: Boolean` parameter passes that variable in by reference, so its incoming value decides whether the default logic is skipped. A freshly declared Boolean starts as `false`, but the same variable is frequently reused to raise several events in one routine, and after the first raise it may already be `true`. Assigning `IsHandled := false;` on the line immediately before every raise makes the control flow deterministic and self-documenting, and prevents a stale `true` from silently suppressing logic the author never meant to make skippable. Generated code often reuses one `IsHandled` across several raises without resetting it.

## Best Practice

Set `IsHandled := false;` immediately before each `OnBeforeX(…, IsHandled)` raise, then guard the default logic with `if IsHandled then exit;` or `if not IsHandled then …`. Do this even when the variable was just declared: the explicit reset documents intent and stays correct if a second event raise is added to the routine later. This applies only to events that carry a `var IsHandled: Boolean`; an `OnBefore` event with no `IsHandled` parameter needs no reset.

See sample: `initialize-ishandled-to-false-before-publishing.good.al`.

## Anti Pattern

Raising `OnBeforeX(…, IsHandled)` with a variable whose value carries over from an earlier raise, so a subscriber that handled the first event unintentionally suppresses the second routine's default logic. Detection: an `IsHandled` variable passed to more than one event in a routine without an intervening `IsHandled := false;`, or any `OnBefore…` raise that passes an `IsHandled` variable without an intervening `IsHandled := false;`.

See sample: `initialize-ishandled-to-false-before-publishing.bad.al`.
