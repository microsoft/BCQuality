---
bc-version: [all]
domain: performance
keywords: [limited-during-write-transactions, write-transaction, runmodal, form-runmodal, page-runmodal, report-runmodal, xmlport-runmodal, codeunit-run, commit, requestpage]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL methods limited during write transactions: commit before RunModal and Codeunit.Run

## Description

Once AL code has written to the database in the current transaction — an `Insert`, `Modify`, or `Delete` with no `Commit` since — the platform restricts four methods until that transaction is committed. The exact conditions, as enforced:

- `Page.RunModal` — not allowed in a write transaction, under any circumstances.
- `Report.RunModal` — allowed only if the request page is suppressed: `Report.RunModal(ReportId, false)` (the second argument is `RequestWindow`), or `UseRequestPage(false)` on a report instance. With a request page it fails.
- `XmlPort.RunModal` — same rule: allowed only if the request page is suppressed, `XmlPort.RunModal(..., false)`. With a request page it fails.
- `Codeunit.Run` — allowed only if its Boolean return value is not used. `OK := Codeunit.Run()` and `if Codeunit.Run() then` fail, because that form commits — see `codeunit-run-requires-prior-commit-inside-transaction.md`.

This is a runtime error, not a compiler diagnostic: the code builds, and the first execution that reaches the call with an open write transaction dies. The guard keys on transaction state alone, not on any relation between what was written and what is opened: an `Item.Insert()` followed by `Page.RunModal(Page::"Customer Card")` — an unrelated table — fails on the `RunModal` line, and because the error stops the transaction, the insert rolls back with it.

The platform's message (Business Central 26, reproduced 2026-09-07) reads: "The following AL methods are limited during write transactions because one or more tables will be locked: Form.RunModal, Codeunit.Run, Report.RunModal, XmlPort.RunModal. Form.RunModal is not allowed in write transactions. Codeunit.Run is allowed in write transactions only if the return value is not used. For example, 'OK := Codeunit.Run()' is not allowed. Report.RunModal is allowed in write transactions only if 'RequestForm = false'. For example, 'Report.RunModal(...,false)' is allowed. XmlPort.RunModal is allowed in write transactions only if 'RequestForm = false'. For example, 'XmlPort.RunModal(...,false)' is allowed. Use the commit method to save the changes before this call, or structure the code differently." The message still uses the legacy names `Form.RunModal` and `RequestForm` even though the AL method is `Page.RunModal` and the report parameter is `RequestWindow`; older versions said "C/AL functions" instead of "AL methods" (microsoft/AL#5452, 2019). The behavior is unchanged across versions.

The reason is the same one behind `avoid-user-prompts-inside-transactions.md`: a modal object waits for the user, and the platform will not let a write transaction — and every lock it holds — sit open for as long as that takes. The difference is enforcement. `Confirm` and `StrMenu` are *allowed* inside a write transaction and silently hold the locks; `RunModal` is *refused*. Both point at the same design fix.

## Best Practice

Sequence the work so the modal interaction happens before the write phase: run the lookup or dialog page first, then perform the writes the user's choice requires, and let the transaction end. When a modal object genuinely must follow a write, `Commit()` first — but only when the state written so far is complete and safe to persist on its own, because that Commit is a real transaction boundary, not a formality. Microsoft's own Base Application follows exactly this pattern where the preceding state is final (`ActivityLog.Table.al` commits the log entry before `Page.RunModal(Page::"Activity Log", Rec)`; `DocumentSendingProfile.Table.al` commits before `Page.RunModal(Page::"Select Sending Options", …)`). For a report or XMLport, suppressing the request page (`UseRequestPage(false)`) is a legitimate way to run it inside a write transaction when no user input is needed. `Database.IsInWriteTransaction()` (runtime 11.0+) lets library code that cannot control its caller detect the state, with the same caveat as the Codeunit.Run article: branching production flow on it usually signals unclear transaction ownership.

See sample: `al-methods-limited-during-write-transactions.good.al`.

## Anti Pattern

Writing to the database and then calling `Page.RunModal` (or a report/XMLport with its request page) in the same trigger — the first production run hits the runtime error. The reflexive fixes are worse than the error: dropping in `Commit()` to silence it persists a half-finished state that can no longer roll back with the rest of the operation, and swapping the page for a `Confirm` or `StrMenu` to "avoid the error" trades a loud failure for the silent lock-holding that `avoid-user-prompts-inside-transactions.md` warns about.

See sample: `al-methods-limited-during-write-transactions.bad.al`.

## Source

- Microsoft Learn, `Codeunit.Run` transaction semantics ("If you're already in a transaction you must commit first before calling Codeunit.Run"): https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/codeunit/codeunit-run-method
- microsoft/AL issue #5452 (verbatim English error text, reproduced on "any current version of Business Central", 2019-11-13): https://github.com/microsoft/AL/issues/5452
- Reproduced 2026-09-07 on Business Central 26 (runtime error dialog, English and Danish clients): a page `OnAction` doing `Item.Insert()` then `Page.RunModal(Page::"Customer Card")` fails with the text quoted in the Description, the AL call stack pointing at the `RunModal` line, and the dialog stating that the transaction was stopped.
- Microsoft Base Application (BCApps, W1): the `Commit(); … Page.RunModal(…)` pattern in `Modules/System/Logging/ActivityLog.Table.al`, `Foundation/Reporting/DocumentSendingProfile.Table.al`, `Bank/Setup/PaymentServiceSetup.Table.al`, and others; BCApps test suites annotate the same guard as "COMMIT is required for Write Transaction Error" (`Tests/General Journal/ERMTestMultipleGenJnlLines.Codeunit.al`).
