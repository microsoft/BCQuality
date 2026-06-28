---
bc-version: [all]
domain: events
keywords: [ishandled, onafter, event-pairing, control-flow, guard, integration-event, side-effects]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Preserve OnAfter execution when IsHandled skips the body

## Description

A routine that exposes both an `OnBefore…` event (with `var IsHandled`) and a paired `OnAfter…` event has a subtle trap. The common `if IsHandled then exit;` guard returns from the whole routine, so when a subscriber handles the OnBefore the OnAfter event never fires. Subscribers that depend on OnAfter — logging, downstream integration, dependent updates — then silently stop running whenever some other extension overrides the body. The fix is to skip only the default body, not the routine, so the OnAfter still publishes. The two seams are independent: overriding the work should not cancel the notification that the work happened.

## Best Practice

Wrap only the default work in `if not IsHandled then begin … end;` and keep the `OnAfterX(…)` raise after that block, outside the guard, so it always fires regardless of whether a subscriber handled the OnBefore. This keeps the override seam and the after-notification independent, which is what subscribers expect.

See sample: `preserve-onafter-execution-when-ishandled-skips-the-body.good.al`.

## Anti Pattern

Guarding with `if IsHandled then exit;` and placing the `OnAfterX` raise later in the same routine, so handling the OnBefore short-circuits the whole procedure and the OnAfter event is skipped along with the body. Detection: an `if IsHandled then exit;` in a routine that also raises a paired `OnAfter…` event after that point.

See sample: `preserve-onafter-execution-when-ishandled-skips-the-body.bad.al`.
