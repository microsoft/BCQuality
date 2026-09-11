---
bc-version: [all]
domain: performance
keywords: [locktable, read-only, helper, contention, transaction]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not LockTable in a read-only procedure

## Description

`LockTable` is a transaction-wide signal: from the call onward, every read against that table in the same transaction acquires `UPDLOCK`. Per the upstream guidance, "`LockTable()` before Modify/Insert/Delete in the same procedure is the correct pattern" — locking the read against the write that follows is what the call exists for. The anti-pattern is "`LockTable()` in read-only procedures — unnecessary lock contention": the procedure never writes, but the lock cost is paid by everyone sharing the transaction.

## Best Practice

Reserve `LockTable` for the read directly before a `Modify`, `Insert`, or `Delete` that depends on the read value. If a helper is sometimes called for reading and sometimes for writing, split it into separate read and write paths and call `LockTable` only on the write path. For read-only existence checks or lookups, the right primitive is `ReadIsolation` (see `prefer-readisolation-over-locktable-for-reads.md`).

See sample: [`do-not-locktable-in-read-only-procedure.good.al`](do-not-locktable-in-read-only-procedure.good.al).

## Anti Pattern

A pure getter that opens with `Rec.LockTable();`. Every caller's transaction now acquires `UPDLOCK` on that table for every subsequent read until commit. The contention shows up as blocking on unrelated sessions whose own code path looks innocent — the locker is invisible to the blocked reader.

See sample: [`do-not-locktable-in-read-only-procedure.bad.al`](do-not-locktable-in-read-only-procedure.bad.al).
