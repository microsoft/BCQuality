---
bc-version: [all]
domain: ui
keywords: [enqueuebackgroundtask, async-calculation, child-session, factbox, cue-tile, onaftergetcurrrecord, responsive-page, read-only]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Offload Slow Read-Only Page Calculations To Background Tasks

## Description
Pages that compute statistics, aggregates, or external lookups inline block the page from rendering until the calculation finishes, producing a visible freeze on FactBoxes, cue tiles, and calculated fields. Business Central provides page background tasks: `CurrPage.EnqueueBackgroundTask` runs a dedicated codeunit in a read-only child session and returns values via `OnPageBackgroundTaskCompleted`, so the page opens immediately and fills in computed values as they arrive. This matters because users should never wait on a calculation they may not need. The mechanism has specific rules that are easy to get wrong, which is why it warrants an explicit pattern.

## Best Practice
Move any noticeable read-only computation off the synchronous render path into a background task. Enqueue from `OnAfterGetCurrRecord` so the task is tied to the currently focused record, and pass small payloads through the `Dictionary of [Text, Text]` input/output, converting types with `Format` and `Evaluate`. Keep each task focused on one value or a small related set rather than one large task, and show a placeholder until results land. Because tasks auto-cancel when the page closes, the record changes, or a same-ID task is re-enqueued, always supply sensible defaults and handle the timeout path in `OnPageBackgroundTaskError` — never let critical functionality depend on completion. For tests, drive the task synchronously with `RunPageBackgroundTask`.

## Anti Pattern
Enqueuing from `OnAfterGetRecord` on a list page fires the task for every row, and each cancels the instant the selection moves to the next row — pure wasted child-session churn; a reviewer spots `EnqueueBackgroundTask` called from `OnAfterGetRecord` (or from `OnOpenPage`, where the record context is not yet stable). The other tell is a task codeunit attempting a database write or `Modify`: background tasks run read-only and the write fails at runtime. Inline heavy calculation directly in `OnAfterGetCurrRecord` with no task at all is the baseline smell — it reintroduces the page freeze the feature exists to remove.
