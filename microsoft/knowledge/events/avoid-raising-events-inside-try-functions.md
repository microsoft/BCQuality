---
bc-version: [all]
domain: events
keywords: [tryfunction, integration-event, subscriber, error-handling, silent-failure, event-publisher]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not raise integration events inside a TryFunction whose result the caller consumes

## Description

A `TryFunction` whose caller consumes its Boolean result catches all errors raised during its execution — including errors thrown by event subscribers. When an `[IntegrationEvent]` is raised inside a `TryFunction` body, any error a subscriber raises is silently swallowed by the TryFunction's error boundary. The subscriber's logic fails, the caller sees no error, and the calling code continues as if nothing happened. Subscribers have no way to signal failure to the caller.

## Best Practice

When a call site uses the TryFunction's Boolean result, raise the integration event before entering the TryFunction scope. The event and its subscribers execute outside the error boundary, so subscriber errors propagate normally to the caller. Move only the operation that genuinely needs error isolation (such as an HTTP call or a posting step) inside the TryFunction.

A TryFunction that is only ever invoked as a bare statement, with its Boolean result ignored, activates no error boundary: subscriber errors raised in its body propagate like those of any ordinary procedure. Such a publisher path needs no change; see `microsoft/knowledge/error-handling/bare-tryfunction-call-propagates-errors.md`.

See sample: [`avoid-raising-events-inside-try-functions.good.al`](avoid-raising-events-inside-try-functions.good.al).

## Anti Pattern

Raising an integration event inside a TryFunction body that is invoked through an assignment or a conditional (for example `Success := TryDoWork();` or `if not TryDoWork() then`). Only that consumed-result call catches errors, so subscriber failures are caught and discarded and the subscriber contract — that a subscriber can signal failure to the caller — is silently broken. Resolve each call site of the TryFunction before flagging.

The event raise alone is not this anti-pattern. When every call site of the TryFunction is a bare statement, no try boundary is active and subscriber errors reach the caller as usual.

See sample: [`avoid-raising-events-inside-try-functions.bad.al`](avoid-raising-events-inside-try-functions.bad.al).
