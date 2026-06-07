---
bc-version: [all]
domain: integration
keywords: [staged-pipeline, job-queue, iintegrationstage, interface, lock-window, no-shared-state, rollback]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Split multi-step flows into staged job queue entries

## Description

A multi-step integration flow (fetch, transform, post, notify) handled by one big codeunit in one transaction is one big lock and one big rollback. Every lock the flow takes anywhere along the chain is held until the final step commits, so the slowest or most contended step sets the lock duration for all of them, and a failure in the last step discards the successful work of every earlier step. A transient hiccup while notifying then throws away a posting that was perfectly good, and the whole flow re-runs from the start, redoing work that had already succeeded.

Splitting the flow into stages, each its own Job Queue entry, changes the unit of failure and the unit of locking. Every stage gets its own short lock window and its own retry policy, and a failed stage rolls back only its own work, leaving earlier stages committed and the flow free to resume from where it stopped. The flow advances stage by stage with the message Status as the cursor: Status records the position, so resuming is just reading the next stage to run, and there is no separate per-stage row to reconcile. The discipline that keeps the stages genuinely independent is that they share no state across runs.

## Best Practice

Make each stage its own Job Queue entry with its own short lock window and retry. Have stages implement a common `IIntegrationStage` interface dispatched from an extensible enum, so adding a stage is one new codeunit plus one enum value with no change to the orchestrator. Use Status as the cursor that records the flow's position; do not create a new row per stage, because the message is the flow and its Status is where it is up to. The rule that makes the split real is shared state: a stage may cache item, customer, or location lookups within a single run (a Dictionary that is created and discarded inside one invocation), but never across stages and never globally, because cross-run cache is exactly the coupling the split exists to remove. A useful tell is that if a lookup is hot enough to tempt you toward a global cache, the split is in the wrong place. See `split-multi-step-flows-into-staged-job-queue-entries.good.al`.

The trade-off is more moving parts (an interface, an enum, several codeunits) in exchange for short lock windows, per-stage retry, and a flow that resumes instead of restarting. That trade is worth making once a flow has more than one step that can fail independently.

## Anti Pattern

One handler that runs every step in a single transaction, or stages that pass data through a global or cross-invocation cache. The detection signal: a single codeunit whose `Run`/`OnRun` does fetch, transform, post, and notify in sequence in one transaction, or a `SingleInstance` codeunit or other long-lived holder caching lookups that survive between stage runs. The consequence of the monolith is one lock window covering the whole chain and one rollback that discards all prior work when any step fails; the consequence of the shared cache is that stages which should be independent are coupled, so they can no longer be retried or reordered in isolation. The fix is one Job Queue entry per stage behind an interface, Status as the cursor, and per-run-only caching. See `split-multi-step-flows-into-staged-job-queue-entries.bad.al`.

## See also

- `park-long-running-work-on-a-status-url.md`
- `stage-every-integration-message.md`
- `use-a-framing-record-for-inbound-polling.md`
