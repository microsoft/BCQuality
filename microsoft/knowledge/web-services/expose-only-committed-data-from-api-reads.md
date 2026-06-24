---
bc-version: [22..]
domain: web-services
keywords: [api-page, readisolation, isolationlevel, readcommitted, onopenpage, dirty-read, committed-data]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Read only committed data from APIs that must not expose in-flight writes

## Description

By default a read can observe uncommitted changes made by other, still-open transactions running concurrently. For most interactive pages that is harmless, but an API whose contract is "return only data that is durably committed" must not leak those dirty reads — a consumer could fetch a row that a concurrent transaction later rolls back, and act on data that never really existed. From runtime 22.0 (BC 2023 release wave 1) AL exposes `Rec.ReadIsolation`, letting a page pin its isolation level. Setting `Rec.ReadIsolation := IsolationLevel::ReadCommitted;` in `OnOpenPage` guarantees the endpoint only returns committed rows. LLMs rarely set isolation explicitly because the platform's default "just works" for ordinary UI; this file is remedial because committed-only API semantics require an explicit opt-in that the model would not add on its own.

## Best Practice

For an API page that must expose only committed data, set the isolation level once as the page opens: in the `OnOpenPage` trigger write `Rec.ReadIsolation := IsolationLevel::ReadCommitted;`. Every subsequent read on that record variable then ignores uncommitted writes from concurrent transactions, so the endpoint never returns a row that another transaction might still roll back.

See sample: `expose-only-committed-data-from-api-reads.good.al`.

## Anti Pattern

An API intended to return committed-only data that sets no isolation level, leaving reads at the default that can observe in-flight, uncommitted writes. A consumer can fetch a row created by a concurrent transaction that is later rolled back — a dirty read that surfaces data which never durably existed. The detection signal: a committed-only read API with no `Rec.ReadIsolation := IsolationLevel::ReadCommitted` in `OnOpenPage`.

See sample: `expose-only-committed-data-from-api-reads.bad.al`.
