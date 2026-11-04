---
name: K3 Save Delivery Report
description: "Require explicit approval before creating or updating a delivery-report file. Use after the complete report draft has been shown to the user."
type: skill
scope: workspace
---

# K3 Save Delivery Report

A request to create a report is not approval to write it. Do not write anything until the user has seen the complete draft and explicitly approved the proposed save.

## Procedure

1. Confirm that the complete draft has already been displayed in the conversation. If not, display it before asking for approval.
2. State the intended path: `docs/internal/delivery reports/delivery-report-feature-<ID>.md` at the root of the repository being reported on. If the user gave another location, use that instead.
3. Ask the user to choose: **Save as proposed**, **Save to another location**, or **Changes needed**. A prior approval given before the complete draft was displayed is not valid; ask again after displaying it.
4. For requested edits, revise and show the full updated draft, then request approval again.
5. Before writing, check whether a report already exists or is deleted in the worktree. Tell the user whether saving will update or recreate it. Preserve unrelated worktree changes.
6. Only after explicit approval, create the needed directory and write the approved content to the approved path. Do not alter source files or commit changes.
7. Confirm the saved path after the write.

## Output

Before approval, make no filesystem changes. After approval, report the exact saved path and any validation limitations.
