---
bc-version: [all]
domain: performance
keywords: [setup-table, temporary, bounded-table, metadata, migration, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not flag performance on inherently bounded tables

## Description

Several categories of Business Central tables are so small, so rarely accessed, or so in-memory that performance heuristics that make sense on Item Ledger Entry produce noise when applied to them. Temporary records (`TableType = Temporary`, `SourceTableTemporary = true`) live in memory and any access pattern is fast. Singleton setup tables (`Sales & Receivables Setup`, `General Ledger Setup`, `*Setup` tables generally) hold one row per company. Small bounded tables — enum mappings, permission objects, Role IDs — count in the dozens. System metadata tables (`TableMetadata`, `Field`, `AllObjWithCaption`) are bounded by the object catalog. Admin, Migration, Setup, Wizard, and Hybrid* pages are used infrequently with small datasets.

## Best Practice

Skip performance findings on these categories unless the code is specifically pathological (unbounded loop that multiplies cost non-linearly). A missing SetLoadFields on a singleton Setup table is not a finding. A Count on a 30-row permission mapping is not a finding. An admin page that iterates a bounded list once per invocation is not a finding. Reserving reviewer attention for the tables where it matters is half the value of the heuristics — noise on bounded tables trains authors to ignore the signal.

## Anti Pattern

Flagging `SalesReceivablesSetup.Get()` followed by `SetLoadFields()` on a handful of fields as "missing partial record optimization". Flagging a `FindSet` + loop on `Role ID` mapping because the loop has no SetCurrentKey. Flagging a Migration codeunit for writing many records, when the entire migration runs once per customer. All three burn author attention on cases that are not regressions.
