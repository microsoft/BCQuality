---
bc-version: [all]
domain: performance
keywords: [page-trigger, onaftergetrecord, modify, display, scroll, db-write]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not Modify inside OnAfterGetRecord

## Description

A list page's `OnAfterGetRecord` fires once per visible row, every time the user scrolls, sorts, or refreshes. A `Modify` inside that trigger means a database write per row displayed. Per the upstream guidance, "`Modify()` here means a DB write on every scroll. Use page variables for display-only state instead." `OnAfterGetCurrRecord` (single record on selection), `OnOpenPage`, and `OnInit` fire once or at much lower frequency and tolerate one-time setup logic.

## Best Practice

When the trigger needs to compute display-only state per row, write the result into a page variable (a global on the page object) rather than back to the database. Reserve `Modify` for triggers that fire on an explicit user action — `OnAction`, validation triggers, `OnQueryClosePage` — where one action maps to one write.

See sample: [`do-not-modify-in-onaftergetrecord.good.al`](do-not-modify-in-onaftergetrecord.good.al).

## Anti Pattern

`trigger OnAfterGetRecord() begin Rec."Warning Flag" := CalcWarning(); Rec.Modify(); end;` — on a list page over a moderately sized table, scrolling through fifty rows produces fifty writes. The page feels slow, the table accumulates churn, and the warning flag — which is recomputed on every refresh anyway — never needed persistence.

See sample: [`do-not-modify-in-onaftergetrecord.bad.al`](do-not-modify-in-onaftergetrecord.bad.al).
