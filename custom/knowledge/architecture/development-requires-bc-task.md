---
bc-version: [all]
domain: architecture
keywords: [bc-task, task-registration, customer-app, pte, appsource, lifecycle, before-development]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Development requires a registered BC task

## Description

Development work on a **customer app** must not begin until the task is
registered in Business Central. The enforcement point is branch creation:
before a feature branch is created, the BC task must exist and be resolvable
via BC MCP.

Whether an app is a customer app is decided by its object ID ranges in
`app.json`:

| `idRanges` in app.json | App type | BC task |
|---|---|---|
| Within 50000–99999 | Customer app (PTE) | **Mandatory** before development |
| Outside 50000–99999 (e.g. 100000+) | AppSource app | Recommended, optional |

## Why

Customer-app work is billable, customer-facing work. A task that exists only
in a chat conversation or a developer's head cannot be traced, invoiced, or
picked up by anyone else. Registering the task in BC *before* development —
not after — is what makes the rest of the lifecycle chain work: branch naming,
dev-status sync, and commit traceability all key off the BC task.

For AppSource apps the work is product investment, not customer billing, so
the task is optional — but the same chain applies whenever a task exists.

## Decision point

Before `git checkout -b feature/...` on a customer app:

1. Resolve the task via BC MCP (see `[[bc-mcp-find-active-task-for-branch]]`)
2. No task found → create it first (see bc-mcp.agent.md create-task workflow)
   or have the project manager register it
3. Only then create the branch, named after the task, and sync status
   (see `[[git-lifecycle-must-sync-bc-status]]`)

## Anti Pattern

    # Customer app, idRanges 50000..99999
    git checkout -b feature/quick-price-fix     # no BC task exists
    # ...development starts, task registered "later" (= never, or wrong)

## Best Practice

    # 1. BC MCP: task exists (or is created) → taskNo 004 on DEV2023-00027
    # 2. Branch keyed to the task:
    git checkout -b feature/DEV2023-00027-004-price-lookup
    # 3. BC: gitHubDevStatus = "In Progress"
    # 4. Commits prefixed [#taskId] (see commit-message-must-include-bc-task-id)

## Scope

All CURABIS repositories. Mandatory for apps whose `app.json` idRanges lie
within 50000–99999; optional but recommended for AppSource-range apps. Related:
`[[commit-message-must-include-bc-task-id]]`, `[[one-task-in-progress-at-a-time]]`.
