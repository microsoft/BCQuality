---
bc-version: [all]
domain: upgrade
keywords: [get, findset, findlast, guard, if-then, runtime-error]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Guard every database read in upgrade code with `if`

## Description

Inside an upgrade codeunit (or any procedure transitively invoked from `OnUpgradePerCompany` / `OnUpgradePerDatabase`), an unguarded `Record.Get`, `Record.FindSet`, or `Record.FindLast` raises a runtime error when the row or set is missing. In upgrade context that error aborts the entire upgrade for the company or database — a far worse outcome than the missing data itself. Records the upgrade reasons about may legitimately not exist on every customer's tenant.

## Best Practice

Wrap every read in an `if`. `if Item.Get(No) then ...`, `if Customer.FindSet() then;`, `if not Vendor.FindLast() then exit;`. The empty-then form `if Customer.FindSet() then;` is the idiomatic way to attempt a read whose only purpose is to position a record, while swallowing the "not found" case.

See sample: [`guard-database-reads.good.al`](guard-database-reads.good.al).

## Anti Pattern

Calling `Item.Get()`, `Customer.FindSet()`, or `Vendor.FindLast()` bare in upgrade code. The first tenant whose data does not match the upgrade's assumptions will fail to upgrade.

See sample: [`guard-database-reads.bad.al`](guard-database-reads.bad.al).
