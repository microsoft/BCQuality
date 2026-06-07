---
bc-version: [all]
domain: integration
keywords: [idempotency, deduplication, external-reference, inbound, replay, in-progress, unique-key]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Deduplicate inbound messages with an idempotency check

## Description

Duplicate inbound messages are a guarantee, not an edge case. A source system re-fetches and resends after a restart, a webhook platform fires a retry because it did not see your acknowledgement in time, a poll window overlaps a previous one, a load balancer replays a request. Every one of these delivers a message you have already seen, and the source genuinely believes it is doing the right thing by retrying. The receiver, not the sender, is responsible for recognising the repeat, because only the receiver knows what it has already processed.

The mechanism that makes recognition possible is the source system's own stable identifier. Before staging an inbound message, look it up by that identifier plus the message type. If a matching message is already Resolved, return its stored response and do nothing else, because the work is already done. If a matching message is In Progress, wait or reject rather than start a second concurrent run against the same external reference. Only when there is no match do you stage a new message and process it. Skip this check and a slow or duplicating external system turns every replay into real work: duplicate sales orders, double postings, duplicate outbound side effects that ripple to yet more systems.

## Best Practice

Deduplicate on `External Reference + Type`, the stable id the source system controls, and back it with a unique key on `(External Reference, Type)` so the lookup is a single indexed read and a concurrent duplicate insert fails at the database rather than racing through. Never deduplicate on the internal Message ID: that GUID is generated fresh on every insert, so it never matches a replay and gives you the illusion of a dedup check that can never fire. On a Resolved hit return the stored response so the caller sees the same answer it would have seen the first time; on an In Progress hit reject or back off so two runs do not process the same external reference at once; only on no hit do you insert and process. See `deduplicate-inbound-messages-with-an-idempotency-check.good.al`.

The trade-off is one indexed read on the ingest path, which is cheap, and a unique key that will reject a genuine duplicate insert, which is the point. Pair this with outbound idempotency keys (see `send-an-idempotency-key-on-every-outbound-call.md`) so the same flow is protected against duplicates on the way out as well as on the way in.

## Anti Pattern

An inbound handler that inserts a new Integration Message on every call without first checking for an existing one, or that deduplicates on the internal Message ID instead of the source's External Reference. The detection signal: an `Insert` of an inbound message with no prior `SetRange`/`Get` on `External Reference` and `Type`, a `CreateGuid()` used as the dedup key, or a dedup lookup keyed on `Message ID`. The consequence is that a retried or re-fetched delivery is processed as a brand-new message, so a duplicating source produces duplicate documents and double-applied side effects, and the volume scales with how aggressively the source retries. The fix is a lookup on `External Reference + Type` before any insert, backed by a unique key. See `deduplicate-inbound-messages-with-an-idempotency-check.bad.al`.

## See also

- `send-an-idempotency-key-on-every-outbound-call.md`
- `use-a-framing-record-for-inbound-polling.md`
- `stage-every-integration-message.md`
