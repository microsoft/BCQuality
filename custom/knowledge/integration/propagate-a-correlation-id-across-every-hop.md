---
bc-version: [all]
domain: integration
keywords: [correlation-id, tracing, propagation, queue-header, telemetry, end-to-end, trace]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Propagate a correlation id across every hop

## Description

A single integration flow touches many components in sequence: an inbound message arrives, a row is staged, a business event fires, a queue entry is picked up, an outbound call goes out, a confirmation comes back. Each component logs its own activity, but unless one identifier is threaded through all of them, those log lines are isolated islands. When something fails three hops in, reconstructing what happened means correlating by timestamp and hope, guessing which inbound message produced which outbound call, which is slow at the best of times and nearly impossible when the system is busy and many flows are interleaved.

A correlation id solves this by giving every component in one flow the same trace identifier to log and to pass along. It is the second most load-bearing field on the Integration Message after its own key, because it is what turns a pile of disconnected log entries into a single traceable story. The discipline that matters is that it is set exactly once, at the point where the flow enters Business Central, and then carried unchanged everywhere downstream. The most common failure is not the absence of a correlation id but its regeneration: a downstream step that mints a fresh id breaks the chain just as thoroughly as having none, because now two halves of the same flow log different identifiers.

## Best Practice

Generate the correlation id once at the entry point, the webhook receiver, the poll handler, or the first staged message, and never regenerate it downstream. Carry it on every subsequent Integration Message, every event payload, every queue message header, and every outbound HTTP request as a header such as `Correlation-Id`, and log it at every step. The mechanism that pays off is that the request row and its eventual confirmation row, and every step in between, all carry the one identifier, so a status query or a failure investigation pulls the entire chain, across Business Central, the queue, and the external system, with a single filter. Read the id from the incoming message rather than creating a new one; the only `CreateGuid` for a correlation value lives at the entry point. See `propagate-a-correlation-id-across-every-hop.good.al`.

The cost is one field carried and one header set per hop, which is trivial; the payoff is that incident response goes from archaeology to a single filtered query.

## Anti Pattern

Generating a new id at each hop, or not carrying the id onto outbound calls and queue headers at all, so each component logs an unrelated identifier. The detection signal: a `CreateGuid()` producing a correlation value inside a downstream processor or outbound step rather than reading the id from the incoming message, an outbound `HttpClient` request or event payload that omits the correlation header, or log statements that emit a locally minted trace value. The consequence is that no two components share a trace id, so tracing a failure across the flow requires correlating by timestamp and guesswork, and the external system's logs can never be joined back to the BC side at all. The fix is one id minted at the entry point and read, never regenerated, by every hop after it. See `propagate-a-correlation-id-across-every-hop.bad.al`.

## See also

- `stage-every-integration-message.md`
- `park-long-running-work-on-a-status-url.md`
- `monitor-external-event-subscription-health.md`
