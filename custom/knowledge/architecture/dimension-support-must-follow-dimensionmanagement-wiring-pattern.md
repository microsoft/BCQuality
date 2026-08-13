---
bc-version: [all]
domain: architecture
keywords: [dimensions, dimensionmanagement, global-dimension, shortcut-dimension, default-dimension, validateshortcutdimcode, createdim, captionclass]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Dimension support must follow the DimensionManagement wiring pattern

## Description

Wiring a new custom master table or document table into Business
Central's dimension system isn't a matter of adding a `Code[20]` field and
calling it done — it requires a specific set of hooks into
`DimensionManagement` (codeunit 408) so the value is validated, persisted,
and flows into transactions the same way it does for every standard
master/document table. Skipping any one of these hooks produces a
dimension field that looks right in the designer but silently fails to
save, validate, or carry through to postings.

## Wiring a Master Table (e.g. a new "Instructor" or "Course" table)

1. **Fields:** add `Global Dimension 1 Code` / `Global Dimension 2 Code`
   (`Code[20]`), each with `TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1/2), Blocked = const(false))`
   and `CaptionClass` set to `'1,1,1'` / `'1,1,2'` — this is what lets
   Codeunit 42 (Caption Class) show the company's actual dimension name
   (e.g. "Department Code") instead of the generic field name.
2. **Validation:** add a `ValidateShortcutDimCode` function that calls
   `DimensionManagement.ValidateDimValueCode` then
   `DimensionManagement.SaveDefaultDim`; call it from each dimension
   field's `OnValidate` trigger.
3. **Lifecycle:** the table's `OnInsert`/`OnDelete` triggers must call
   `DimensionManagement` to create/delete the corresponding Default
   Dimension (table 352) records tied to that master record — the master
   record and its default dimensions must be created and destroyed
   together.
4. **Table ID registration:** if the master table's key is referenced
   through a `TypeToTableID`-style option in `DimensionManagement`
   (`SetupObjectNoList`/`TableIDArray`), that logic must be extended to
   include the new table, or dimension lookups involving it will resolve
   to the wrong table.

## Wiring a Document Table (header/line)

Add `Shortcut Dimension 1 Code` / `Shortcut Dimension 2 Code` fields (the
remaining six shortcut dimensions are entered through a separate
Dimensions window, not as physical fields). Call `ValidateShortcutDimCode`
from each field's `OnValidate`. Call a `CreateDim` function — which pulls
dimension values from the related master record — whenever the field
that attaches the document to a master record changes (e.g. when
`Bill-to Customer No.` changes on a header, or when a line's `Type`/`No.`
changes). This is the same model the Sales Header table uses when the
Bill-to Customer changes.

## Review Checklist

1. Do the dimension fields have the correct `TableRelation` filtered to
   `Global Dimension No. = 1`/`2` and `Blocked = false`, and the matching
   `CaptionClass`?
2. Is `ValidateShortcutDimCode` wired to each dimension field's
   `OnValidate` — not left to a bare `TableRelation` with no validation?
3. Do `OnInsert`/`OnDelete` create/delete the Default Dimension records,
   so master records and their dimensions can't get out of sync?
4. If the table is referenced via a `TypeToTableID`-style option, was
   `SetupObjectNoList`/`TableIDArray` actually extended?
5. For a document table: does `CreateDim` run whenever the
   master-record-attaching field changes, so dimensions flow in
   automatically rather than requiring the user to re-enter them?

## Source

CURABIS Academy course "The Developers Guide through AL" (rev. July
2022), Chapter 8: Dimensions & Debugging, "Code Walkthrough - Dimension
Management Codeunit", "Solution Design - DimensionManagement Codeunit",
"Solution Design - Global Dimension Fields", "Dimensions in Documents",
"Solution Design - Shortcut Dimension Fields" (p. 262–268). Cross-checked
against the current Base Application `DimensionManagement` codeunit (408)
and the `Customer`/`Sales Header` table wiring as of 2026-08-13 — the
pattern still holds.
