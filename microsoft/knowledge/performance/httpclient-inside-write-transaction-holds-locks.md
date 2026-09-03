---
bc-version: [all]
domain: performance
keywords: [httpclient, write-transaction, lock, commit, outbound-http, session-block]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not call HttpClient inside an open write transaction

> Contributions welcome — open a PR to refine or extend this article.

## Description

The first database write opens an AL write transaction that the runtime holds until the execution completes or `Commit()` runs — see `understand-implicit-transaction-boundary.md`. `HttpClient` blocks the session until the remote call returns. Any locks taken by earlier `Insert`/`Modify`/`Delete` therefore stay held for the HTTP wall-clock time, and interactive users see a spinner. This is not generic "don't block": it is the AL transaction model plus lock lifetime around outbound I/O.

## Best Practice

Defer the HTTP call to a separate session. When the external operation must correspond to a committed database change, insert an outbox work item in the same transaction as that change and process committed outbox rows with a recurring job queue entry. The change and work item then commit or roll back together, and the worker performs HTTP before deleting the item so it holds no write lock during the call. Make the external operation idempotent because a failure after a successful HTTP response can cause the work item to be retried.

A directly created scheduled task is suitable only when its work is independent of the caller's commit. An immediately ready task can run concurrently with the caller, so it must not assume that the caller's writes are already committed. Do **not** use `Commit()` as a general remedy: it irrevocably commits all prior writes in the current transaction, so any subsequent failure cannot roll them back. `Commit()` is appropriate only at top-level entry points where partial persistence is intentional and understood.

See sample: `httpclient-inside-write-transaction-holds-locks.good.al`.

## Anti Pattern

`Modify`/`Insert` followed by `HttpClient` in the same procedure with no `Commit` between them. Detection signal: any `HttpClient` use after a write on the same execution path, especially in posting, page actions, or subscribers.

See sample: `httpclient-inside-write-transaction-holds-locks.bad.al`.
