---
bc-version: [all]
domain: privacy
keywords: [dataclassification, inheritance, table-level, field-level, override]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Override inherited DataClassification when a field doesn't fit the table default

## Description

When a table declares `DataClassification` at the table level, every field inherits that value unless the field declares its own. This is efficient for homogeneous tables — a SystemMetadata log table whose fields are all system-generated, a CustomerContent transaction table whose fields are all business data. It is a privacy regression when a table is classified SystemMetadata but contains a field that holds personal data: the field silently inherits the wrong classification, and telemetry tooling treats its content as safe to log when it is not.

## Best Practice

Review every field on a table with a table-level DataClassification. Fields whose content matches the table's default need no per-field declaration. Fields that carry a different kind of data — a customer name on an otherwise-system-metadata log table, a personal identifier on a mixed-content table — must declare their own DataClassification that overrides the table default.

See sample: `override-inherited-dataclassification-per-field.good.al`.

## Anti Pattern

A table declared `DataClassification = SystemMetadata` with fields like `Customer Name`, `E-Mail`, `Phone No.` — the fields inherit SystemMetadata, which is wrong for CustomerContent. Subject-access-request and retention tooling treats the personal data as system housekeeping.

See sample: `override-inherited-dataclassification-per-field.bad.al`.
