---
bc-version: [all]
domain: integration
keywords: [idempotency-key, outbound, http-header, retry, message-guid, side-effect, uncertain-failure]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Send an idempotency key on every outbound call

## Description

When Business Central calls an external system, some failures are certain (a 400 that clearly rejected the request) but the dangerous ones are uncertain: a socket timeout, a dropped connection, a 502 from a gateway in front of a service that may have processed the request anyway. After an uncertain failure you genuinely do not know whether the work landed. You must retry to make progress, but a blind retry risks doing the side effect twice: a second payment captured, a second shipment booked, a second order placed. The uncertainty is inherent to networks and cannot be engineered away; what you can do is make the retry safe.

An idempotency key makes it safe. It is a value the caller sends so the receiver can recognise a repeat of a request it has already handled and return the original response instead of acting again. The contract is the caller's responsibility: the receiver can only deduplicate if every retry of the same logical request carries the same key. That is the crux of the rule, because the most common bug is a key that changes between attempts, which looks like a fix but is functionally no key at all. Every outbound call that has a side effect must carry a stable key.

## Best Practice

Set an `Idempotency-Key` header on every outbound request and derive its value from the Integration Message GUID, which is created once when the message is staged and never changes. Because the key lives on the staged row, every retry of that row, whether by the Job Queue minutes later or by an operator resolving a failed message days later, sends the identical key, so a well-behaved receiver collapses all of them into one side effect and returns the same response. The mechanism is the binding of the key to the durable message rather than to the attempt: a new key is minted only when a genuinely new message is created. See `send-an-idempotency-key-on-every-outbound-call.good.al`.

This pairs with re-running the same message on manual resolution (see `make-failed-integration-messages-manually-resolvable.md`): because resolution re-runs the same Message ID, it reuses the same idempotency key, so even a human-driven retry cannot double-apply. The only cost is one header per request and the discipline of never regenerating the key.

## Anti Pattern

An outbound `HttpClient` call with no idempotency header, or one that generates a fresh key per attempt (for example `CreateGuid()` or a counter inside the retry loop) so each retry looks like a brand-new request to the receiver. The detection signal: an `HttpClient.Post`/`Send` building an outbound request that has a side effect but no `Idempotency-Key` header, or a key whose source is anything that changes between attempts (a `CreateGuid()` inside the loop, a timestamp, an attempt counter). The consequence is that after an uncertain failure the retry double-applies the side effect, so a slow or flaky receiver produces duplicate payments and duplicate shipments precisely when it is least healthy. The fix is one stable key derived from the message GUID, set on every attempt. See `send-an-idempotency-key-on-every-outbound-call.bad.al`.

## See also

- `deduplicate-inbound-messages-with-an-idempotency-check.md`
- `make-failed-integration-messages-manually-resolvable.md`
- `park-long-running-work-on-a-status-url.md`
