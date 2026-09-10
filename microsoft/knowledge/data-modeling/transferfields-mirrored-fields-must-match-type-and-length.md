---
bc-version: [all]
domain: data-modeling
keywords: [transferfields, field-number, posting-cascade, schema-design, custom-field]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Mirrored TransferFields cascade fields must match type and length exactly

## Description

Most custom fields genuinely belong to only one table — a status used
only before posting, a note relevant only afterwards, whatever the case
may be. That is the ordinary, unremarkable default, and it needs no
justification: `TransferFields` never touches a field that doesn't exist
on the destination. Per Microsoft's own documentation, a source field's
contents are copied "if such a field exists" on the destination with a
matching field number — a field defined on only one side of a posting
cascade is simply outside `TransferFields`' reach, not a gap to fix.

The narrower case this rule addresses is when a field **is** deliberately
mirrored across a known cascade — the same field number reused on
another table specifically so the value survives posting, for example a
field added to both `Sales Header` (36) and `Sales Invoice Header` (112),
which `SalesPost.Codeunit.al` connects via
`SalesInvHeader.TransferFields(SalesHeader)`. The two definitions have to
agree on type and, less obviously, on length. A field defined `Text[100]`
on `Sales Header` and `Text[50]` on `Sales Invoice Header` compiles
cleanly on both sides, and the `TransferFields` call runs without error
for every value up to 50 characters. Per Microsoft's documentation, a
runtime error only occurs when there isn't "room for the actual length
of the contents of the field to be copied" — so nothing fails while test
data, or early production data, stays short. The error surfaces only the
day an actual value finally exceeds the shorter definition, on a document
type that may have been posting cleanly for months.

See also `transferfields-skip-type-mismatch-can-drop-data.md`, which
covers `SkipFieldsNotMatchingType = true` silently skipping a *type*
mismatch between same-extension fields. That parameter has no effect on
length: two fields of the same type but different length still raise the
runtime error described above regardless of how `SkipFieldsNotMatchingType`
is set, which is the distinct failure mode this article addresses.

## Best Practice

When mirroring a field across a `TransferFields` cascade, define it with
the exact same field number, data type, and length on every table in
that cascade, at creation time. A field intentionally left local to one
table is unaffected by this and needs no mirroring at all — this is a
consistency requirement between definitions that are already meant to be
linked, not a mandate to check every field against every table on the
cascade.

See sample: `transferfields-mirrored-fields-must-match-type-and-length.good.al`.

## Anti Pattern

The same field number added to two tables that `TransferFields` connects
in a posting cascade (e.g. `Sales Header` (36) and `Sales Invoice Header`
(112), linked by `SalesPost.Codeunit.al`), with a shorter length — or an
incompatible data type — on one side. Both definitions compile without
error; nothing fails until an actual value exceeds the shorter one, which
typical test data never does.

See sample: `transferfields-mirrored-fields-must-match-type-and-length.bad.al`.

## Source

Microsoft Learn, `Record.TransferFields(var Record [, Boolean])`:
"The `TransferFields` method copies fields based on the field number on
the fields. For each field in `Record` (the destination), the contents
of the field that has the same field number in `FromRecord` (the source)
will be copied, **if such a field exists**." And: "The fields must have
the *same data type* for the copying to succeed... There must be room
for the actual length of the contents of the field to be copied in the
field to which it is to be copied. If any one of these conditions aren't
fulfilled, a runtime error will occur."
(https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-transferfields-table-boolean-method)

BCApps `SalesPost.Codeunit.al` (`src/Layers/W1/BaseApp/Sales/Posting/`):
`SalesShptHeader.TransferFields(SalesHeader);` (line 7104),
`ReturnRcptHeader.TransferFields(SalesHeader);` (line 7166),
`SalesInvHeader.TransferFields(SalesHeader);` (line 7220),
`SalesCrMemoHeader.TransferFields(SalesHeader);` (line 7275) — the real
cascade a mirrored field on `Sales Header` (36) is checked against.
