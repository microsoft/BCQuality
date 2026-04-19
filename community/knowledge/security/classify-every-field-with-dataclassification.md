---
bc-version: [26..28]
domain: security
keywords: [dataclassification, gdpr, privacy, euii, compliance]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Classify every field with DataClassification

> **Seed article.** Ported from BC Code Intelligence to seed the community corpus. Community contributors are invited to expand or refine.

## Description

Every field on every AL table and table extension must carry an explicit `DataClassification` property. The value drives GDPR tooling, data-subject requests, retention policies, and audit reporting — all of which rely on the field metadata to know what data to include, anonymize, or delete. A field with no `DataClassification` defaults to `ToBeClassified`, which is a compliance gap, not a neutral state.

## Best Practice

Choose the narrowest value that accurately describes the field's content: `EndUserIdentifiableInformation` for data that directly identifies a person, `EndUserPseudonymousIdentifiers` for indirect identifiers, `CustomerContent` for business operational data, `SystemMetadata` for system-generated housekeeping, `AccountData` for tenant/billing, `OrganizationIdentifiableInformation` for organization-level identifiers. When uncertain between two values, pick the stronger protection.

See sample: `classify-every-field-with-dataclassification.good.al`.

## Anti Pattern

Leaving `DataClassification = ToBeClassified` on a field, or omitting the property entirely (which resolves to the same default). Code in this state fails compliance audits and breaks the subject-access-request and retention tooling that depends on the property being set correctly.

See sample: `classify-every-field-with-dataclassification.bad.al`.
