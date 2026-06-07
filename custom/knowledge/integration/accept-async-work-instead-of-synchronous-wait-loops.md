---
bc-version: [all]
domain: integration
keywords: [async, sleep, polling, http-202, status-url, api-handler, request-thread]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Accept async work instead of synchronous wait loops

## Description

An inbound API handler or webhook receiver that kicks off external work and then `Sleep`-and-polls until it finishes holds the request thread for the entire wait, and with it the session slot and any locks the handler has taken. The handler is now blocked on work it does not own and cannot speed up. Web requests into Business Central have a finite server-side budget, so a wait measured in seconds or minutes does not produce a slow-but-correct answer: the connection times out, the caller gets an error, and the work it triggered is orphaned with no record that it ever started.

The damage compounds under load and under exactly the external conditions you cannot control. When the downstream system is slow, each in-flight request pins a thread, so a handful of slow calls exhaust the available request slots and healthy callers start getting rejected too: one slow dependency becomes a site-wide outage. When the downstream system is down, every request blocks for the full timeout before failing, turning a fast failure into a slow one and multiplying the thread pressure. The handler must never block on work it does not own. Accept the request, persist it, answer immediately, and let the caller check back.

## Best Practice

Split acceptance from completion. Stage the request as an Integration Message, return `202 Accepted` with a status URL that points at that staged row, and let a background processor do the slow work. The request thread is freed the instant the row is written, so throughput is bounded by how fast you can insert rows, not by how slow the downstream system is. The mechanism that makes the caller whole is the status URL plus the Status field: the caller polls a read-only API page over the Integration Message keyed by its Message ID and watches Status move from New to In Progress to Resolved or Failed, reading the final response from the same row. This applies to any inbound path where completion is not guaranteed to be immediate. See `accept-async-work-instead-of-synchronous-wait-loops.good.al`.

The trade-off is that the caller must be willing to poll (or accept a callback), which is a contract you state up front with the 202 and the Location header. For work that genuinely answers in the same call, a synchronous response is fine; reach for staging the moment completion depends on a system you do not control.

## Anti Pattern

An inbound handler that contains a `Sleep` inside a `repeat ... until` or `while` loop that re-queries an external service for completion before returning. The detection signal: `Sleep(` together with a loop and an `HttpClient` call inside an API page trigger, a webhook codeunit, or any procedure on the request path; equivalently, a handler whose return value depends on a remote status it polls in-line. The consequence is that the request blocks for the full duration of external work, the caller's connection times out, and concurrent requests pile up on pinned threads until the service stops accepting new ones. The fix is to stage the request and return 202 with a status URL. See `accept-async-work-instead-of-synchronous-wait-loops.bad.al`.

## See also

- `park-long-running-work-on-a-status-url.md`
- `stage-every-integration-message.md`
- `propagate-a-correlation-id-across-every-hop.md`
