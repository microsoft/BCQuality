---
bc-version: [all]
domain: integration
keywords: [posting, httpclient, callout, job-queue, locks, subscriber, rollback]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Never call external services from posting

## Description

A posting routine runs as one database transaction and holds write locks on the document header, the document lines, and every ledger and entry table it touches until that transaction commits. Calling an external service from inside that routine, or from a posting subscriber such as `OnAfterPostSalesDoc`, `OnAfterPostPurchaseDoc`, or `OnAfterFinalizePosting`, binds the lifetime of those locks to the response time of a system Business Central does not control. The remote endpoint, not BC, now decides how long the locks are held.

The failure mode is concrete and it gets worse under exactly the conditions you cannot prevent. When the external system is slow, the posting transaction stays open and every other user who needs those records waits behind it, so one sluggish endpoint serialises an entire team's posting. When the external system is down, the call blocks until the HTTP timeout fires and then throws, and because the throw happens inside the posting transaction the whole post rolls back: the shipment that physically left the warehouse now has no posted document, and nothing was staged to retry. When the external system is healthy but the network blips, you get an uncertain failure on a transaction that may already have committed downstream. The remote call has to leave the posting transaction entirely.

## Best Practice

Stage the outbound work instead of sending it inline. From the posting subscriber, write one Integration Message row (Direction Outbound, Status New) that carries the document anchor (for example the posted document number) and whatever payload the receiver needs, then return immediately so posting commits on local state alone. A background Job Queue codeunit reads the staged rows by Status and performs the actual `HttpClient.Send` outside any posting lock. The mechanism that makes this safe is the commit boundary: the row is inserted in the posting transaction, so it exists only if the post succeeded, and the callout runs in a separate later transaction where a remote outage delays delivery without ever touching the posting locks or the posted document. See `never-call-external-services-from-posting.good.al`.

This applies to every posting and posting-adjacent path, inbound or outbound. The one nuance worth knowing: firing an `[ExternalBusinessEvent]` from a posting subscriber is not a violation, because that is not an HTTP call and the platform delivers it post-commit (see `prefer-business-events-over-handwritten-retry-loops.md`). The trade-off of staging is added latency and one more table, which is the point: you are trading immediacy for a posting path that cannot be held hostage.

## Anti Pattern

A posting routine or a posting-event subscriber that calls `HttpClient.Send` directly, or that invokes a client codeunit which does. The detection signal a reviewer or agent can match: an `HttpClient`, `HttpRequestMessage`, `HttpContent`, or REST/JSON client reference inside a `Codeunit "*-Post"`, or inside a subscriber bound to `OnAfterPostSalesDoc`, `OnAfterPostPurchaseDoc`, `OnAfterFinalizePosting`, `OnBeforePost*`, or any publisher on a posting codeunit. The consequence is that posting locks are now held for the full remote round trip, and a remote failure rolls back a post that should have been durable. The fix is structural: move the callout into a Job Queue processor that reads staged rows. See `never-call-external-services-from-posting.bad.al`.

## See also

- `stage-every-integration-message.md`
- `prefer-business-events-over-handwritten-retry-loops.md`
- `propagate-a-correlation-id-across-every-hop.md`
