---
bc-version: [all]
domain: performance
keywords: [readisolation, locktable, updlock, read-only, transaction-scope, isolation-level]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer ReadIsolation over LockTable for read-only scenarios

## Description

Without read scale-out, `LockTable` causes subsequent reads of that table in the transaction to use `UPDLOCK`. With read scale-out, those reads use `REPEATABLEREAD` on the replica instead. `ReadIsolation` selects an isolation level for one record instance. A helper that only reads should not broaden locking for the table merely to request committed data.

## Best Practice

For a read-only operation that specifically requires committed data, set `Rec.ReadIsolation := IsolationLevel::ReadCommitted` immediately before the read. If the default isolation is sufficient, set neither property. `ReadCommitted` can still block behind writers and does not guarantee that repeated reads stay unchanged; use the isolation level required by the operation. Reserve update locks for read-before-write logic, not read-only helpers.

See sample: `prefer-readisolation-over-locktable-for-reads.good.al`.

## Anti Pattern

`Rec.LockTable();` at the top of a helper that only reads, perhaps to "make sure the read is consistent". It takes stronger isolation than the helper needs and changes later reads of that table in the surrounding transaction or read-scale-out session.

See sample: `prefer-readisolation-over-locktable-for-reads.bad.al`.
