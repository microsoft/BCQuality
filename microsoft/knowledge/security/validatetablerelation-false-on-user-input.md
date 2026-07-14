---
bc-version: [all]
domain: security
keywords: [validatetablerelation, tablerelation, field, validation, input]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Handle free-form input when ValidateTableRelation is false

## Description

`ValidateTableRelation = false` intentionally lets a user keep free-form input even when it does not match `TableRelation`. This is supported for scenarios such as accepting a new vendor name and handling it in `OnValidate`. The risk is not the property itself; it is leaving downstream code to assume that every value identifies an existing related record.

## Best Practice

Keep the default validation when values must exist in the related table. When free-form values are intentional, set both `ValidateTableRelation = false` and `TestTableRelation = false`, then add compensating `OnValidate` logic that normalizes, validates, creates, or otherwise handles unmatched input. Document that downstream code must not assume the relation exists. See sample: `validatetablerelation-false-on-user-input.good.al`.

## Anti Pattern

`ValidateTableRelation = false` on a user-facing field with no intentional handling for unmatched values, or leaving `TestTableRelation = true` so database relation tests reject values the UI deliberately accepts. See sample: `validatetablerelation-false-on-user-input.bad.al`.
