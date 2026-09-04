---
bc-version: [all]
domain: error-handling
keywords: [logging, rollback, session, transaction, isolated-session, telemetry]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Log writes that must capture failures must survive transaction rollback

## Description

Inserting a log record inside the same transaction as the operation it logs looks correct until the operation errors: the transaction rolls back and takes the log entry with it. The result is a log that faithfully records every success and silently loses exactly the failures it exists to capture. This is a common blind spot in error/duration logging around web-service calls, background jobs, and other operations expected to fail sometimes.

## Best Practice

Write any log whose purpose includes capturing failures from a transaction that is independent of the operation being logged: start an isolated session (`StartSession` on a codeunit that only inserts the log record and commits) so the entry persists regardless of what happens to the caller's transaction. Capture duration and other telemetry values in the caller and pass them as parameters — the isolated session must not re-read state that a rollback may have erased. Logs that only record successful, committed work can safely stay in the main transaction; this pattern targets error and diagnostic logs specifically.

See sample: `log-writes-must-survive-rollback.good.al`.

## Anti Pattern

Inserting the error-log record in the same transaction as the risky operation, so a rollback deletes the very entry meant to explain the failure. Adding a stray `Commit` before the risky call is not a fix either — it breaks the caller's atomicity and can violate posting-routine rules. Swallowing the error to keep the log alive (running a codeunit without checking or re-raising its result) is equally wrong: the log must observe the failure, not suppress it.

See sample: `log-writes-must-survive-rollback.bad.al`.
