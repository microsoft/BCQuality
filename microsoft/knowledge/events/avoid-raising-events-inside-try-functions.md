---
bc-version: [all]
domain: events
keywords: [tryfunction, integration-event, subscriber, error-handling, silent-failure, event-publisher]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not raise integration events inside a TryFunction

## Description

A `TryFunction` catches all errors — including errors thrown by event subscribers. When an `[IntegrationEvent]` is raised inside a `TryFunction` body, any error a subscriber raises is silently swallowed by the TryFunction's error boundary. The subscriber's logic fails, the caller sees no error, and the calling code continues as if nothing happened. Subscribers have no way to signal failure to the caller.

## Best Practice

Raise the integration event before entering the TryFunction scope. The event and its subscribers execute outside the error boundary, so subscriber errors propagate normally to the caller. Move only the operation that genuinely needs error isolation (such as an HTTP call or a posting step) inside the TryFunction.

See sample: `avoid-raising-events-inside-try-functions.good.al`.

## Anti Pattern

Raising an integration event inside a TryFunction body. Subscriber failures are caught and discarded by the TryFunction. The subscriber contract — that a subscriber can signal failure to the caller — is silently broken.

See sample: `avoid-raising-events-inside-try-functions.bad.al`.
