---
bc-version: [all]
domain: error-handling
keywords: [oninsertrecord, onmodifyrecord, ondeleterecord, onquerypage, boolean-trigger, exit, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Page record triggers return true by default; a missing exit(true) does not block the operation

## Description

The Boolean page record triggers `OnInsertRecord`, `OnModifyRecord`, `OnDeleteRecord`, and `OnQueryClosePage` return `true` by default. When the trigger body omits an explicit return value, the platform treats the result as `true` and the operation proceeds. Only an explicit `exit(false)` — or a reachable code path that returns `false` — cancels the insert, modify, delete, or page close.

This is a defined exception to the ordinary Boolean method rule, where the default return is `false`. Reviewers unfamiliar with the exception sometimes read a page record trigger that has no `exit(true)` and conclude the operation is blocked; it is not.

## Best Practice

Do not claim that a missing `exit(true)` blocks or prevents an insert, modify, or delete, and do not recommend adding `exit(true)` "to let the operation proceed" — that is already the default. Evaluate these triggers only for an explicit or reachable `exit(false)`/false-returning path that would cancel the operation unintentionally.

## Anti Pattern

Flagging `OnInsertRecord`, `OnModifyRecord`, `OnDeleteRecord`, or `OnQueryClosePage` as defective because it "does not return `true`", or asserting that inserts/modifies/deletes will silently fail without an explicit `exit(true)`. The default return already permits the operation.
