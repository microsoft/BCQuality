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
dates and date filters). Application code must never call the `WorkDate`
function to set a new value. Doing so changes what the user sees and
defaults to for the rest of their session, as a side effect of running
unrelated business logic — a surprising, hard-to-trace behavior change the
user never asked for and has no visibility into.

This is a call-direction distinction: reading the current work date via
`WorkDate` (or `WorkDate()` with no argument) is fine and common — it is
only the assignment form, `WorkDate(NewDate)`, that is the anti-pattern.

## Best Practice

Read the work date to default a value; never write to it.

See sample: `code-must-not-change-workdate.good.al`.

## Anti Pattern

Setting the work date from within a codeunit, report, or page action
changes session state the user owns, for the duration of a call that has
nothing to do with the user's date preference. If a scenario genuinely
needs a specific date for a calculation, pass or compute that date as a
local variable — never repurpose the session's `WorkDate`.

See sample: `code-must-not-change-workdate.bad.al`.
