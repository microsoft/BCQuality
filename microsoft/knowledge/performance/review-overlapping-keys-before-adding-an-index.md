---
bc-version: [all]
domain: performance
keywords: [overlapping-keys, redundant-index, includedfields, sift, write-amplification, index-portfolio, key, setrange]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Review overlapping keys as a portfolio

## Description

Adding a secondary key to a frequently written table maintains another SQL index for every affected write. Several keys with the same leading fields might be serving distinct filters, sort orders, unique constraints, or SIFT aggregates; they might instead be redundant payload variants. A shared prefix, absent `SetCurrentKey` calls, or low usage in a short window is not proof that a key is unused.

## Best Practice

Before adding or removing a key, inventory keys from the table and installed extensions and identify each key's consumers and purpose: seek, ordering, uniqueness, or aggregation. Check `SQLIndex`, `MaintainSQLIndex`, `SumIndexFields`, and `MaintainSIFTIndex`, not only the AL key name. For *confirmed* payload-only variants on BC 19 or later, a single nonclustered key with `IncludedFields` can be a consolidation candidate (see [covering keys](design-covering-keys-from-read-pattern.md)); an included field cannot replace a key column used for ordering or a maintained SIFT sum. Measure representative read and write workloads, including periodic reports, integrations, and other companies, before and after a supported extension/schema change. Retain a rollback path for a critical reader that regresses. See sample: [`review-overlapping-keys-before-adding-an-index.good.al`](review-overlapping-keys-before-adding-an-index.good.al).

## Anti Pattern

Keeping another customer/date key for each displayed field without checking whether the trailing fields support distinct operations. Conversely, merging `(Customer, Date)` with `(Customer, Item, Date)` merely because they share a prefix can regress item-selective queries; removing a unique key or a SIFT aggregate changes more than write cost. Do not report a key as unused solely because AL never calls `SetCurrentKey` on it. See sample: [`review-overlapping-keys-before-adding-an-index.bad.al`](review-overlapping-keys-before-adding-an-index.bad.al).

## References

- [Table keys: benefits, costs, and constraints](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-table-keys).
- [IncludedFields property](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-includedfields-property).
- [Manage index usage (BC 2026 release wave 1 and later)](https://learn.microsoft.com/en-us/dynamics365/business-central/manage-indexes).
- [SIFT read/write trade-off](choose-maintainsiftindex-by-read-write-ratio.md).
