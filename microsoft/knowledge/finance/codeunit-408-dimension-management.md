---
bc-version: [1..99]
domain: finance
keywords: [codeunit-408, dimension-management, dimension-merge, high-risk, dimension-set]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Codeunit 408 (Dimension Management)

## Description

Codeunit 408 is the central broker for every dimension operation in Business Central. It resolves Default Dimensions into concrete Dimension Set Entries, deduplicates sets by Dimension Set ID, merges header/line/master-data defaults during posting, enforces Dimension Combination rules, and owns the API that every other module uses to read or write dimensions. Sales, Purchase, Manufacturing, Warehouse, Fixed Assets, and Job posting all call into this codeunit; the codeunit is also how BC-internal UI controls retrieve the dimension values shown on a document.

A modification here propagates to every posted dimension, across every module. The blast radius is not bounded by "we only customised Sales" — a change to the merge logic that Sales happens to exercise may shift dimensions on a Job Journal that shares no code with Sales. Subscribers to codeunit 408's integration events are safe; direct modifications are a high-risk change that frequently produces silent drift (dimension values on ledger entries that are defensible line by line but produce wrong totals in the financial statements).

## Best Practice

Extend only via the published integration events or by subscribing to business-layer events that codeunit 408 emits during its lifecycle. Review every dimension-related extension as part of every BC upgrade to confirm its event subscribers still fire.

## Anti Pattern

Writing to Dimension Set Entries (table 480) from custom code to "fix" a miscategorised entry. The set is shared across many entries; editing the set retroactively reclassifies every entry that referenced it, usually in ways the author did not intend.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "High-Risk Areas") on 2026-04-21.
