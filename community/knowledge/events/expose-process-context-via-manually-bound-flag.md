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

An extension that drives a process over shared code — a base application report, a posting routine, a codeunit any caller may invoke — leaves every other extension hooked into that same shared code with a question the platform cannot answer: is this run part of that process, or an ordinary one? AL keeps no ambient "current process", so the driving app has to publish the context itself. The reflex answer, a `SingleInstance` codeunit holding a boolean that is set at the start of the run and cleared at the end, is unsafe in Business Central: single-instance variables are not part of the database transaction, so when the run fails the writes roll back and the flag does not. It stays `true` until the company is closed, and every later run in that session is silently treated as part of the process. A manual event binding carries the same signal safely, because the platform ties its lifetime to a variable's scope instead of to cleanup code that has to run.

## Best Practice

Publish the context as a query and let the binding itself be the state. One procedure is public; everything behind it is internal:

- A context codeunit — public, so dependent extensions can name it — exposes a public procedure such as `IsProcessRunning(): Boolean`, which raises an `[InternalEvent]` publisher taking a `var Boolean` and returns what comes back. That procedure is the entire public surface. The publisher is an internal event because only the owning app ever subscribes to it, and `local` because only this codeunit ever raises it.
- A second codeunit, `Access = Internal` with `EventSubscriberInstance = Manual`, subscribes to that event and sets the boolean to `true`. It is implementation rather than API, and it keeps nothing between runs — being bound *is* the state.
- The driving process calls `BindSubscription` on a variable whose scope is exactly the span it wants to claim: a local in the procedure that drives the run, or a global on an object that lives exactly as long as the run does. While that variable is alive the query answers `true`; when it leaves scope — on the normal path, or because an error unwound the call stack — the platform removes the binding and the query answers `false` again. Nothing has to be reset, so there is no cleanup path to forget and no `UnbindSubscription` to place in an error handler.

Bind a fresh instance per run rather than reusing one: the platform refuses to bind the same instance twice but accepts several instances of the same codeunit, so nesting and re-entrancy need no counter. The binding is session-scoped, so work the process starts in another session — a background session, a page background task, a job queue entry — cannot see it; pass the context explicitly there.

See sample: `expose-process-context-via-manually-bound-flag.good.al`.

## Anti Pattern

Two shapes, both of which leave other extensions unable to integrate correctly.

First, the single-instance boolean. The reset at the end of the routine never runs when the process errors, so the flag survives the rollback and poisons the rest of the session. Detection: a `SingleInstance = true` codeunit with a boolean set before a process and cleared after it, read by other code to decide whether that process is running.

Second, the context kept private. The driving app arranges its own marker — typically a manually bound subscriber on an event added to the shared code for its benefit alone — and offers no way to ask about it, or only an `internal` query its own module can call. Extensions hooked into the same shared code are left inferring the context from side effects, request-page values, or record state, which breaks silently the first time the process changes. Detection: a manual binding used purely as an internal run marker, with no public query procedure over it.

The mirror-image anti-pattern belongs to the reviewer, human or agent: reporting the `BindSubscription` in this pattern as a leaked binding because no `UnbindSubscription` follows it. Scope release is the mechanism here, not an omission — see `choose-static-vs-manual-subscribers-deliberately.md`, whose leak case is an instance parked on a `SingleInstance` global that never leaves scope.

See sample: `expose-process-context-via-manually-bound-flag.bad.al`.
