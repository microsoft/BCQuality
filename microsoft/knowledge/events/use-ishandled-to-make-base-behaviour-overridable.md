---
bc-version: [all]
domain: events
keywords: [ishandled, overridable, onbefore, integration-event, extensibility, event-override, subscriber-hook]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use the IsHandled pattern to make base behaviour overridable

## Description

AL has no method overriding, so a `procedure` that runs its body unconditionally cannot be replaced by an extension without editing base code. The established Business Central seam for substituting default behaviour is the `IsHandled` pattern: the routine raises an `OnBefore…` integration event carrying a `var IsHandled: Boolean`, then exits early when a subscriber has set it. This hands a partner a sanctioned hook to replace the logic instead of overwriting the routine. LLMs trained on languages with inheritance emit routines whose logic always runs and expose no `OnBefore`/`IsHandled` seam, so the behaviour silently cannot be overridden.

## Best Practice

Raise `OnBeforeX(…, IsHandled)` as the first step of the routine and guard with `if IsHandled then exit;` before any default logic runs. Declare the publisher `[IntegrationEvent(false, false)] local procedure OnBeforeX(…; var IsHandled: Boolean)` with an empty body, and keep `IsHandled` a `var` parameter so a subscriber can write to it. A subscriber that replaces the behaviour does its work and sets `IsHandled := true`; one that only augments leaves it untouched and guards with `if IsHandled then exit;` itself. Reserve the override hook for cases where a partner genuinely needs to replace logic — when the goal is only to react, a positive `OnAfter` event is the better seam.

See sample: `use-ishandled-to-make-base-behaviour-overridable.good.al`.

## Anti Pattern

Two shapes. First, a routine whose default logic always runs because there is no `OnBefore…`/`IsHandled` hook at all — extensions cannot change it without overwriting base code. Second, a routine that raises `OnBeforeX(IsHandled)` but omits the `if IsHandled then exit;` guard, so the default logic still executes after a subscriber set `IsHandled := true`, duplicating work and side effects. Detection: an `OnBefore` publisher with a `var IsHandled: Boolean` parameter whose caller never tests `IsHandled`, or a public routine doing non-trivial work with no overridable seam.

See sample: `use-ishandled-to-make-base-behaviour-overridable.bad.al`.
