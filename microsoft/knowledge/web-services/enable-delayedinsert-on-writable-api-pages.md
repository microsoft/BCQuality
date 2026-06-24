---
bc-version: [all]
domain: web-services
keywords: [api-page, delayedinsert, writable-api, insert-trigger, mandatory-fields, partial-record]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set DelayedInsert = true on writable API pages

## Description

When a client POSTs a new record to an API page, the platform receives the posted fields one at a time. Without `DelayedInsert = true`, the page can insert the row as soon as the first field is assigned — before the remaining fields in the payload have been applied. That premature insert fails mandatory-field and table validation that depends on fields arriving later, or it persists a partial record that violates the table's invariants. Setting `DelayedInsert = true` defers the actual `Insert` until every posted field has been assigned, so validation sees the complete record. The official API page template ships with this property set. LLMs that generate an API page by analogy with an ordinary editable page routinely omit it, because interactive pages do not need it; this file is remedial because the default is a footgun specific to the API/POST flow.

## Best Practice

On any API page that accepts inserts (a writable entity), set `DelayedInsert = true`. The platform then collects all posted fields and inserts the row once, after assignment is complete, so mandatory-field checks and `OnInsert` validation run against the full record. Treat `DelayedInsert = true` as a default for every writable API page, exactly as the standard API page template does.

See sample: `enable-delayedinsert-on-writable-api-pages.good.al`.

## Anti Pattern

A writable API page that omits `DelayedInsert`. On a POST the platform may insert the row on the first assigned field, before the rest of the payload lands — failing validation that needs the later fields, or leaving a half-populated record behind. The detection signal: a writable `PageType = API` page (one that allows inserts) with no `DelayedInsert = true`.

See sample: `enable-delayedinsert-on-writable-api-pages.bad.al`.
