---
bc-version: [all]
domain: performance
keywords: [confirm, strmenu, dialog, transaction, lock, user-interaction]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not hold locks while waiting for the user

## Description

A `Confirm`, `StrMenu`, modal page, or other user prompt issued from inside a write transaction stalls the transaction — and therefore every lock it holds — until the user responds. Per the upstream guidance, "Avoid user interactions (Confirm, StrMenu) inside transactions — they hold locks while waiting for user input." The wait is bounded only by the user; meanwhile other sessions block on whatever this transaction has acquired.

## Best Practice

Sequence the operation so user confirmation happens *before* any database write that takes a lock the prompt holds open. The shape is: ask the user → if confirmed, acquire locks and post. `if Confirm(...) then begin SalesHeader.LockTable(); SalesHeader.Get(DocNo); PostSalesOrder(SalesHeader); end;` keeps the lock window down to the work itself.

See sample: [`avoid-user-prompts-inside-transactions.good.al`](avoid-user-prompts-inside-transactions.good.al).

## Anti Pattern

`SalesHeader.LockTable(); SalesHeader.Get(DocNo); if Confirm('Post this order?') then ...;` — the lock is held for as long as the dialog is up. A user who steps away to lunch holds the lock for an hour, and every other session that touches that row blocks for the duration.

See sample: [`avoid-user-prompts-inside-transactions.bad.al`](avoid-user-prompts-inside-transactions.bad.al).
