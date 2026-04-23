---
bc-version: [all]
domain: performance
keywords: [onaftergetrecord, get, rec, page-runtime, redundant-fetch]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not re-Get the current record inside OnAfterGetRecord

## Description

The page runtime loads the current record before firing `OnAfterGetRecord` — `Rec` already holds the row's values when the trigger body runs. Calling `Rec.Get(...)` (or any equivalent Get against the same key) inside the trigger issues a second database round-trip for data the runtime just fetched. On a list page that displays hundreds of rows during a scroll, this turns into hundreds of wasted round-trips per user interaction. The same concern applies to `OnAfterGetCurrRecord` on card and document pages, though the impact is smaller because the trigger fires per selection rather than per row.

## Best Practice

Read from `Rec` directly. When a helper method needs a different record, pass `Rec` as an argument or let the helper fetch its own lookup once; do not re-Get the current row. If the code truly needs a fresh value because it was modified by another session, design the refresh explicitly — document it in a comment — rather than paying the cost on every trigger fire.

See sample: `do-not-re-get-rec-inside-onaftergetrecord.good.al`.

## Anti Pattern

An `OnAfterGetRecord` trigger body that starts with `AssemblyLineRec.Get("Document Type", "Document No.", "Line No.")` for the same keys the page runtime has already used — the Get restates what `Rec` already holds. Replace with a direct call against `Rec` (`CheckAvailability(Rec)`).

See sample: `do-not-re-get-rec-inside-onaftergetrecord.bad.al`.
