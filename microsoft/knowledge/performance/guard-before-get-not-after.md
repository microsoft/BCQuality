---
bc-version: [all]
domain: performance
keywords: [get, guard, early-exit, wasted-fetch, conditional]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Place guard conditions before Get, not after

## Description

A `Record.Get(Key)` is a database round-trip. When the call site also contains an early-exit condition that may fire before the fetched record is used, the order of the two matters: `Get` first followed by a guard that may exit means every call pays the round-trip, including the calls that immediately return. Flipping the order — evaluate the guard first, `Get` only when needed — costs nothing in the happy path and turns the wasted round-trip into zero work on the exit path. The savings compound on hot tables and on code paths entered many times per user action.

## Best Practice

Evaluate cheap, in-memory conditions first. Only issue the `Get` (or `FindFirst`, `FindLast`) when the subsequent code actually needs the record's values. For complex procedures with multiple exit conditions, sort them cheapest-first: in-memory checks, then single-record lookups, then set iteration.

See sample: `guard-before-get-not-after.good.al`.

## Anti Pattern

`PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No."); if PurchaseLine."Selected Alloc. Account No." = '' then exit;` — the Get fires on every call; the exit discards the result for every call where `Selected Alloc. Account No.` is blank.

See sample: `guard-before-get-not-after.bad.al`.
