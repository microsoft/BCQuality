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

This is about the data-consistency contract of an API endpoint: what a consumer receives when it reads. By default an API read can return in-flight rows that a concurrent, still-open transaction has written but not yet committed. For an endpoint whose contract is "return only data that is durably committed," that is wrong — a consumer could fetch a row that the writing transaction later rolls back, then act on data that never really existed. From runtime 22.0 (BC 2023 release wave 1) an API page can pin the isolation level its reads use: setting `Rec.ReadIsolation := IsolationLevel::ReadCommitted;` in the page's `OnOpenPage` trigger makes the endpoint expose only committed rows. LLMs rarely set this on an API page because the platform default "just works" for ordinary UI; this file is remedial because the committed-only endpoint contract requires an explicit opt-in the model would not add on its own.

## Best Practice

For an API page that must expose only committed data, set the endpoint's read isolation once as the page opens: in the `OnOpenPage` trigger write `Rec.ReadIsolation := IsolationLevel::ReadCommitted;`. Every read the endpoint then serves ignores uncommitted writes from concurrent transactions, so a consumer never receives a row that another transaction might still roll back.

See sample: `expose-only-committed-data-from-api-reads.good.al`.

## Anti Pattern

An API intended to return committed-only data that sets no isolation level, leaving reads at the default that can observe in-flight, uncommitted writes. A consumer can fetch a row created by a concurrent transaction that is later rolled back — a dirty read that surfaces data which never durably existed. The detection signal: a committed-only read API with no `Rec.ReadIsolation := IsolationLevel::ReadCommitted` in `OnOpenPage`.

See sample: `expose-only-committed-data-from-api-reads.bad.al`.
