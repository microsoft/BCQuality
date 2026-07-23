---
bc-version: [all]
domain: mcp
keywords: [mcp, task-responsible, task-allocation, write-access, active-task, project-management]
technologies: [al]
countries: [w1]
application-area: [all]
---
# BC MCP: taskResponsible Must Be Writable Alongside gitHubBranch/gitHubDevStatus

## Description

The Project Management MCP API must expose `taskResponsible` as a writable field on the same action that already carries `gitHubBranch` and `gitHubDevStatus` (`Modify_ActiveTask`). Developer-to-developer task allocation is a routine, low-risk part of a multi-developer branching workflow, and currently has no automatable path — forcing a manual round-trip to the BC UI every time a task changes hands.

## Why This Matters

`taskResponsible` is ownership metadata, not a business-process-workflow-gating field. It does not control invoicing, approval, or time registration the way the sub-task `Status` field does (see `agent-must-not-write-business-process-status.md`) — it simply records who is doing the work, the same category of information as `gitHubDevStatus`/`gitHubBranch`. Omitting it from the writable surface forces every reassignment out of the coding session and into a separate manual BC step, breaking the flow of an otherwise fully MCP-driven multi-developer workflow.

## What Counts As A Violation

- A CURABIS Project Management MCP API page/action exposes `gitHubBranch` and/or `gitHubDevStatus` as writable, but omits `taskResponsible`, with no documented reason tied to business-process protection.
- An agent session must fall back to instructing the developer to manually reassign a task in the BC UI because no MCP action exposes the field.

## Correct Pattern

`Modify_ActiveTask` (or equivalent) should expose:

    field(gitHubBranch; Rec."GitHub Branch") { }
    field(gitHubDevStatus; Rec."GitHub Dev Status") { }
    field(taskResponsible; Rec."Task Responsible") { }   // ownership metadata, same tier as the two above

`Status` remains read-only — it still gates invoicing/time-registration and must stay protected per the existing rule.

## Verification

For each Project Management MCP action that writes developer-tracking fields, confirm `taskResponsible` is included alongside `gitHubBranch`/`gitHubDevStatus`. If a session needs to reassign a task and finds no writable path, that is this rule being violated in practice.
