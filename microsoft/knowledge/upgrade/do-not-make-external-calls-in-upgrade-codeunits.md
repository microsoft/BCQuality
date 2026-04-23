---
bc-version: [all]
domain: upgrade
keywords: [upgrade, httpclient, external-service, dotnet, availability]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not make external service calls inside upgrade codeunits

## Description

The upgrade scope has to complete for the tenant to reach the new version. Any call in the upgrade path that depends on an external service — HttpClient to a partner API, a DotNet interop call, a codeunit that fetches remote configuration — fails closed when the service is unreachable, misconfigured, or slow. The failure blocks the upgrade for every customer whose environment cannot reach the dependency at the moment the upgrade runs, and there is no user present to retry. The scope is specifically code inside codeunits with `Subtype = Upgrade` or reachable from their triggers.

## Best Practice

Defer external calls to runtime code that executes after the upgrade — install-triggered tasks, background job queue entries scheduled by the upgrade, or lazy initialization on first use. The upgrade step should compute a local result or mark work to be done, not perform the remote call itself.

## Anti Pattern

`HttpClient.Get(...)` or `DotNetType.CallStaticMethod(...)` directly in `OnUpgradePerCompany`, or in a local procedure called from it. The upgrade now depends on network availability to a service the platform does not control.
