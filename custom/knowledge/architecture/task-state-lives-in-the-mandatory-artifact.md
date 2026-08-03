---
bc-version: [all]
domain: architecture
keywords: [task-state, persistence, resumability, bc-task, pull-request, pte, appsource, lifecycle, operator-handoff]
technologies: [al, mcp]
countries: [w1]
application-area: [all]
---

# Task State Lives in the Mandatory Artifact — Never a New Store

## Description

A task's progress through the lifecycle gates (start, red, green, review,
merge) must be readable by both the operator and Claude, must survive a
machine change, and must survive an **operator change** — a different
developer picking up where the last one stopped. That rules out anything
machine-local (a gitignored file, session memory).

The correct home is not a new, bespoke state store — it's whichever
artifact is **already mandatory** for that task's flow:

- **PTE** (`app.json` idRange 50000–99999): a BC sub-task always exists
  before development starts (`[[development-requires-bc-task]]`, no
  exceptions). The sub-task's comments (`taskComments`, PAG6102902) ARE the
  state store. Nothing new to build — just a disciplined format for what
  gets written there.
- **AppSource**: no BC task is mandatory today (`[[one-task-in-progress-at-a-time]]`
  — "AppSource app: offer, never block"). The mandatory artifact instead is
  the pull request. Open it as a draft early — at the start gate, not only
  when work is ready for review — and its description carries the state as
  a checklist.

Do not build a third mechanism (a community example: a dedicated
`workflowSessionManager` with its own session IDs) when a task already has
a mandatory home. Building a parallel store means two sources of truth that
can drift; the artifact the flow already requires cannot drift from itself.

## State vocabulary (both flows use the same stages)

```
TASK_STARTED        branch created, BC gitHubDevStatus = In Progress (PTE only)
ERGASTERION_RULING: PROCEED | PROCEED_WITH_CHANGES | RECONSIDER   (HIGH tier only,
                     before implementation — see below)
RED_CONFIRMED        test written, developer confirmed the failing run
GREEN_CONFIRMED       test passes, developer/CI has actually run it
REVIEW: APPROVE | APPROVE_WITH_NOTES | BLOCK    al-review's verdict
ON_HOLD              parked mid-task (Focus gate) — always includes why
MERGED               track branch merged, BC Done (PTE) / PR merged (AppSource)
```

**2026-08-03 — `ERGASTERION_RULING` carries required changes forward.** When
a HIGH-tier task convenes the Ergasterion (`ergasterion.agent.md`) before
implementation, its ruling — and, critically, the *exact required changes*
for a PROCEED_WITH_CHANGES or RECONSIDER disposition — is written into the
same trail, not just decided in the moment and forgotten. Without this,
nothing downstream (al-review, at merge time) has any way to check whether
the implementation actually honored a design ruling that happened before
code existed. The checkpoint text includes the required-changes list
verbatim, e.g.:

    [CURABIS-STATE] ERGASTERION_RULING: PROCEED_WITH_CHANGES — hide the
    exchange-rate lookup behind an interface before implementation — 2026-08-03, mid

al-review's Titus checklist reads this checkpoint back and treats an
unaddressed required change as a BLOCK finding — see `al-review.agent.md`.

## PTE format — a tagged comment per transition

Write one `[CURABIS-STATE]` comment per transition via `Create_TaskComment_PAG6102902`
(new) or `Modify_TaskComment_PAG6102902` (correcting the same transition, never
silently editing history — see Anti-Pattern). Keep it one line, machine-parseable:

    [CURABIS-STATE] RED_CONFIRMED — 2026-08-03, mid

To resume: call `List_TaskComments_PAG6102902` scoped to `projectNo` +
`subTaskNo`, filter for `[CURABIS-STATE]` lines, the last one is current
state. Never infer state from `gitHubDevStatus` alone — that enum only has
four values (Backlog/In Progress/Done/On Hold) and cannot distinguish
"red confirmed" from "green confirmed" from "blocked in review".

## AppSource format — a checklist in the PR description

Open the PR as a draft at the start gate (not when work is ready), title and
branch as normal, description containing:

    ## CURABIS Task State
    - [x] Branch created — 2026-08-03, mid
    - [x] Test written, RED confirmed — 2026-08-03, mid
    - [ ] Implementation
    - [ ] Test GREEN confirmed
    - [ ] Independent review (al-review)
    - [ ] Merged

Update via `gh pr edit --body`, checking boxes as gates pass — never remove
or reorder completed lines, only append the next checked box. To resume:
`gh pr view <number> --json body` and read which boxes are checked.

## Why not adopt a dedicated session-state tool

The community pattern this generalizes from (`workflow_start`/`workflow_next`/
`workflow_status`, etc.) has real persisted, queryable state — genuinely
worth having — but enforces **no gating whatsoever**: the tool hands back a
natural-language instruction and trusts the calling agent to follow it, with
no human checkpoint anywhere in the mechanism. CURABIS's actual advantage is
the opposite property — RED_CONFIRMED and BLOCK are hard stops, not
suggestions (`[[testcase-must-fail-before-implementation]]`). Building a
parallel state store without also rebuilding that discipline would trade a
real strength for a shinier mechanism. This rule adds the persistence
without touching the gating.

## Anti-Pattern

    // WRONG: editing a state comment's text after the fact to "fix" the record
    Modify_TaskComment_PAG6102902(commentId, "[CURABIS-STATE] GREEN_CONFIRMED — 2026-08-03")
    // on a comment that previously said RED_CONFIRMED — this destroys the
    // audit trail. Append a new comment for the new state; only use Modify
    // to correct a typo in the SAME transition, never to change which
    // transition it records.

## Scope

Applies to every task on every CURABIS-owned or customer repo, PTE and
AppSource alike, from the moment `[[development-requires-bc-task]]` or the
AppSource equivalent activates. Wired into Smiley's Task Lifecycle gates —
see `smiley.agent.md`.
