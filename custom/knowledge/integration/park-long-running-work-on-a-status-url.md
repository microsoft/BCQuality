---
bc-version: [all]
domain: integration
keywords: [long-running, http-202, status-url, awaiting-reply, orchestration, retry-state, durable-function]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Park long-running work on a status URL

## Description

Some external work does not answer in the call that starts it. The service accepts the request, returns `202 Accepted` with a status URL in the Location header, and finishes minutes or hours later. This is a correct and common pattern on the remote side, and Business Central has to handle it correctly on its side, which means avoiding two opposite mistakes. Blocking on the work until it finishes is wrong, because it pins a session for the whole wait (the no-synchronous-wait-loop rule). Firing the request and forgetting it is also wrong, because the answer arrives later with nothing in BC tracking that it is owed.

The right shape treats the 202 as a deferral, not a failure or a completion. On receiving it, park the Integration Message as Awaiting Reply with the status URL stored on the row, and let a separate scheduled poll resume the flow when the answer is ready. The request and the eventual confirmation are two states of one message sharing a correlation id, not two unrelated events. The detail that makes a parked flow survivable is where its retry state lives: retry count and last error belong on the message row, not in a codeunit variable, because a variable resets on restart and a flow that can wait hours will almost certainly outlive the session that started it.

## Best Practice

On a 202, read the Location header, store it on the message as the status URL, and set Status to Awaiting Reply. A scheduled poll reads Awaiting Reply rows, queries each status URL, and advances the message to Resolved when the work is done or records the failure when it is not. Keep retry count and last error on the message, so a resumed poll, possibly running in a different session after a restart, knows how many times it has tried and why it last failed. The mechanism that keeps the Job Queue healthy is the separation between parking and polling: the Job Queue owns short, BC-bounded units of work, so when the wait exceeds roughly 30 seconds the waiting belongs to external orchestration (a Logic App or a Durable Function) that calls back or that BC polls briefly, never a Job Queue tight loop holding a slot for hours. See `park-long-running-work-on-a-status-url.good.al`.

The trade-off is an extra status field and a poll job, which buys you a flow that resumes correctly across restarts and never monopolises a worker slot.

## Anti Pattern

Treating a 202 as a failure and retrying the original request, holding the work in a Job Queue tight loop that `Sleep`-polls the status URL, or keeping retry count in a codeunit variable that resets on restart. The detection signal: a 202 branch that re-sends the original request, a `Sleep` poll loop over a status URL inside a Job Queue handler, or retry/last-error state held in a local or global variable rather than on the Integration Message. The consequences are duplicate work (re-sending a request the service already accepted), a Job Queue slot pinned for the entire external wait (so a flow that waits hours starves other jobs), and a retry counter that resets to zero every restart so backoff and give-up logic never work. The fix is to park as Awaiting Reply with the status URL and resume via a scheduled poll, with all retry state on the row. See `park-long-running-work-on-a-status-url.bad.al`.

## See also

- `accept-async-work-instead-of-synchronous-wait-loops.md`
- `propagate-a-correlation-id-across-every-hop.md`
- `split-multi-step-flows-into-staged-job-queue-entries.md`
