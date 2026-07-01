---
bc-version: [all]
domain: security
keywords: [dataclassification, gdpr, privacy, euii, compliance]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Classify every field with DataClassification

## Description

Every field on every AL table and table extension must have a resolved `DataClassification` value, either declared directly on the field or inherited from a table-level default. The value drives GDPR tooling, data-subject requests, retention policies, and audit reporting — all of which rely on the field metadata to know what data to include, anonymize, or delete. A field with no field-level property and no table-level default resolves to `ToBeClassified`, which is a compliance gap, not a neutral state.

## Best Practice

Choose the narrowest value that accurately describes the field's content: `EndUserIdentifiableInformation` for data that directly identifies a person, `EndUserPseudonymousIdentifiers` for indirect identifiers, `CustomerContent` for business operational data, `SystemMetadata` for system-generated housekeeping, `AccountData` for tenant/billing, `OrganizationIdentifiableInformation` for organization-level identifiers. Use a table-level default for homogeneous tables, and override individual fields whose content differs from that default. When uncertain between two values, pick the stronger protection.

See sample: `classify-every-field-with-dataclassification.good.al`.

## Anti Pattern

Leaving `DataClassification = ToBeClassified` on a field, omitting classification when the table has no default, or relying on a table-level default that understates a field's actual content. Code in this state fails compliance audits and breaks the subject-access-request and retention tooling that depends on the property being set correctly.

See sample: `classify-every-field-with-dataclassification.bad.al`.
