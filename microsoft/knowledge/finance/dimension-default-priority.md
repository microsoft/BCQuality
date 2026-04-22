---
bc-version: [1..99]
domain: finance
keywords: [dimension-default, dimension-priority, posting-conflict, dimension-merge, troubleshooting]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Dimension default priority

## Description

At post time, Business Central merges dimension values from several sources into the final Dimension Set for each ledger entry. The merge honours a priority order: document header defaults (copied from customer/vendor at document creation) are the base, document line defaults overlay header (customer/vendor/item/G/L account defaults applied line by line), and line-level user edits overlay the defaults. For Gen. Journal posting, G/L Account default dimensions are applied inside codeunit 12 after the line is otherwise finalised. Dimension Combinations (tables 350/351) are a final gate that may reject the merged set outright.

The single most common posting error in finance is a conflict during this merge: a line-default mandatory dimension conflicts with a header-default Same Code rule, or a Dimension Combination rejects a pair that neither source knew about. Users see the error only at post time, often long after the values were set. Troubleshooting requires tracing back through each source layer.

## Best Practice

When a post fails on dimensions, inspect in this order: (1) the error message's named conflict, (2) Default Dimensions on every master referenced by the document (customer, vendor, items, G/L accounts), (3) the Dimension Combination matrix, (4) document-header dimensions for staleness (a header-level change does NOT cascade to existing lines; if the header was re-coded after lines were entered, line defaults no longer match).

## Anti Pattern

Manually forcing a Dimension Set ID on a ledger entry to bypass the merge. The entry then carries a set that does not match its source defaults, and next-period reports silently disagree with the journal audit trail.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (sections: "Dimensions — The #1 Source of Finance Issues", "Dimension Conflict Troubleshooting") on 2026-04-21.
