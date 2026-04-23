---
bc-version: [all]
domain: upgrade
keywords: [upgrade, get, findset, findlast, guard, unblocking]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Guard every database read in upgrade codeunits; never let a missing row block the upgrade

## Description

An unguarded `Record.Get()` raises when the row does not exist; an unguarded `FindSet()` or `FindLast()` raises when the result set is empty. In ordinary runtime code those errors surface to a user who can retry. In an upgrade codeunit they abort the upgrade of the tenant and the customer is blocked from getting to the new version. Real-world data is inconsistent enough — missing lookup rows, empty setup tables, skipped modules — that an unguarded read reliably blocks at least one customer per release.

## Best Practice

Wrap every Get, FindSet, FindFirst, FindLast, and related call in an `if … then` guard. On the not-found path, either exit the current step or log telemetry and continue; never let the upgrade scope raise. `if Customer.FindSet() then;` (statement terminator as the entire body) is an acceptable pattern when only the side effect of positioning matters.

See sample: `guard-every-database-read-in-upgrade-codeunits.good.al`.

## Anti Pattern

`Customer.Get(CustomerNo);` or `SalesHeader.FindLast();` inside an upgrade procedure. One missing row in one tenant turns every future upgrade into a support ticket.

See sample: `guard-every-database-read-in-upgrade-codeunits.bad.al`.
