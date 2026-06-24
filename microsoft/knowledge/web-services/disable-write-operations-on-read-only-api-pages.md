---
bc-version: [all]
domain: web-services
keywords: [api-page, insertallowed, modifyallowed, deleteallowed, editable, read-only, reporting-api]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Lock down write operations on read-only API pages

## Description

An API meant purely for reading — a reporting or lookup endpoint — is not read-only just because nobody intends to write to it. Unless the page explicitly forbids writes, the platform leaves the endpoint writable, so a client can POST, PATCH, or DELETE against data that was never meant to change through that surface. The fix is explicit: set `InsertAllowed = false`, `ModifyAllowed = false`, and `DeleteAllowed = false` (and `Editable = false`) so the endpoint rejects every write operation. LLMs often assume "I only exposed read fields, so it's read-only" and rely on defaults; this file is remedial because the default for an API page is writable, and the read-only intent has to be encoded as three explicit property settings, not inferred.

## Best Practice

For a read-only / reporting API page set all three CRUD guards off — `InsertAllowed = false`, `ModifyAllowed = false`, `DeleteAllowed = false` — and mark the page `Editable = false`. The endpoint then serves GET requests and rejects any insert, modify, or delete, matching the read-only contract regardless of the caller. Make the read-only stance explicit rather than depending on the writable default.

See sample: `disable-write-operations-on-read-only-api-pages.good.al`.

## Anti Pattern

An API intended for read-only consumption that omits the CRUD guards, leaving `InsertAllowed`, `ModifyAllowed`, and `DeleteAllowed` at their writable defaults. The endpoint silently accepts POST, PATCH, and DELETE, so a client can mutate or remove data the API was never meant to expose for writing. The detection signal: a read-only/reporting `PageType = API` page that does not set the three `*Allowed = false` properties.

See sample: `disable-write-operations-on-read-only-api-pages.bad.al`.
