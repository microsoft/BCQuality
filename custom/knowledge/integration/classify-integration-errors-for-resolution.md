---
bc-version: [all]
domain: integration
keywords: [error-classification, triage, transient, data-error, contract-change, resolution, ai]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Classify integration errors for resolution

## Description

When integration messages fail they pile up, and a single "Failed" status with a raw error string forces an operator to read every one to decide what to do. Most failures fall into one of three classes that demand different responses: a data error (customer not found, invalid currency, wrong VAT code) that a human must fix on the payload, a transient error (timeout, 503, deadlock) that the system should retry with backoff and no human at all, and a contract change (a renamed field, a schema break) that is a code change the integration owner must be paged about. Without the class, transient errors waste human attention while contract breaks sit unescalated, and time-to-resolve grows with the size of the failed queue.

Classifying each failure and storing the class on the Integration Message turns a Monday pile of three hundred failures into three sorted buckets, each with an obvious next action. The class is one extra field; the value is the routing it enables.

## Best Practice

On failure (Status set to Failed with a non-empty error), classify the error into data error, transient, or contract change and write the class to an Error Class field on the Integration Message before ops sees it. The class drives the action: data errors go to the manual resolution page, transient errors are left for the scheduled retry, contract changes raise an alert to the integration owner. A rules table over known error codes handles the common cases; an AI classifier (called through the System.AI module, never a raw model call) buckets the free-text messages that rules miss, which is where most of the time-to-resolve saving comes from. Keep the classifier advisory: the class routes work, it does not auto-resolve it. See `classify-integration-errors-for-resolution.good.al`.

## Anti Pattern

A failure handler that sets Status to Failed with only a raw error string and no class, leaving an operator to read and triage every row by hand. The detection signal: an integration error path that writes `Error Message` but has no Error Class (or equivalent category) field and no classification step, so the resolution page shows one undifferentiated Failed bucket. The consequence is that retries that would self-heal get manual attention, genuine data fixes wait behind them, and a contract break that should page an engineer looks identical to a transient timeout. See `classify-integration-errors-for-resolution.bad.al`.

## See also

- `make-failed-integration-messages-manually-resolvable.md`
- `version-business-events-and-keep-payloads-stable.md`
- `monitor-external-event-subscription-health.md`
