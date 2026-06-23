---
bc-version: [all]
domain: events
keywords: [integration-event, onbefore, onafter, extension-point, thin-publisher, publisher-body, extensibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Publish thin OnBefore/OnAfter integration events to expose extension points

## Description

A key operation — a posting, release, or validation routine — becomes a hard wall for partners when it ships no integration events: the only way to change it is to overwrite or duplicate the base code. The Business Central remedy is to raise thin `OnBeforeX`/`OnAfterX` integration events at the operation's boundaries, passing `var Rec` and the relevant parameters so subscribers have what they need. An equally common defect is the inverse: putting business logic *inside* the publisher method body. An event publisher is a hook, not a procedure — its body must be empty, and the platform even forbids variables, return values, and code other than comments in it. LLMs both omit the extension points and, when they do add an event, wrongly fill its body with logic.

## Best Practice

Wrap the operation's core with events: raise `OnBeforeX(var Rec, var IsHandled)` before the default work and `OnAfterX(var Rec)` once it succeeds, at the natural boundaries of the routine. Declare each publisher `[IntegrationEvent(false, false)] local procedure` with an empty body and let the calling routine — never the publisher — own the logic. Pass records by `var` so subscribers can read and adjust them, and include the parameters a subscriber would need to act. This gives partners a stable seam without touching base code.

See sample: `publish-thin-onbefore-onafter-integration-events.good.al`.

## Anti Pattern

Business logic placed inside an `[IntegrationEvent]` publisher method, so the "event" actually mutates state every time it is raised — defeating the hook and surprising every reader — or a core operation that exposes no extension points at all, forcing partners to overwrite or duplicate it. Detection: an `[IntegrationEvent]`/`[BusinessEvent]` method whose body contains statements rather than being empty, or a posting/validation routine with no surrounding `OnBefore`/`OnAfter` publishers.

See sample: `publish-thin-onbefore-onafter-integration-events.bad.al`.
