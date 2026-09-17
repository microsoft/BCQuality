---
bc-version: [all]
domain: style
keywords: [api-page, delayedinsert, insert-trigger, validation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set `DelayedInsert = true` on API pages

## Description

On a normal page, `DelayedInsert = false` is the default: the record is inserted into the table as soon as the user enters the first field, and subsequent fields are written via `Modify` triggers. That model does not work for an API endpoint, where the consumer sends a complete JSON payload in a single request and expects exactly one `Insert` to fire with all fields already populated. `DelayedInsert = true` defers the insert until every field on the page has been assigned, so the `OnInsert` trigger runs once with the full record and `OnValidate` triggers on individual fields run in a predictable order. The convention is that API pages always set `DelayedInsert = true`.

## Best Practice

Declare `DelayedInsert = true` on every page with `PageType = API`. The setting plays well with `Modify(true)` and `Insert(true)` calls inside `OnInsert` and avoids the half-populated record states that otherwise reach validation logic.

See sample: [`api-page-delayedinsert-true.good.al`](api-page-delayedinsert-true.good.al).

## Anti Pattern

Omitting `DelayedInsert` (which defaults to `false`) on an API page. Validation triggers fire on a partially populated record, mandatory-field errors come back to the caller for fields the JSON payload was about to supply, and the API surface produces failures that have no analogue in the UI page model.

See sample: [`api-page-delayedinsert-true.bad.al`](api-page-delayedinsert-true.bad.al).
