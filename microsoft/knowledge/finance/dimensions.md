---
bc-version: [1..99]
domain: finance
keywords: [dimensions, default-dimension, dimension-set, codeunit-408, global-dimension]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Dimensions

## Description

Dimensions are analytical tags — Department, Project, Region, etc. — attached to every posting so financial reports can filter and group by business attributes without adding columns to every ledger table. Two representations coexist: Default Dimensions (table 352) declare per-record defaults on masters (customer, vendor, item, G/L account, employee), and Dimension Set Entries (table 480) record the actual combinations carried on each ledger entry. A Dimension Set ID on a ledger entry references the exact set of dimension values; multiple entries sharing a set reuse the same ID rather than duplicating rows.

Codeunit 408 (`Dimension Management`) is the central broker: it resolves defaults into concrete sets at posting time, deduplicates sets, and enforces dimension combination rules. It also owns the merge logic that walks document header, document line, and master-data defaults to produce the final set.

Default Dimensions carry one of four rules per dimension: Code Mandatory (posting blocks without a value), Same Code (the value must match the master's default exactly), No Code (posting blocks if any value is provided), or blank (free choice, no constraint). The rule is enforced at post time, not at entry; user-interface entry may allow setting values that later fail posting.

## Best Practice

Set Global Dimension 1/2 on every master that drives dimension analysis; this prepopulates document lines without users remembering to add them.

## Anti Pattern

Introducing a new required dimension mid-year without backfilling existing open documents. Posting will fail for every document whose header was created before the rule existed.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "Dimensions — The #1 Source of Finance Issues") on 2026-04-21. To be refined in Phase 2 from `D:\Repos\NAV\App\Layers\W1\BaseApp\Foundation\Dimensions\`.
