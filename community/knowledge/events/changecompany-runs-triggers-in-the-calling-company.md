---
bc-version: [all]
domain: events
keywords: [changecompany, cross-company, runtrigger, trigger-event, subscriber, onafterinsertevent, insert, startsession, multi-company]
technologies: [al]
countries: [w1]
application-area: [all]
---

# ChangeCompany leaves triggers and trigger-event subscribers running in the calling company

> Contributions welcome — open a PR to refine or extend this article.

## Description

`ChangeCompany` redirects the data access of one record variable to another company's table. Execution context does not move with it: Microsoft Learn states that triggers still run in the current company, not in the company passed to `ChangeCompany`. Code that knows this usually reaches for `Insert(false)` and copies the trigger's work by hand from the target company's setup. That closes only half of the gap. The runtime raises the database trigger events (`OnBeforeInsertEvent`, `OnAfterInsertEvent`, and their modify, delete, and rename counterparts) on every database operation and only passes the `RunTrigger` flag to the subscriber, so every subscriber that does not exit on `RunTrigger = false` still runs, in the calling company, against the calling company's setup, number series, and companion tables. The row lands in the target company, the side effects land in the caller, and nothing reports an error. The per-row cost of the call is a separate concern, see `changecompany-in-loop-drops-caches`.

## Best Practice

Use `ChangeCompany` to read. Access rights in the target company are still enforced, so reads are safe. When the goal is business data in another company, run the code in that company: `StartSession` takes a company name and runs a codeunit there, so triggers, validation, and subscribers all execute with the target company as their context. Learn notes that a background session costs as much as a user session to start, so batch the work rather than starting one session per row, or let the target company process a hand-off row on its own schedule. A direct cross-company write is acceptable only as such a hand-off into a table the writing extension owns, whose triggers do not read company data and whose trigger-event subscribers exit when `RunTrigger` is false, using `Insert(false)`, `Modify(false)`, or `Delete(false)`, and never `Validate`.

See sample: `changecompany-runs-triggers-in-the-calling-company.good.al`.

## Anti Pattern

An `Insert`, `Modify`, `Delete`, or `Validate` on a record variable after `ChangeCompany(<name>)`, on a table whose triggers or trigger-event subscribers read setup, consume a number series, or write companion rows. With `RunTrigger = true` the trigger code fills the row from the caller's setup. With `RunTrigger = false` the trigger code is skipped, but the subscribers still fire in the caller, so a counter, log, or companion row maintained by a subscriber is written in the wrong company, and a caller that also updates the target by hand counts twice.

Detection signal: a record variable that has had `ChangeCompany` called on it with a company name and is later used with `Insert`, `Modify`, `Delete`, or `Validate`, where the table is not owned by the extension, or has triggers that read company data, or has trigger-event subscribers that do not exit on `RunTrigger = false`. Do not flag reads after `ChangeCompany`; writes with `RunTrigger = false` into an owned table whose triggers do not read company data and whose subscribers exit on `RunTrigger = false`; or `ChangeCompany()` without an argument, which points the variable back at the current company.

See sample: `changecompany-runs-triggers-in-the-calling-company.bad.al`.

## See also

- Record.ChangeCompany method, Remarks — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-changecompany-method
- Record.Insert(Boolean) method, RunTrigger — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-insert-boolean-method
- Record.Delete method, RunTrigger defaults to false — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-delete-method
- OnInsert (Table) trigger, Remarks — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/triggers-auto/table/devenv-oninsert-table-trigger
- Event types, Database trigger events and order of event execution — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-event-types
- OnAfterInsertEvent trigger event, RunTrigger parameter — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/triggers-auto/events/table/devenv-onafterinsertevent-table-trigger
- Session.StartSession method, Company parameter and Remarks — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/session/session-startsession-integer-integer-string-table-method
