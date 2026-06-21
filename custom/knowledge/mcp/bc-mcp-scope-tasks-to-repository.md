---
name: bc-mcp-scope-tasks-to-repository
description: >
  When a developer asks for their open tasks, scope the result to the current
  git repository only. If no BC project is linked to the repo, raise it as a
  flag instead of returning all tasks.
layer: 2
category: mcp
---

# BC MCP: Scope Task Lists to the Current Repository

## Rule

When a developer asks "what tasks do I have", "what are my open tasks", or any
equivalent question about their work queue, **only return tasks that belong to
the project(s) linked to the current git repository**.

Do **not** return all tasks assigned to the developer across all BC projects.
That produces noise from unrelated customers and hides the signal of what is
actually in scope for the current repo.

## Why

A developer working in a repository is focused on that context. Showing tasks
from other projects (other customers, other repos) creates confusion and
increases the risk of working on the wrong thing or copying context from the
wrong project.

## Standard recipe

```
1. git remote get-url origin
   → e.g. "https://github.com/Curabis/Wareco.git"

2. List_ProjectRepositories_PAG6102904
      filter: "gitHubRepository eq '<url>'"
   → get projectNo(s) for this repo

3. IF no projects found → STOP and flag (see "No linked project" below)

4. List_ActiveTasks_PAG6102900
      filter: "projectNo eq '<projectNo>' and taskResponsible eq '<employeeCode>'"
   → return only tasks in this repo's project(s)
```

For developer identity (resolving `employeeCode` from git email), see
`[[bc-mcp-find-active-task-for-branch]]`.

## No linked project — flag it

If step 2 returns no results, do not fall back to listing all tasks.
Instead, surface it explicitly:

> **Flag:** Dette repository (`<url>`) er ikke knyttet til et BC-projekt.
> Opgavelisten kan ikke scopetes. Tilknyt repoet via `projectRepositories`
> (PAG6102904) eller kontakt projektlederen.

This is a data-quality issue that should be fixed, not silently bypassed.

## Multiple projects on one repo

If step 2 returns more than one project for the repo, query tasks from all of
them and group the output by project.

## What to show

| Field | Include |
|---|---|
| `taskNo` | Yes |
| `description` | Yes |
| `status` | Yes |
| `gitHubDevStatus` | Yes — shows In Progress / Backlog / Done / On Hold |
| `gitHubBranch` | Yes — shows which branch the task is on |
| `estimatedTime` / `timeLeft` | Yes — helps prioritize |
| `expectedDelivery` | Yes — shows urgency |
| `customerName` | Yes — context |

Do not show internal system fields (`taskId`, etags, `@odata.*`).

## Violations to avoid

- Filtering only by `taskResponsible` without scoping to `projectNo` → returns
  tasks from every customer the developer has ever worked on.
- Falling back to all-tasks when the repo lookup fails → hides a config problem.
- Returning tasks where `gitHubRepository` on the task matches (this field is
  obsolete — always scope via the project, not the task field).
