---
bc-version: [all]
domain: performance
keywords: [job-queue, idempotency, retry, outbox, httpclient, external-effect]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Job queue external effects must be idempotent

> Contributions welcome — open a PR to refine or extend this article.

## Description

A job queue handler can successfully create something in an external system and then fail while updating Business Central. Business Central rolls back its database changes and retries the queued work, but it cannot roll back the external request. Without a way for the external system to recognize the repeated request, the retry can create a duplicate shipment, payment, notification, or other side effect.

## Best Practice

Use a stable request ID that exists before the job queue processes the outbox row. For example, include the outbox record's `SystemId` as an `idempotencyKey` value in the JSON body of every POST attempt. The external service must enforce uniqueness on that value: when it receives the key again, it returns the existing record instead of creating another one. Delete the outbox row only after the external call and all required local updates succeed.

A `Processed` flag set after the external call does not solve this failure window. If a later AL error rolls back that flag, the outbox row again looks unprocessed even though the external operation already happened.

See sample: `job-queue-external-effects-must-be-idempotent.good.al`.

## Anti Pattern

Sending a state-changing request from a job queue handler with no stable request ID understood by the external API. Specifically, look for this sequence: read an outbox row, call `HttpClient.Post` or another side-effecting API, update or delete local data, and propagate an error that can cause the same outbox row to be retried. The key may be part of the request body, URI, headers, or an existing business key; a naturally idempotent remote operation is already safe and should not be flagged.

See sample: `job-queue-external-effects-must-be-idempotent.bad.al`.