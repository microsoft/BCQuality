---
bc-version: [all]
domain: web-services
keywords: [api-page, least-privilege, write-access, odata, security, external-api, identity-fields]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Give API pages least-privilege write access

## Description

A general-purpose API page that exposes many fields should not be widened to allow writes on one additional field. A `PageType = API` page consumed by an external integration, an automation agent, or a partner system carries the same risk regardless of caller: a write-enabled page with no per-field restriction is a wide-open surface. Least privilege has to cover both dimensions of exposure: which fields are on the page, and which operations the page allows. Only a field actually placed on the page is reachable at all — but a page that includes many fields, with `InsertAllowed`/`ModifyAllowed`/`DeleteAllowed` left at their defaults and no `Editable = false` on most of them, leaves every one of those included fields — identity fields and financially significant ones among them — fully writable, with nothing marking that as deliberate. Restricting fields alone is not enough either: a page with only two fields on it can still let a caller insert brand-new records or delete existing ones if `InsertAllowed`/`DeleteAllowed` are left at their true defaults (both `true`).

## Best Practice

Create a separate, minimal API page that exposes only the key and the specific field the consumer needs to write, with everything else `Editable = false` or simply absent from the page — and set `InsertAllowed`/`DeleteAllowed` to `false` unless the consumer's use case genuinely needs to create or delete records through that page.

See sample: `api-page-least-privilege-write-access.good.al`.

## Anti Pattern

Widening an existing general-purpose API page with write access to one field, leaving every other field on the page (including identity and posting fields) writable by default because no one added `Editable = false`.

See sample: `api-page-least-privilege-write-access.bad.al`.
