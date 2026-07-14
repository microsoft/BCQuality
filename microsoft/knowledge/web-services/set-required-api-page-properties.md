---
bc-version: [all]
domain: web-services
keywords: [api-page, pagetype-api, apipublisher, apigroup, apiversion, entityname, entitysetname, sourcetable]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Declare API routing properties and an explicit stable version

## Description

An API page needs `APIPublisher`, `APIGroup`, `EntityName`, `EntitySetName`, and a backing `SourceTable` to define its routed entity. `APIVersion` is different: it is optional at the language level and defaults to `beta`. Omitting it therefore does not mean the page has no version; it publishes under the preview contract. A production integration that intends a stable route should set a `vX.Y` version explicitly rather than rely on that default.

## Best Practice

Declare the five routing/entity properties required by the API page and set `APIVersion` explicitly for a stable published contract, for example `'v1.0'`. Expose the record's fields inside a repeater under `area(content)`. Review missing routing metadata as a malformed API definition, but review a missing `APIVersion` as unintended publication under `beta`, not as an unpublished endpoint.

See sample: `set-required-api-page-properties.good.al`.

## Anti Pattern

Leaving out `APIPublisher`, `APIGroup`, `EntityName`, `EntitySetName`, or `SourceTable` leaves the API definition incomplete. A subtler contract defect is declaring all of those but omitting `APIVersion`: the page is exposed as `beta`, which is valid runtime behavior but not the explicit stable route a production client expects.

See sample: `set-required-api-page-properties.bad.al`.
