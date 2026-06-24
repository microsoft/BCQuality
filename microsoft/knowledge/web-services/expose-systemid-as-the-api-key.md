---
bc-version: [all]
domain: web-services
keywords: [api-page, odatakeyfields, systemid, stable-key, guid, business-key, editable-false]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Address API records by SystemId, not by a renamable business key

## Description

Every BC table carries a `SystemId` — an immutable GUID assigned at insert and never reused. API consumers must address a record through a key that does not change, otherwise a previously stored URL or `@odata.id` reference breaks the moment a user renames the underlying business key. The convention is to set `ODataKeyFields = SystemId` on the API page and expose the GUID as a non-editable `field(id; Rec.SystemId)`. An LLM left to its own devices often reaches for the human-readable primary key (a customer `No.`, an item code) as the OData key, because that is what a developer types when filtering in AL. That choice is wrong for an external contract: business keys are renamable and the API caller's stored references would dangle. This file is remedial because the correct key (`SystemId`) is rarely the one the model would pick by analogy with ordinary AL code.

## Best Practice

Set `ODataKeyFields = SystemId` so OData routes records by the stable GUID, and expose it as `field(id; Rec.SystemId)` marked `Editable = false`. Clients then address a record at `.../customers(<guid>)`, an identity that survives any rename of the business key. Keep the business key (for example `No.`) as an ordinary exposed field, not as the OData key.

See sample: `expose-systemid-as-the-api-key.good.al`.

## Anti Pattern

Setting `ODataKeyFields = "No."` so the endpoint addresses records by a renamable business field. As soon as a user changes that `No.`, every external reference built on the old value points at nothing, silently breaking integrations. The detection signal: `ODataKeyFields` set to a business field rather than `SystemId`, or an API page that exposes no `id` field bound to `Rec.SystemId`.

See sample: `expose-systemid-as-the-api-key.bad.al`.
