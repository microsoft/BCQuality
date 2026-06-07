---
bc-version: [all]
domain: integration
keywords: [integration, staging, integration-message, webhook, posting, decoupling]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Stage every integration message

## Description

Every message that crosses the Business Central boundary, inbound or outbound, should be written to one staging table (the Integration Message) before any business work runs against it. Posting, document creation, and notification then operate on staged data, never on a live external call. This is the single most load-bearing rule in BC integration design because it decouples the local transaction from the availability and latency of a system you do not control: an external outage delays processing, it never breaks posting or forces a rollback. A flow that skips staging couples a database transaction to a remote endpoint, so a slow or failed remote call surfaces inside BC as a request timeout, a lock held too long, or a half-finished document.

The Integration Message is a normal table whose rows carry everything a processor needs to act without calling back to the source: the external reference, the message type, a status, the request and response payloads, the correlation id, and the retry state. Inbound and outbound rows share the table and are told apart by a Direction field.

## Best Practice

Treat staging as a two-phase split. Phase one is acceptance: a webhook receiver or an API page validates the payload, writes one Integration Message row, and returns. It does no posting and makes no second remote call. Phase two is processing: a background Job Queue codeunit reads rows by Status and does the real work, fully decoupled from the original caller.

Expose the Integration Message as a single API page and let a Type field route each row to the correct dispatcher codeunit, rather than versioning a separate endpoint per source system. One endpoint plus a Type-driven dispatcher means a new message kind is a new dispatcher branch, not a new published API surface. Keep an idempotency key on the external reference so a replayed delivery is detected at insert time rather than processed twice. See `stage-every-integration-message.good.al` for the intake page, the staging table shape, and the Job Queue processor.

## Anti Pattern

A webhook handler, an API page insert trigger, or a Job Queue poll handler that posts a document inline, or that calls the external service again to enrich the message before returning. Both couple the request to live database locks and to the remote system staying up.

Detection signal for a reviewer or agent: an HTTP-triggered handler or an `OnInsertRecord`/`OnModifyRecord` trigger on an API page that calls a posting codeunit (`Codeunit "Sales-Post"`, `OnAfterPostSalesDoc`, and similar) or `HttpClient.Send` directly, instead of `Insert`-ing an Integration Message row and returning. The fix is structural: move the post and the callout into the Job Queue processor that reads staged rows. See `stage-every-integration-message.bad.al`.

## See also

- `accept-async-work-instead-of-synchronous-wait-loops.md`
- `never-call-external-services-from-posting.md`
- `deduplicate-inbound-messages-with-an-idempotency-check.md`
