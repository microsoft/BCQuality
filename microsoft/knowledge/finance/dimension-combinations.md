---
bc-version: [1..99]
domain: finance
keywords: [dimension-combination, blocked-combination, dimension-matrix, dimension-value-combination]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Dimension combinations

## Description

Dimension Combinations (tables 350 — `Dimension Combination`, and 351 — `Dimension Value Combination`) are the guardrail that restricts which dimension values may coexist on the same posting. Table 350 records pair-level rules for two dimensions (typically Global Dimension 1 and Global Dimension 2): the pair may be Blocked, Limited (only specific value pairs allowed), or blank (free). Table 351 records the allowed value pairs under a Limited combination. The check runs during posting via codeunit 408; when a rejected pair arrives on a Dimension Set, posting fails with a specific error naming the blocked combination.

Combinations are the right mechanism for organisational rules like "the Marketing department cannot post to the Factory location" — they enforce once, at post time, across every document type. They are the wrong mechanism for user-input validation (they do not fire until post), and they are often surprising to users who see them for the first time years into a deployment because they were set up once and forgotten.

## Best Practice

When introducing a new blocked combination, run a what-if query against open documents and journal batches first. Existing lines whose dimensions already violate the new rule will fail posting as soon as the rule activates; fix those lines before turning it on.

## Anti Pattern

Using Dimension Combinations to simulate permission checks. They gate posting, not data entry, and they fire in every module — a combination added to enforce a Sales workflow may suddenly block a General Journal entry no one expected.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "Dimensions — The #1 Source of Finance Issues") on 2026-04-21.
