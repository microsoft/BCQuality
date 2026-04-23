---
bc-version: [all]
domain: performance
keywords: [setloadfields, partial-record, blob, bandwidth]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use SetLoadFields for partial records

## Description

SetLoadFields instructs the platform to hydrate only the listed fields on a record variable. On wide tables, or tables with BLOB or media fields, the difference is substantial: a Sales Invoice Line has dozens of fields and loading all of them for every row of a large set is wasted bandwidth. Primary key fields, SystemId, and system audit fields are always loaded automatically. SetLoadFields works only with FieldClass = Normal; FlowFields and FlowFilters cannot be partial-loaded.

## Best Practice

Call SetLoadFields before FindSet, FindFirst, or Get whenever the code path only reads a subset of fields. List every field that is read during the operation, including fields used in filters, calculations, and downstream function calls. Omitting a field that is later accessed triggers a second round-trip.

See sample: `use-setloadfields-for-partial-records.good.al`.

## Anti Pattern

Iterating a large set and reading only two or three fields without SetLoadFields forces the platform to transport every column for every row, including BLOBs and unused text fields.

See sample: `use-setloadfields-for-partial-records.bad.al`.

