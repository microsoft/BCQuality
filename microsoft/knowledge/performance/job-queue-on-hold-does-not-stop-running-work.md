---
bc-version: [all]
domain: performance
keywords: [job-queue, on-hold, cancellation, in-process, long-running, stop-request]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Putting a job queue entry on hold does not stop its current run

> Contributions welcome — open a PR to refine or extend this article.

## Description

The On Hold status prevents a job queue entry from starting again, but it does not cancel a run that is already in process. A long-running handler continues until it completes, fails, reaches a cancellation point implemented by the application, or its session is stopped externally.

## Best Practice

Use On Hold to pause future scheduling. When a long-running operation must support graceful cancellation, store a separate application-owned stop request and check it before every bounded unit of work, including the first. Exit only at a point where completed work and the checkpoint are consistent. The code that resumes scheduling must clear the stop request before restarting the job. Use administrative session termination only when graceful cancellation is impossible.

See sample: `job-queue-on-hold-does-not-stop-running-work.good.al`.

## Anti Pattern

Polling the job queue entry's Status field from inside its handler and expecting a change to On Hold to cancel the active run. The status controls scheduling, not cooperative cancellation, so the handler can continue processing despite the operator's action.

See sample: `job-queue-on-hold-does-not-stop-running-work.bad.al`.