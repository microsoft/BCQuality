---
bc-version: [all]
domain: style
keywords: [api-page, apiversion, entityname, entitysetname, apipublisher, apigroup, delayedinsert]
technologies: [al]
countries: [w1]
application-area: [all]
---

# API pages follow strict naming and property rules that differ from regular pages

## Description

Pages declared `PageType = API` are exposed through the OData API surface. The platform enforces a set of conventions that regular pages do not share: `APIPublisher`, `APIGroup`, `EntityName`, and `EntitySetName` must be camelCase alphanumeric only — no spaces, hyphens, or underscores. `APIVersion` must match the pattern `vX.Y` (for example `v2.0`) or the literal `beta`. `EntityName` is the singular form (`customer`); `EntitySetName` is the plural (`customers`). `DelayedInsert = true` is effectively required for the OData insert workflow to behave correctly on composite keys. These rules are platform-enforced and tooling-enforced; violations produce runtime errors or consumer-visible inconsistencies rather than soft warnings.

## Best Practice

For every API page: camelCase alphanumeric API properties; `APIVersion` as `vX.Y` or `beta`; singular `EntityName` and plural `EntitySetName`; `DelayedInsert = true`. Keep these properties together near the top of the page definition so reviewers can check the set at a glance.

See sample: `follow-api-page-naming-rules.good.al`.

## Anti Pattern

`APIPublisher = 'Contoso-App'` (hyphen rejected), `EntityName = 'customers'` and `EntitySetName = 'customer'` (swapped), `APIVersion = 'v2'` (missing minor version), `DelayedInsert` omitted. Each violation surfaces only when a consumer exercises the endpoint.

See sample: `follow-api-page-naming-rules.bad.al`.
