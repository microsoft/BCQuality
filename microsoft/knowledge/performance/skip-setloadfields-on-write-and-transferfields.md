---
bc-version: [all]
domain: performance
keywords: [setloadfields, partial-record, jit-load, modify, insert, transferfields, write-path]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Skip SetLoadFields on write and copy paths

> Contributions welcome — open a PR to refine or extend this article.

## Description

`SetLoadFields` is a read optimization. The platform's [partial-record usage guidelines](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-partial-records#usage-guidelines) list the operations that require every field to already be present: `Insert`, `Delete`, `Rename`, `TransferFields`, and copying a record into a temporary table. When those operations run on a partial record, the platform issues a just-in-time load of the missing fields. That extra round-trip costs more than loading the full row on the original `FindSet` or `Get`. Note: `Modify` itself is **not** in this list — a `Modify(false)` that only touches loaded fields is safe with a partial record.

## Best Practice

Omit `SetLoadFields` on loops whose body performs a documented full-load operation (`Insert`, `Delete`, `Rename`, `TransferFields`, or assignment into a temporary record) on the same record variable, so the initial read already materializes every field those operations need.

See sample: `skip-setloadfields-on-write-and-transferfields.good.al`.

## Anti Pattern

Calling `SetLoadFields` immediately before a `FindSet` whose body performs `Delete`, `Rename`, `TransferFields`, or copies the record into a temporary table. The review signal is a partial-record setup on a record variable that feeds one of these documented full-load operations in the same iteration.

See sample: `skip-setloadfields-on-write-and-transferfields.bad.al`.
