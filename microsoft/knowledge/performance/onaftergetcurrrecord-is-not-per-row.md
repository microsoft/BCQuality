---
bc-version: [all]
domain: performance
keywords: [onaftergetcurrrecord, onaftergetrecord, calcfields, n-plus-one, page-lifecycle, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Database work in OnAfterGetCurrRecord is not a per-row or N+1 cost

## Description

`OnAfterGetCurrRecord` fires only when the current/active record changes — typically once when the page opens and once each time the user selects a different row — not once for every row rendered in a list. Database work placed there, such as `CalcFields`, `Get`, or a lookup, therefore runs a bounded number of times driven by user navigation, not multiplied by the number of visible rows. This is unlike `OnAfterGetRecord`, which fires once per row as the page loads records and can create a genuine N+1 pattern. Reviewers sometimes see `CalcFields` or a database call inside a page trigger and assume it runs for every row; the trigger name determines whether that assumption holds.

## Best Practice

Before flagging `CalcFields`, `Get`, or a similar database call in a page trigger as a per-row or N+1 problem, confirm the trigger is `OnAfterGetRecord`, which runs per row. Do not flag the same work in `OnAfterGetCurrRecord`: that trigger runs on current-record change, not for every displayed row.

## Anti Pattern

Reporting `CalcFields` or another database call inside `OnAfterGetCurrRecord` as an N+1 or per-row performance defect, or recommending it be moved out "to avoid running once per row". The trigger does not run per row.

## See also

- `calcfields-in-both-getrecord-triggers-is-not-redundant.md` — the lifecycle distinction between the two triggers.
