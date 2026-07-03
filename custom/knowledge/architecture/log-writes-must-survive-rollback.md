---
bc-version: [all]
domain: architecture
keywords: [logging, rollback, session, transaction, error-log, web-service, telemetry]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Log writes must survive transaction rollback

## Description

The naive instinct when adding logging is to insert the log record inside
the running transaction. That log has a fatal blind spot: when the operation
ERRORS, the transaction rolls back — and takes the log entry with it. The
result is a log that faithfully records every success and silently loses
exactly the failures it exists to capture.

Observed in production design (Wareco IC, 2026-07-02): a log of errors and
duration per web-service call needed entries to persist even when the
business transaction was rolled back. The correct pattern — writing the log
from an ISOLATED SESSION so its commit is independent of the caller's
transaction — had previously cost a developer most of a day to discover.

## Rule

A log whose purpose includes capturing FAILURES must write its entries in a
transaction that is independent of the operation being logged:

1. **Isolated session write:** start a separate session (`StartSession` on a
   codeunit that inserts the log record and commits) so the entry persists
   regardless of what happens to the caller's transaction.
2. The log codeunit does ONE thing: insert + implicit commit. No business
   logic rides along in the isolated session — anything committed there
   escapes the caller's rollback by design.
3. Duration/telemetry fields are captured in the caller and passed as
   parameters — the isolated session must not re-read state that the
   rollback may erase.
4. Logs that only record successes (audit of committed work) may stay in the
   main transaction — this rule targets error/diagnostic logs specifically.

## What NOT to do

- Do not `Insert` the error-log record in the same transaction as the
  operation — the error you most need to see is the one that deletes it
- Do not "fix" it with `Commit` before the risky call — a stray `Commit`
  breaks the caller's atomicity and violates posting-routine rules
- Do not swallow errors to keep the log alive (`if Codeunit.Run then...`
  without re-raising) — the log must observe the failure, not suppress it

## Signal to watch for

A log table whose entries are inserted in the flow they measure, with no
isolated-session writer — combined with any error path. In review: search
callers of the log-insert for surrounding `Insert`/`Post` in the same
transaction scope.

## Message to developer

When an in-transaction error log is found, explain: entries vanish on
rollback, so the log is blind to failures; route the write through an
isolated session (StartSession → insert+commit codeunit) with values passed
as parameters.
