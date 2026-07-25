---
bc-version: [all]
domain: architecture
keywords: [one-task, focus, wip-limit, lifecycle, branch, in-progress, park]
technologies: [al]
countries: [w1]
application-area: [all]
---

# One task in progress at a time

## Description

A developer — and a Claude session — works on **at most one task per
repository at a time**. Starting a task is an atomic sequence; nothing else
starts until the task is finished or explicitly parked.

**Starting a task means, in order:**

1. Feature branch created in VS Code (named per the convention in
   `[[git-lifecycle-must-sync-bc-status]]`)
2. BC subtask updated: `gitHubDevStatus = "In Progress"` (when a BC task
   exists — see `[[development-requires-bc-task]]`)
3. Test case created and confirmed red
   (see `[[testcase-must-fail-before-implementation]]`)
4. Implementation begins

**Finishing a task means:** test case green, feature branch merged to the
declared track branch (see `[[feature-branch-must-merge-to-track-branch]]`),
BC status `Done`.

## Why

Half-finished work is the most expensive inventory a codebase carries. Two
open tasks means two branches drifting, two test cases in unknown state, and
a merge conflict being cultivated. The WIP limit of one is what makes the
red→green gate meaningful: at any moment, the repo's state answers the
question "what are we building right now?" with exactly one answer.

## When new work arrives mid-task

"Hurtigt lige..." is the anti-pattern. The choice is binary:

| Option | Action |
|---|---|
| Finish first | Complete the current task to green + merged, then start the new one |
| Park | BC status `On Hold`, commit or stash work-in-progress, then start the new one |

What is never allowed: starting the new work on top of the open task's branch,
or leaving the open task in `In Progress` while working on something else.

**Exception — break-fix:** a production error or broken build interrupts
immediately and does not count as a second task. Fix, then return.

## Anti Pattern

    # Task A in progress, test still red
    # "Hurtigt lige" request arrives:
    git checkout -b feature/task-b        # Task A abandoned in limbo
    # BC still says Task A "In Progress" — now a lie

## Best Practice

    # Park Task A explicitly:
    #   BC: Task A gitHubDevStatus = "On Hold"
    git add -A && git commit -m "[#8738] WIP: parked for urgent task B"
    git checkout main && git checkout -b feature/DEV2023-00027-005-task-b
    #   BC: Task B gitHubDevStatus = "In Progress"

## Scope

All CURABIS repositories — customer apps and AppSource apps alike.
