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

`SystemId` is an immutable GUID for an inserted record. For persistent API resources it provides an identity that survives renaming a business key, so a stored URL or `@odata.id` does not break when a customer `No.` changes. The convention is `ODataKeyFields = SystemId` with a non-editable `field(id; Rec.SystemId)`. Immutability belongs to that record, not to a logical resource recreated later: a temporary API page that inserts fresh rows on each request does not gain stable cross-request identity merely by exposing their newly generated GUIDs.

## Best Practice

For persistent resources, set `ODataKeyFields = SystemId` and expose it as `field(id; Rec.SystemId)` marked `Editable = false`. Keep the renamable business key as an ordinary field. For a temporary projection, trace how identity is populated and retained: preserving a persistent source's `SystemId` can work, while generating a new GUID per request cannot. A read-only temporary resource with an intentional stable key need not be rewritten to an ephemeral `SystemId`. Require uniqueness and continuity for the logical resource, not a particular field name without its lifetime.

See sample: [`expose-systemid-as-the-api-key.good.al`](expose-systemid-as-the-api-key.good.al).

## Anti Pattern

Addressing a persistent resource by a renamable business field, so renaming invalidates external references. Another unstable design recreates temporary rows and exposes a newly generated `SystemId` as if it identified the same resource across requests. Before recommending a replacement key, establish its stability; absence of `Rec.SystemId` alone is not proof of broken identity.

See sample: [`expose-systemid-as-the-api-key.bad.al`](expose-systemid-as-the-api-key.bad.al).

## References

[Table system fields](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-table-system-fields) documents generated or explicitly assigned `SystemId` values and their per-record immutability.
