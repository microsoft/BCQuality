---
bc-version: [all]
domain: ui
keywords: [request-page, onqueryclosepage, onprereport, closeaction, mandatory-input, report-validation, job-queue]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Validate request-page input in OnQueryClosePage, not only in OnPreReport

> Contributions welcome — open a PR to refine or extend this article.

## Description

`OnPreReport` runs after the request page has closed and before the data items are processed. A validation error raised there aborts the run with the request page already gone: everything the user typed is lost, and the only way forward is to open the report again and retype it. The request page's own `OnQueryClosePage` trigger runs while the page is still open, and the platform does not close a page whose `OnQueryClosePage` raises an error or returns `false` — so the same check placed there leaves the user in front of their input, with the offending field still filled in and correctable. Moving the check rather than duplicating it fails the other way: a report can run with no request page at all — `Report.Run`/`Report.RunModal` with the request window suppressed, `UseRequestPage = false`, job queue entries, scheduled and web-service invocations — and `OnQueryClosePage` never fires on those paths.

## Best Practice

Put the validation in one local procedure and call it from both places: from the request page's `OnQueryClosePage`, so an interactive user can correct the input where they entered it, and from `OnPreReport` (or the relevant `OnPreDataItem`), so a run without a request page is still refused. Guard the interactive call on the close action — validate only when the user confirmed the run, for example `if CloseAction = Action::OK then`. The base application uses this shape; report 292, `Copy Sales Document`, validates its request-page input in `OnQueryClosePage` behind a close-action check. Mark the control with `ShowMandatory` as well, so the requirement is visible before the user submits — see `showmandatory-on-code-required-page-fields.md`. See sample: `validate-request-page-input-in-onqueryclosepage.good.al`.

## Anti Pattern

Validating mandatory request-page input only in `OnPreReport`. The check is correct and the report is never run with bad input, but every interactive mistake costs the user the whole request page: the error arrives after the page is gone, and filters, dates, and options all have to be entered again. Reviewer signal: a `TestField`, `Error`, or blank/zero-value check in `OnPreReport` or `OnPreDataItem` against a variable that is bound to a request-page control, in a report whose request page declares no `OnQueryClosePage`.

The mirror defect is an `OnQueryClosePage` that validates without inspecting `CloseAction`: because an error prevents the page from closing, a user who presses Cancel or Esc to abandon the report is trapped in a request page that errors on every attempt to leave it. Validating only in `OnQueryClosePage` is the third variant — the interactive path behaves well, and a job queue entry runs the report with unchecked input. See sample: `validate-request-page-input-in-onqueryclosepage.bad.al`.

## See also

`OnQueryClosePage` (Request Page) trigger — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/triggers-auto/requestpage/devenv-onqueryclosepage-requestpage-trigger

`OnPreReport` (Report) trigger — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/triggers-auto/report/devenv-onprereport-report-trigger
