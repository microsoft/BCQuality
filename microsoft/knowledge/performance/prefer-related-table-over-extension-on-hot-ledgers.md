---
bc-version: ["23.."]
domain: performance
keywords: [tableextension, companion-table, gl-entry, related-table, flowfield, hot-table]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer a related table over stored fields on hot ledgers

> Contributions welcome — open a PR to refine or extend this article.

## Description

Since v23, all extensions on the same base table share at most one companion-table join, and the platform automatically excludes that join on List, ListPart, and OData pages when partial records are in effect and no extension field is loaded. However, the join is still paid on every posting path and any AL code that accesses an extension field — or that runs without partial-record semantics. On hot tables — G/L Entry, Item Ledger Entry, Cust. Ledger Entry — even a single access per posted row adds up at volume. A related table keyed by the ledger `Entry No.`, optionally surfaced with a FlowField or FactBox, leaves the base read path entirely untouched. Agents extend G/L Entry because it is "where the posting already is".

## Best Practice

Put optional, sparse, or integration attributes in a related table with the ledger entry number as primary key. Show them from a FactBox or a FlowField. 
Use a tableextension stored field only when the value must appear as a native list column and is read on almost every access.

See sample: `prefer-related-table-over-extension-on-hot-ledgers.good.al`.

## Anti Pattern

`tableextension` on `"G/L Entry"` (or another posting table) that adds several stored `Text`/`Blob` fields used only by one integration. The companion join is paid on every posting and on any AL code path that loads extension fields, even when those columns are not needed for the current operation.

See sample: `prefer-related-table-over-extension-on-hot-ledgers.bad.al`.
