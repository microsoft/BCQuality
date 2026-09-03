---
bc-version: [all]
domain: events
keywords: [bindsubscription, manual-binding, eventsubscriberinstance, internalevent, singleinstance, process-context, running-flag, scoped-state, rollback]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Expose process context through a manually bound flag, not a single-instance boolean

> Contributions welcome — open a PR to refine or extend this article.

## Description

When an extension drives a process over shared code — a base application report, a posting routine — other extensions hooked into that code cannot tell whether a run belongs to that process: AL keeps no ambient "current process", so the driving app has to publish the context itself. The reflex answer, a `SingleInstance` codeunit holding a boolean set at the start of the run and cleared at the end, is unsafe: single-instance variables are not part of the database transaction, so a failed run rolls back the writes but not the flag, which stays `true` until the company is closed and marks every later run in the session as part of the process. A manual event binding carries the same signal safely, because the platform ties its lifetime to a variable's scope instead of to cleanup code that has to run.

## Best Practice

Publish the context as a query and let the binding itself be the state. One procedure is public; everything behind it is internal:

- A public context codeunit exposes `IsProcessRunning(): Boolean`, which raises an `[InternalEvent]` publisher taking a `var Boolean` and returns what comes back — the entire public surface. The publisher is internal because only the owning app subscribes, `local` because only this codeunit raises it.
- A second codeunit, `Access = Internal` with `EventSubscriberInstance = Manual`, subscribes to that event and sets the boolean to `true`. Internal keeps it out of the API and stops other apps binding it to forge the context; it stores nothing between runs — being bound *is* the state.
- The driving process calls `BindSubscription` on a variable whose scope is exactly the span it wants to claim: a local in the procedure that drives the run, or a global on an object that lives exactly as long as the run. While that variable is alive the query answers `true`; when it leaves scope — normally, or because an error unwound the call stack — the platform removes the binding and the query answers `false` again.

Bind a fresh instance per run rather than reusing one: the platform refuses to bind the same instance twice but accepts several instances of the same codeunit, so nesting and re-entrancy need no counter. The binding is session-scoped, so work the process starts in another session — a background session, a page background task, a job queue entry — cannot see it; pass the context explicitly there.

See sample: `expose-process-context-via-manually-bound-flag.good.al`.

## Anti Pattern

Two shapes.

First, the single-instance boolean — the failure described above. Detection: a `SingleInstance = true` codeunit with a boolean set before a process and cleared after it, read by other code to decide whether that process is running.

Second, the context kept private: the driving app arranges its own marker — typically a manually bound subscriber on an event added for its benefit alone — and offers no query, or only an `internal` one. Other extensions are left inferring the context from side effects, request-page values, or record state, which breaks silently the first time the process changes. Detection: a manual binding used purely as an internal run marker, with no public query procedure over it.

The mirror-image anti-pattern belongs to the reviewer: flagging the `BindSubscription` here as a leaked binding because no `UnbindSubscription` follows it. Scope release is the mechanism, not an omission — see `microsoft/knowledge/events/choose-static-vs-manual-subscribers-deliberately.md`, whose leak case is an instance parked on a `SingleInstance` global that never leaves scope.

See sample: `expose-process-context-via-manually-bound-flag.bad.al`.
