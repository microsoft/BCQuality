---
bc-version: [17..]
domain: web-services
keywords: [api-page, enum, enum-value-name, rename, ordinal, caption, schemaversion, breaking-change, dataverse, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Under OData schema version 2.0 an API enum field is a contract by member name; under 1.0 it is the caption

> Contributions welcome — open a PR to refine or extend this article.

## Description

What an API page publishes for an enum field depends on the OData `$schemaversion` the caller receives, and never on the ordinal. Under schema 2.0 the field is a strongly typed enum: `$metadata`, every response and every `$filter` carry the AL member **names**, and captions are published separately through `entityDefinitions`. Under schema 1.0 the same field is `Edm.String` and responses carry the en-US **caption**. Microsoft's API v2.0 is always schema 2.0. Custom APIs defaulted to schema 1.0 through BC 23; BC 24 changed the default to 2.0, and a caller can still pin `?$schemaversion=1.0`. Dataverse virtual tables build on API v2.0 and match choices by the value's External Name, with the integer values documented as not stable.

LLMs treat one carrier as universal. Some assume the caption is serialised and report every caption change as an API break; others assume the name is serialised and wave a rename through when its ordinal and caption are kept. Each is right for one schema version and wrong for the other, and neither knows that the schema version decides. Page-shape changes are covered by `version-apis-by-adding-not-mutating-published-versions.md`; ordinal stability for persisted rows by `enum-values-additive-at-end.md`. This article is about the values inside one exposed field.

## Best Practice

Establish which schema versions the field is served under before changing anything about its enum. Under schema 2.0 (Microsoft's API v2.0, an explicit `$schemaversion=2.0` in the consumer contract, or another reliable context signal) the member name is the contract: keep names stable, put wording changes in `Caption`, add a value by appending a new name with an ordinal above every existing one, and retire a value through `ObsoleteState` rather than by deleting it. For a custom API that clients may still call as schema 1.0, any install of BC 17 to 23 or a caller that pins 1.0, the caption is a contract as well: change neither name nor caption in place, or publish the change as a new `APIVersion` on a new page object. A rename is out in every case: AppSourceCop AS0082 rejects it against a baseline, and dependent extensions bind to the name.

See sample: `api-enum-values-are-a-contract-by-name-not-ordinal.good.al`.

## Anti Pattern

Renaming a value on an enum that an API page field exposes while keeping its ordinal and caption, or re-pointing an API page field at a source field whose enum carries different member names. Under schema 2.0 every consumer that filters on, posts, or maps the old name fails at runtime and Dataverse choices built on the old External Name stop matching; AS0082 reports the rename only when AppSourceCop runs against a baseline package, and nothing reports the re-pointed field.

Detection signal: a diff hunk that changes the name in a `value(...)` line while keeping its ordinal, on an enum used by a table field that a `PageType = API` page exposes; or an API page `field(...)` whose source expression moves to a field of another enum type.

The mirror image is a review defect: suppressing a caption-change finding because "the API serialises names". That holds only under schema 2.0. Do not flag a `Caption` change when the reviewer can establish schema 2.0 for every consumer; on a custom API where clients may select schema 1.0, report a caption change on an exposed value as a consumer-visible change and ask for versioning. A value appended at the end changes no contract under either schema and is never a finding.

See sample: `api-enum-values-are-a-contract-by-name-not-ordinal.bad.al`.

## See also

Deprecated features in the platform, Schema version for custom APIs (changed default in BC 24) — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/upgrade/deprecated-features-platform#changes-in-2024-release-wave-1-version-240

Transitioning from API v1.0 to API v2.0, Enums and Schema version — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/api-reference/v2.0/transition-to-api-v2.0#enums

Working with Virtual Tables, Table fields — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/powerplatform/powerplat-entity-modeling#table-fields

AppSourceCop AS0082 (rename) — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0082 and AS0083 (delete) — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0083
