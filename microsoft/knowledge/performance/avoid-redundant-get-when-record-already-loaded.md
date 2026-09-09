---
bc-version: [all]
domain: performance
keywords: [get, onaftergetrecord, redundant, page-trigger, rec, already-loaded]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not Get the record the page already loaded

## Description

A list or card page's `OnAfterGetRecord` trigger fires *because* the platform has already fetched a row into `Rec`. Calling `Get` for that same row inside the trigger repeats the read the platform just did. Per the upstream guidance, this is "redundant — record already fetched by page runtime"; the correction is "use `Rec` directly — already loaded." The waste compounds on list pages, where the trigger runs once per row displayed.

## Best Practice

Inside page triggers — `OnAfterGetRecord`, `OnAfterGetCurrRecord`, validation triggers — read from `Rec` (or the trigger's record parameter). The platform exposes the freshly loaded record there for exactly this purpose. Reach for `Get` only when the trigger needs a *different* record than the one being displayed.

See sample: [`avoid-redundant-get-when-record-already-loaded.good.al`](avoid-redundant-get-when-record-already-loaded.good.al).

## Anti Pattern

`AssemblyLineRec.Get("Document Type", "Document No.", "Line No.");` at the top of `OnAfterGetRecord`, when the trigger is on the `Assembly Line` page itself and `Rec` already holds that row. The pattern often appears when a helper that expects a record parameter is invoked from a page trigger and the author writes a `Get` to "freshen" `Rec` rather than passing `Rec` through.

See sample: [`avoid-redundant-get-when-record-already-loaded.bad.al`](avoid-redundant-get-when-record-already-loaded.bad.al).
