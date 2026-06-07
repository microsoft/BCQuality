---
bc-version: [all]
domain: integration
keywords: [manual-resolution, failed-message, resolution-page, edocument, confirm-by-exception, ops, audit]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Make failed integration messages manually resolvable

## Description

Automation cannot fix every failure. A malformed payload from a source that changed its format, a mapping gap for a product that was set up wrong, a one-off data problem on a single document: these are not transient and no amount of retrying resolves them, because the data itself is the problem. When automation cannot recover, a human has to be able to step in, and the design must let them do it without a developer and a deployment. If the only way to fix a stuck message is to change code and ship a release, then every data-level failure becomes an engineering incident, and the backlog of stuck messages grows while it waits for the next deployment window.

Manual resolution is therefore a first-class part of the integration design, not an afterthought bolted on once something breaks. Failed Integration Messages must stay editable so operations can correct the payload and re-run the same message, and the re-run has to preserve identity so it does not undo the very guarantees the happy path relied on. The shape worth copying is the one Microsoft already ships for E-Document: inbound staging, a resolution page, a status enum, retry actions, and an audit trail, so the experience is familiar to anyone who has resolved an electronic document and the audit story is already understood.

## Best Practice

Keep Failed messages editable. Operations corrects the payload on the row and flips Status back to New, and the processor re-runs the same Message ID under the same idempotency key, so the correction reprocesses without creating a duplicate and without double-applying a side effect that may already have partly landed. Provide a resolution page exposing the payload and the error, with three actions: Resolve (re-run the same message after a fix), Confirm-by-Exception (accept the message as handled with no retry, keeping the audit record so the decision is traceable), and Reassign (route the message to another handler or queue). The mechanism that makes re-run safe is reusing the existing Message ID rather than minting a new one, because the idempotency key is derived from that id (see `send-an-idempotency-key-on-every-outbound-call.md`), so a human-driven retry is as safe against duplicates as an automated one. Mirror the E-Document shape so the experience and the audit trail are familiar. See `make-failed-integration-messages-manually-resolvable.good.al`.

The trade-off is keeping failed rows around and editable rather than purging them, which costs storage and demands a resolution UI, in exchange for a system where a data problem is an operations task rather than an engineering deployment.

## Anti Pattern

Failed messages that are read-only or auto-deleted, so a fix means a code change and redeploy, or a manual retry that mints a new Message ID and so loses the idempotency guarantee. The detection signal: a Failed status with no editable payload and no resolution page, a purge or cleanup job that `DeleteAll`s failed rows, or a manual retry path that calls `CreateGuid()` to create a fresh message instead of re-running the existing one. The consequences are that every data failure becomes a deployment (read-only or deleted rows), the payload and error context needed to diagnose it are gone (deletion), or the retry double-applies the side effect because the receiver sees a new request rather than a repeat (new Message ID). The fix is editable failed rows, a resolution page with retry actions, and a re-run that reuses the same Message ID. See `make-failed-integration-messages-manually-resolvable.bad.al`.

## See also

- `deduplicate-inbound-messages-with-an-idempotency-check.md`
- `send-an-idempotency-key-on-every-outbound-call.md`
- `stage-every-integration-message.md`
