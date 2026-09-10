---
bc-version: [all]
domain: data-modeling
keywords: [workdate, session-setting, user-control, side-effect]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Application code must not change the WorkDate

## Description

The work date is a per-user session setting the user controls from the
client (the date shown in the top-right corner, used to default posting
dates and date filters). Business logic unrelated to that setting must not
call `WorkDate(NewDate)` as a side effect of doing something else — that
silently changes what the user sees and defaults to for the rest of their
session, a surprising, hard-to-trace behavior change the user never asked
for and has no visibility into. This is not a blanket ban on the setter
itself: BCApps' own demo-data generators legitimately save the current
work date, set a specific one to backdate the data they create, and
restore it afterward (see `CreateDemoEDocsBE.Codeunit.al`'s
`WorkDate(SampleInvoiceDate)` / `WorkDate(SavedWorkDate)` pair), and test
codeunits routinely set `WorkDate` deliberately to control the date context
a test runs under (hundreds of calls across BCApps' test suite, for
example `SustainabilityPostingTest.Codeunit.al`). Both are the code's
*actual purpose*, not a side effect of something unrelated.

This is a call-direction distinction for the read side: reading the
current work date via `WorkDate` (or `WorkDate()` with no argument) is
always fine.

## Best Practice

Read the work date to default a value. Only write to it when changing it
*is* the operation being performed — implementing the user's own
work-date/settings action, or a test or demo-data routine that deliberately
establishes a date context (saving and restoring the prior value if the
routine must leave the session as it found it). Business logic that exists
to do something else must never write `WorkDate` as an incidental side
effect; if a calculation needs a specific date, pass or compute that date
as a local variable instead.

See sample: `code-must-not-change-workdate.good.al`.

## Anti Pattern

Setting the work date from within a codeunit, report, or page action whose
purpose is unrelated to the user's date preference — for example, a
posting or calculation routine that calls `WorkDate(SomeDate)` to make its
own logic simpler. This changes session state the user owns for the
duration of a call that was never about the work date, and never restores
it. This is a different case from a test or demo-data routine explicitly
declaring a date context: the anti-pattern is unrelated logic silently
mutating state it does not own, not the setter form itself.

See sample: `code-must-not-change-workdate.bad.al`.
