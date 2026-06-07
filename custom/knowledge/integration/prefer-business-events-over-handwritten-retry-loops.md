---
bc-version: [all]
domain: integration
keywords: [business-events, external-business-event, retry, outbound, post-commit, subscription, notification]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer business events over handwritten retry loops

## Description

For outbound notification, the kind of "something happened, tell whoever is interested" message that does not need an inline answer, a hand-written AL HTTP retry loop reimplements machinery the platform already ships. To be correct, that loop must own exponential backoff, classify which status codes are worth retrying (408, 429, and 5xx) versus which are permanent, persist its retry state so it survives a restart, and stay alive long enough to exhaust its attempts. Most hand-rolled loops get at least one of these wrong, and the failure is silent: a notification is simply lost and nobody notices until a downstream system is found to be out of sync.

An `[ExternalBusinessEvent]` hands all of that to the platform. Business Central retries the delivery on 408, 429, and 5xx responses for up to roughly 36 hours, persists the delivery state itself, and lets external subscribers register without any AL change. Just as important, delivery is asynchronous and post-commit: the platform sends the notification only after the firing transaction commits, and never sends it if that transaction rolls back. That is why firing an event from a posting or release path is safe even though calling `HttpClient` from the same path is not. Prefer the event over the loop wherever a subscriber can register for it.

## Best Practice

Declare an `[ExternalBusinessEvent('name', 'Display', 'Desc', Category)]` whose parameters are a minimal DTO of identifiers (a document number, an external reference) rather than a record, and fire it from a thin subscriber on the real event such as release or post. The mechanism that makes this both reliable and safe is the platform's delivery model: the event is queued in the committing transaction, so it exists only if the business action succeeded, and the platform then owns retry and backoff against the registered notification URLs. External subscribers self-serve by POSTing to `api/microsoft/runtime/v1.0/externaleventsubscriptions` with the event name, app id, notification URL, and client state, so adding a consumer is a configuration step, not a code change. External business events are available from runtime 11 and are still labelled preview, so confirm the surface against current docs before relying on it. See `prefer-business-events-over-handwritten-retry-loops.good.al`.

The trade-off and its boundary: business events are for fire-and-forget notification, not for request/response where you need an answer in the same call. If the caller must act on a returned value, this is the wrong tool; stage an outbound message and call with an idempotency key instead.

## Anti Pattern

A custom AL codeunit that loops over `HttpClient.Send` with `Sleep` backoff to deliver a notification that an external business event could carry. The detection signal: a retry loop counting attempts around an outbound POST, classifying 429/5xx by hand, with `Sleep`-based backoff, where the payload is a one-way notification rather than a request needing an inline reply. The consequence is twofold: delivery is coupled to Business Central staying up for the life of the loop (a restart mid-loop loses the notification with no record), and you have reimplemented, usually less correctly, the retry, backoff, and durability the platform already provides. The fix is to declare an external business event and fire it from a thin subscriber. See `prefer-business-events-over-handwritten-retry-loops.bad.al`.

## See also

- `version-business-events-and-keep-payloads-stable.md`
- `monitor-external-event-subscription-health.md`
- `never-call-external-services-from-posting.md`
