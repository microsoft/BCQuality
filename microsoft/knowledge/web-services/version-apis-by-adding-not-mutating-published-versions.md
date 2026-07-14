---
bc-version: [all]
domain: web-services
keywords: [api-page, apiversion, versioning, published-contract, breaking-change, backward-compatibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Version changed API shapes with a new page object

## Description

Once an API version is published, external clients depend on its exact shape — entity names, fields, keys, and behavior — as a stable contract. `APIVersion` can list several versions on one API page, but every listed route is generated from that same page object and therefore exposes the same shape. Adding `'v2.0'` to a page and then changing its fields changes what both `v1.0` and `v2.0` serve. To preserve the v1 shape while introducing a different v2 shape, keep the v1 page unchanged and create a separate page object for v2.

## Best Practice

Keep the existing page object and its `APIVersion = 'v1.0'` contract unchanged. Copy the page to a new object ID, set that object's `APIVersion = 'v2.0'`, and make the v2-only shape changes there. A multi-value `APIVersion` list is appropriate only when the exact same page shape is supported under each listed version.

See sample: `version-apis-by-adding-not-mutating-published-versions.good.al`.

## Anti Pattern

Editing the published `v1.0` page in place breaks its clients. So does adding `v2.0` to that same page and assuming subsequent field changes apply only to v2: both routes use one object shape. The detection signal is a breaking shape change without a separate API page object retaining the old version.

See sample: `version-apis-by-adding-not-mutating-published-versions.bad.al`.
