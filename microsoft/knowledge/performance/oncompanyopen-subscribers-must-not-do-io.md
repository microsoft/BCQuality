---
bc-version: [all]
domain: performance
keywords: [oncompanyopen, onafterlogin, session-start, httpclient, subscriber, login]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Session-open subscribers must not do I/O

> Contributions welcome — open a PR to refine or extend this article.

## Description

`OnCompanyOpen`, `OnCompanyOpenCompleted`, and `System Initialization`.OnAfterLogin run while the session is being created. The platform waits until every subscriber returns before the UI, an API call, or a background session can proceed. `HttpClient` or a heavy `FindSet` here delays **every** session type, not just the user who "opened the company". Agents still put warmup sync, license checks, and HTTP probes on these events because they look like an application startup hook.

## Best Practice

Keep company-open subscribers to cheap in-memory work: set a flag, enqueue a job-queue entry, or `TaskScheduler.CreateTask`. Perform HTTP and large SQL after the session is running, in that background work.

See sample: `oncompanyopen-subscribers-must-not-do-io.good.al`.

## Anti Pattern

An `OnAfterLogin` / `OnCompanyOpenCompleted` subscriber that calls `HttpClient` or scans a ledger. Detection signal: `HttpClient`, `FindSet`, or `CalcFields` inside a subscriber bound to those events.

See sample: `oncompanyopen-subscribers-must-not-do-io.bad.al`.
