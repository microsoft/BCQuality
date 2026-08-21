---
bc-version: [15..]
domain: performance
keywords: [page-background-task, cue, rolecenter, enqueuebackgroundtask, ui-thread]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Calculate expensive cues on a page background task

> Contributions welcome — open a PR to refine or extend this article.

## Description

Role-center cues and CardPart totals that run `CalcFields`, scans, or HTTP on the UI thread freeze the shell until they finish. Page background tasks exist to return the page immediately and fill the number later. Enqueue mechanics, cancellation, and the read-only child session are covered in `microsoft/knowledge/ui/page-background-tasks.md`. This file is the performance trigger: a cue whose value is not needed to *open* the page must not run on the render path.

## Best Practice

Bind the cue to a page variable, enqueue a read-only calculation from `OnAfterGetCurrRecord` (not `OnAfterGetRecord` on a list), and apply the result in `OnPageBackgroundTaskCompleted`. Show a placeholder until then.

See sample: `page-background-tasks-for-expensive-cues.good.al`.

## Anti Pattern

`CalcFields` or a ledger `Count` in `OnOpenPage` / `OnAfterGetCurrRecord` of a CueGroup CardPart with no background task. The Role Center waits on SQL the user may never look at.

See sample: `page-background-tasks-for-expensive-cues.bad.al`.
