---
bc-version: [all]
domain: performance
keywords: [oncompanyopen, oncompanyopencompleted, session, sign-in, subscriber, startup]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep OnCompanyOpen and OnCompanyOpenCompleted subscribers lightweight

## Description

`OnCompanyOpen` and `OnCompanyOpenCompleted` are raised every time a session is created — not only for interactive sign-ins, but also for every web service call, every job queue entry, every scheduled task, and every page background task. The session cannot run any AL code until every subscriber on these events has finished. Interactive users see a spinner; web service callers see elevated response times; background sessions sit idle waiting to start.

Anything expensive in these subscribers is paid per session across the whole tenant. The two patterns that typically cause production incidents are outgoing HTTP calls to external services — which block AL execution until they complete (or time out) — and long-running SQL over large tables. An external service that is slow or unreachable turns into a tenant-wide sign-in outage, not a degraded feature.

The code often looks harmless in review: a telemetry ping, a configuration refresh, a "just make sure the setup record exists" Get-or-Insert. Multiplied by session creations per minute, each of these becomes the critical path of sign-in.

## Best Practice

Keep `OnCompanyOpen` and `OnCompanyOpenCompleted` subscribers short and in-memory. Defer work that touches external services or large tables to a Page Background Task, a job queue entry, or a lazy first-use path. If an outgoing HTTP call in startup is truly unavoidable, set an aggressive timeout so a failing endpoint cannot stall session creation.

## Anti Pattern

An `OnCompanyOpen` subscriber that calls an external licensing API over HttpClient without a tight timeout. When the endpoint is slow, every new session in the tenant — UI, API, background — waits on the HTTP call before it can run any AL.
