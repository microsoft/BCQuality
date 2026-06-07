---
bc-version: [all]
domain: integration
keywords: [batching, outbound, throughput, partial-failure, per-item-status, telemetry, job-queue]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Batch outbound work only when the remote supports it

## Description

Batching several outbound messages into one call reduces per-call overhead, but it couples the fate of the items inside the batch: if the batch of fifty fails, you have to work out which one of the fifty caused it, and most remote APIs return a single success or failure for the whole batch rather than per-item status. Batching is worth it only when the remote exposes a genuine batch endpoint and tells you the outcome of each item, so a single bad item does not strand the other forty-nine. Faking a batch by chaining single calls inside one Job Queue run is worse than not batching at all: it is a synchronous wait loop with extra steps, holding one task and one lock for the whole sequence.

Batch size is a tuning decision, not a constant. A validate stage can batch large; a posting stage that takes locks should batch small. The right size comes from telemetry on real lock contention and throughput, never from intuition.

## Best Practice

Batch in the orchestrator or the sender stage, never inside posting, and only against a remote that accepts a batch and returns per-item status. Keep a per-item idempotency key (the Integration Message id of each item) inside the batch so a retry of the batch does not double-process the items that already succeeded. Mark each message Resolved or Failed individually from the per-item response, so a partial failure parks only the items that actually failed. Start the batch size low and raise it only on the evidence of telemetry, with a smaller size for stages that lock heavily than for stages that only read. See `batch-outbound-work-only-when-the-remote-supports-it.good.al`.

## Anti Pattern

Two shapes. First, simulated batching: a Job Queue run that loops `HttpClient.Send` over fifty messages to "batch" them, which is a wait loop that pins one task and serialises fifty round trips. Second, blind batching: a real batch POST whose response is a single status with no per-item detail, so one invalid item fails the whole batch and the code cannot tell which item to fix or retry. The detection signal: a loop of `Client.Send` inside one `OnRun`, or a batch send followed by a single `IsSuccessStatusCode` check that flips every message in the batch to the same status. The consequence is that one bad item strands a whole batch and a retry re-sends the items that already succeeded. See `batch-outbound-work-only-when-the-remote-supports-it.bad.al`.

## See also

- `send-an-idempotency-key-on-every-outbound-call.md`
- `accept-async-work-instead-of-synchronous-wait-loops.md`
- `split-multi-step-flows-into-staged-job-queue-entries.md`
