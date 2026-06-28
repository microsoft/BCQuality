---
bc-version: [all]
domain: web-services
keywords: [api-page, apiversion, versioning, published-contract, breaking-change, backward-compatibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Version APIs by adding a new APIVersion, not by mutating a published one

## Description

Once an API version is published, external clients depend on its exact shape — the entity name, the set of exposed fields, the key — as a frozen contract. Changing any of that on the already-published version is a breaking change delivered silently: integrations that worked yesterday fail today with no warning. The platform gives you a clean way to evolve without breaking anyone, because `APIVersion` accepts a *list* of versions on one page. The correct way to change a published API is to add the new version (`'v2.0'`) alongside the existing one (`'v1.0'`) — or publish a new API page for it — so both contracts are served side by side and clients migrate on their own schedule. LLMs tend to "fix" an API by editing the live version in place, because in ordinary code you just change what's wrong; this file is remedial because a published API version is an immutable contract in a way ordinary internal code is not.

## Best Practice

When a published API must change shape, keep the old version's contract intact and add the new one to the `APIVersion` list — `APIVersion = 'v2.0', 'v1.0';`. The page now serves both `v1.0` (unchanged) and `v2.0` (carrying the new shape), so existing clients keep working while new clients adopt `v2.0`. Retire the old version only after consumers have migrated.

See sample: `version-apis-by-adding-not-mutating-published-versions.good.al`.

## Anti Pattern

Editing the published `v1.0` page in place — renaming its `EntityName` or removing an exposed field — so the single declared version now serves a different contract than the one clients integrated against. Every consumer of the old shape breaks without notice. The detection signal: a change that renames the entity or removes a field on an existing published `APIVersion` instead of adding a new version to the list.

See sample: `version-apis-by-adding-not-mutating-published-versions.bad.al`.
