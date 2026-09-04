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

A general-purpose API page that exposes many fields should not be widened to allow writes on one additional field. A `PageType = API` page consumed by an external integration, an automation agent, or a partner system carries the same risk regardless of caller: a write-enabled page with no per-field restriction is a wide-open surface. The most common real-world shape of this problem is not a page that started narrow and got widened — it is a page that was never restricted at all: with `InsertAllowed`/`ModifyAllowed`/`DeleteAllowed` left at their defaults and no `Editable = false` on any field, every field on the source table — including identity fields and financially significant ones — is fully writable, with nothing marking that as deliberate.

## Best Practice

Create a separate, minimal API page that exposes only the key and the specific field the consumer needs to write, with everything else `Editable = false` or simply absent from the page.

See sample: `api-page-least-privilege-write-access.good.al`.

## Anti Pattern

Widening an existing general-purpose API page with write access to one field, leaving every other field on the page (including identity and posting fields) writable by default because no one added `Editable = false`.

See sample: `api-page-least-privilege-write-access.bad.al`.
