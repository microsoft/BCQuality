---
bc-version: [all]
domain: data-modeling
keywords: [tablerelation, field-length, code, text, conditional-relation, lookup]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A TableRelation field's length must match the related field

## Description

`TableRelation` points a field at another table, or at a specific field of it with `Table.Field`. The relation is also used to validate entries and to drive the lookup. A referencing field that is shorter than the related field compiles without a length diagnostic: verified with AL compiler 30.0 and the CodeCop, UICop and PerTenantExtensionCop analyzers. Compare `AL0685`, which does warn about an analogous length mismatch for a FlowField's `CalcFormula` target.

A shorter field compiles cleanly and works for every value that happens to fit. It fails only when a real related value is longer than the field. For example, a `Code[10]` field related to a table with a `Code[20]` key fails when a 15-character code is assigned or validated into it. The runtime error reads "The length of the string is N, but it must be less than or equal to M characters."

The length Business Central's own relation check expects depends on whether the field has an unconditional relation:

- **At least one unconditional relation**, either a plain `TableRelation = X` or an unconditional branch: the field must have the **exact** length of the longest related field and the same type.
- **Only conditional relations** (`if (...) X else if (...) Y`): the field must be **at least** as long as the longest related field. A longer field is accepted.

For the type, the check requires the related field's type, or `Text` when the related fields mix `Code` and `Text`. Only under all-conditional relations, and only when the required type is `Code`, may the field be `Text` instead.

The check skips any field that sets `ValidateTableRelation = false` or `TestTableRelation = false`. The Base Application sets `ValidateTableRelation = false` on filter and totaling fields, which hold a filter expression rather than one key value. Such a field may be longer than the related field. A field that is shorter than the related field is still a defect even with either property set to `false`, because a real related value still overflows it at runtime.

The check is codeunit 134926 "Table Relation Test" in the BC test app. Its validation test is `[Scope('OnPrem')]`, so it runs only on an on-premises test surface. It is not a compile-time guarantee. See [`table-relation-test-exclude-known-invalid-relations-via-event.md`](../testing/table-relation-test-exclude-known-invalid-relations-via-event.md) for how that check evaluates relations and how to exclude a known exception.

## Best Practice

Before you add or change a `TableRelation`, read the declared type and length of every related field from its table definition. Lengths vary from table to table, so don't assume a typical `Code[10]` or `Code[20]`. Then size the field:

- For an unconditional relation, give it the same type and exact length as the related field, unless the field holds a filter expression and sets `ValidateTableRelation = false`.
- For an all-conditional relation, make it at least as long as the longest branch target.

When a `tableextension` adds a branch with `modify(...)`, check the new target's length against the field's existing declaration too.

See sample: [`tablerelation-field-length-must-match-related-field.good.al`](tablerelation-field-length-must-match-related-field.good.al).

## Anti Pattern

A field whose declared `Code`/`Text` length is shorter than the field it relates to. One example is a `Code[10]` field with `TableRelation` to a table keyed on `Code[20]`. Another is a conditional relation where one branch targets a longer field than the declaration. Both compile without a diagnostic and fail at runtime once a real, longer value is used. This applies whether or not `ValidateTableRelation` or `TestTableRelation` is `false`. The Base Application has an instance: "Financial Report Schedule"."Excel Template Code" is `Code[20]` and relates, with a `where` filter, to "Fin. Report Excel Template".Code, which is `Code[50]`.

A field that is longer than its related field under an unconditional relation, with neither `ValidateTableRelation` nor `TestTableRelation` set to `false`, is a lesser deviation. It holds every valid value, but it is rejected by codeunit 134926's check and accepts values that can never satisfy the relation.

See sample: [`tablerelation-field-length-must-match-related-field.bad.al`](tablerelation-field-length-must-match-related-field.bad.al).

Related: [`transferfields-mirrored-fields-must-match-type-and-length.md`](transferfields-mirrored-fields-must-match-type-and-length.md) covers the same length-mismatch failure between fields that `TransferFields` connects.

## Source

- [TableRelation property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-tablerelation-property): syntax `<TableName>[.<FieldName>]`, conditional `IF ... ELSE` relations, and use of the relation to validate entries.
- [Compiler Warning (future error) AL0685](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al685): the analogous FlowField length diagnostic, which warns that the mismatch "could result in a runtime error".
- BCApps [`src/Layers/W1/Tests/Misc/TableRelationTest.Codeunit.al`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/Tests/Misc/TableRelationTest.Codeunit.al): line 46 says "Fields must have the exact length of the largest field they relate to". Lines 48-49 skip a field unless both "Test Table Relation" and "Validate Table Relation" are true. Lines 68-84 apply `Field.Len < MaxRelatedFieldLength` when every relation is conditional and `Field.Len <> MaxRelatedFieldLength` otherwise. Line 15 is `[Scope('OnPrem')]`.
- [ValidateTableRelation property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-validatetablerelation-property) and [TestTableRelation property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-testtablerelation-property): both default to `true`, and setting `ValidateTableRelation` to `false` should be paired with `TestTableRelation = false`.
- Deliberately longer filter fields with `ValidateTableRelation = false` in BCApps W1 Base Application:
  - [`src/Layers/W1/BaseApp/Warehouse/Request/WarehouseSourceFilter.Table.al`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Warehouse/Request/WarehouseSourceFilter.Table.al) lines 44-49: "Variant Code Filter" `Code[100]` relates to "Item Variant".Code (`Code[10]`).
  - [`src/Layers/W1/BaseApp/Finance/Analysis/AnalysisViewFilter.Table.al`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Finance/Analysis/AnalysisViewFilter.Table.al) lines 49-54: "Dimension Value Filter" `Code[250]` relates to "Dimension Value".Code (`Code[20]`).
  - [`src/Layers/W1/BaseApp/Projects/Project/Job/JobTask.Table.al`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Projects/Project/Job/JobTask.Table.al) lines 290-295: Totaling `Text[250]` relates to "Job Task"."Job Task No." (`Code[20]`).
- BCApps [`src/Layers/W1/BaseApp/Finance/FinancialReports/FinancialReportSchedule.Table.al`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Finance/FinancialReports/FinancialReportSchedule.Table.al) lines 48-51: "Excel Template Code" `Code[20]` relates to [`FinReportExcelTemplate.Table.al`](https://github.com/microsoft/BCApps/blob/main/src/Layers/W1/BaseApp/Finance/FinancialReports/FinReportExcelTemplate.Table.al) field Code (`Code[50]`, line 33), an instance of the shorter-field anti-pattern.
- BCApps [`src/Apps/W1/Subcontracting/Test/Tests/SubcCommentsAttachmentTest.Codeunit.al`](https://github.com/microsoft/BCApps/blob/main/src/Apps/W1/Subcontracting/Test/Tests/SubcCommentsAttachmentTest.Codeunit.al) line 295 asserts the runtime text "The length of the string is 101".
