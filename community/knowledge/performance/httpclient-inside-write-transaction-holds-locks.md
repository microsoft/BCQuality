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

Defer the HTTP call to a `TaskScheduler` task or job queue entry so it runs in a separate session after the write transaction has already ended. The database write completes and releases its locks naturally when the caller's transaction commits; the HTTP call then happens without holding any locks. Do **not** use `Commit()` as a general remedy: it irrevocably commits all prior writes in the current transaction, so any subsequent failure cannot roll them back. `Commit()` is appropriate only at top-level entry points where partial persistence is intentional and understood.

See sample: `httpclient-inside-write-transaction-holds-locks.good.al`.

## Anti Pattern

`Modify`/`Insert` followed by `HttpClient` in the same procedure with no `Commit` between them. Detection signal: any `HttpClient` use after a write on the same execution path, especially in posting, page actions, or subscribers.

See sample: `httpclient-inside-write-transaction-holds-locks.bad.al`.
