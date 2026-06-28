---
bc-version: [all]
domain: web-services
keywords: [api-page, pagetype-api, apipublisher, apigroup, apiversion, entityname, entitysetname, sourcetable]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Declare every required property on a PageType = API page

## Description

An API page projects a table as an OData v4 / API v2 endpoint, but the platform only publishes that endpoint when the page carries the full set of identifying properties: `APIPublisher`, `APIGroup`, `APIVersion`, `EntityName`, `EntitySetName`, and a backing `SourceTable`. These properties are what compose the route — `/api/<publisher>/<group>/<version>/<entitySet>` — so omitting any one of them yields a page that compiles yet never surfaces as a usable endpoint, or surfaces at an unexpected address. An LLM that has mostly seen ordinary list/card pages tends to treat `PageType = API` as a cosmetic switch and forgets the identifying metadata, because a normal page needs none of it. This file is remedial precisely because the missing-property failure is silent: there is no runtime error, only an endpoint that clients cannot reach.

## Best Practice

On every `PageType = API` page set all six properties explicitly: `APIPublisher` (your publisher tag), `APIGroup` (the logical grouping for related entities), `APIVersion` (a `vX.Y` value such as `'v1.0'`), `EntityName` (singular), `EntitySetName` (plural), and `SourceTable` (the projected table). Expose the record's fields inside a single `field(...)` repeater under `area(content)`. Treat the six properties as a mandatory checklist that travels with the `PageType = API` declaration itself.

See sample: `set-required-api-page-properties.good.al`.

## Anti Pattern

Writing a page with `PageType = API` and a `SourceTable` but leaving out `APIPublisher` and `APIGroup` (and, worse, omitting `SourceTable` entirely). The page compiles, so it looks finished, but the endpoint is malformed: with no publisher and group the route cannot be composed, and the entity is never published where an integration expects it. The detection signal: a `PageType = API` page missing one or more of the six identifying properties.

See sample: `set-required-api-page-properties.bad.al`.
