---
bc-version: [all]
domain: performance
keywords: [locktable, updlock, transaction, contention, scope]
technologies: [al]
countries: [w1]
application-area: [all]
---

# LockTable applies to the whole table for the rest of the transaction

## Description

`Record.LockTable` is commonly read as "lock this record variable", but it does not work that way. The call applies `WITH (UPDLOCK)` to every subsequent read against the underlying table in the current transaction, regardless of which record variable issues the read. If `ItemA.LockTable` runs, then an unrelated `ItemB` variable on `Item`, a `FindSet` from a helper codeunit on `Item`, and any nested code that reads `Item` all acquire UPDLOCK until the transaction commits.

The consequence is that calling LockTable early in a transaction — for example at the top of a routine "to be safe" — upgrades every read of that table for the remainder of the transaction to a writer-blocking lock. Contention scales with transaction length, not with how many writes the code actually performs. A LockTable deep in a call graph can silently serialize readers that never touch the LockTable-ing variable.

## Best Practice

Defer `LockTable` as late as possible and place it as close to the actual modification as you can. Keep transactions short so the UPDLOCK window is narrow. Do not add LockTable preemptively to "protect" a read that is not part of a read-modify-write sequence — the correct tool for read consistency is an isolation level (see Record.ReadIsolation), not a write lock.

## Anti Pattern

A procedure that calls `Rec.LockTable()` at the start "before doing anything" and then performs a long read-heavy validation before the eventual Modify. Every read in the validation now takes UPDLOCK on the whole table, and every other session that tries to read the same table waits on this transaction.
