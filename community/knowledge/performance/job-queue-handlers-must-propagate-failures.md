---
bc-version: [all]
domain: performance
keywords: [job-queue, error-propagation, tryfunction, retry, dispatcher, job-queue-log]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Job queue handlers must propagate execution failures

> Contributions welcome — open a PR to refine or extend this article.

## Description

The job queue dispatcher can mark an entry as failed, record the error, and apply its configured retry behavior only when the handler terminates with an error. A handler that catches a failed `TryFunction` or Boolean-returning operation and then returns normally reports success to the dispatcher, even though its work did not complete.

## Best Practice

Let an error that invalidates the whole run propagate out of the job queue entry point. Add context only when it helps an operator diagnose the failure and does not expose sensitive data. Per-item failures may be collected deliberately, but the batch must persist or emit an observable aggregate outcome instead of silently treating incomplete work as success.

See sample: `job-queue-handlers-must-propagate-failures.good.al`.

## Anti Pattern

Calling a `TryFunction`, `Codeunit.Run`, or another Boolean-returning operation from a job queue handler and using `exit` or normal fall-through on failure without recording an intentional partial-success outcome. The dispatcher sees a successful return, so the entry's status and log do not represent the failed work and configured retries are not applied.

See sample: `job-queue-handlers-must-propagate-failures.bad.al`.