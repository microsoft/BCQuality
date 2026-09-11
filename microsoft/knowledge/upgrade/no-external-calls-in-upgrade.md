---
bc-version: [all]
domain: upgrade
keywords: [httpclient, dotnet, external-service, network-call, blocking, upgrade-rollback]
technologies: [al]
countries: [w1]
application-area: [all]
---

# No external calls inside upgrade codeunits

## Description

Upgrade code runs in a constrained execution window: the tenant is mid-upgrade, no users are signed in, and a failure aborts the entire transaction. An external HTTP call, DotNet interop call, or any other I/O to a system outside Business Central can hang or fail for reasons completely unrelated to the upgrade — DNS, expired credentials, a service that is itself being upgraded — and the upgrade fails with it. Rolling back from such a failure is hard because the upgrade pipeline assumes its work is deterministic.

The rule applies inside any codeunit with `Subtype = Upgrade` and to any procedure transitively invoked from `OnUpgrade...` triggers. The same calls in regular runtime code — pages, table triggers, normal codeunits, background jobs — are fine.

## Best Practice

Defer external calls to runtime code. If a piece of upgrade work conceptually needs data from an external service, set a flag or write a queue row during upgrade and have the runtime code make the call later (for example on first user sign-in or via job queue), where retries and degraded modes are tractable.

See sample: [`no-external-calls-in-upgrade.good.al`](no-external-calls-in-upgrade.good.al).

## Anti Pattern

Calling `HttpClient.Get`, `HttpClient.Post`, or DotNet interop methods from `OnUpgradePerCompany`, `OnUpgradePerDatabase`, or any procedure they invoke.

See sample: [`no-external-calls-in-upgrade.bad.al`](no-external-calls-in-upgrade.bad.al).
