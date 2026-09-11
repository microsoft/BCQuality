---
bc-version: [all]
domain: style
keywords: [api-page, camelcase, apipublisher, apigroup, entityname, entitysetname]
technologies: [al]
countries: [w1]
application-area: [all]
---

# API pages use camelCase, alphanumeric-only values for API properties

## Description

API pages — pages declared with `PageType = API` — surface as OData/JSON endpoints. The strings that appear in the URL (`APIPublisher`, `APIGroup`, `EntityName`, `EntitySetName`) and the JSON payload field names follow different naming rules from the rest of AL. They must be camelCase and use only alphanumeric characters: no hyphens, no underscores, no spaces, no punctuation. `'Contoso-App'`, `'contoso_app'`, and `'contoso.app'` are all rejected. The same rule applies to page field names exposed via `Name = '…'` on API page controls — those names appear verbatim in the JSON keys.

## Best Practice

Pick camelCase identifiers up front: `APIPublisher = 'contoso'`, `APIGroup = 'app1'`, `EntityName = 'customer'`, field `Name = 'displayName'`. Keep them short — they end up in URL paths and JSON keys that every consumer types.

See sample: [`api-page-camelcase-properties.good.al`](api-page-camelcase-properties.good.al).

## Anti Pattern

`APIPublisher = 'Contoso-App'` (hyphen rejected, capitalization wrong for camelCase), `EntityName = 'sales_order'` (underscore rejected), or fields exposed with `Name = 'Display Name'` (space rejected). The compiler usually catches these, but the failure mode is opaque and the rename cost on a deployed API is high.

See sample: [`api-page-camelcase-properties.bad.al`](api-page-camelcase-properties.bad.al).
