---
bc-version: [all]
domain: web-services
keywords: [api-page, key-fields, editable, insert, odata]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep Consumer-Provided Key Fields Editable on API Pages

> Contributions welcome — open a PR to refine or extend this article.

## Description

A field listed in `ODataKeyFields` cannot have `Editable = false` when the API page allows inserts and the field's value must be supplied by the caller. Marking it read-only removes the field from the OData write schema, so a POST that includes it is rejected as an unknown property. This only applies to keys the consumer must supply — a system-generated key such as `SystemId` is a valid exception, since Business Central assigns its value automatically on insert.

## Best Practice

Leave every consumer-supplied key field referenced in `ODataKeyFields` without `Editable = false` on pages where `InsertAllowed = true`, so the OData layer accepts it as a writable property on POST.

See sample: `api-page-key-fields-must-be-editable-on-insert.good.al`.

## Anti Pattern

Marking a consumer-provided key field `Editable = false`, out of habit or for perceived safety. This silently breaks create operations with a generic `BadRequest` instead of a clear validation error.

See sample: `api-page-key-fields-must-be-editable-on-insert.bad.al`.
