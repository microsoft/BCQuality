---
bc-version: [all]
domain: performance
keywords: [task-scheduler, scheduled-task, taskexists, duplicate-task, createtask, guid]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Store the scheduled task ID to avoid duplicate tasks

> Contributions welcome — open a PR to refine or extend this article.

## Description

Every call to `TaskScheduler.CreateTask` creates a new scheduled task and returns its unique GUID. Repeating setup or lifecycle code without retaining that GUID can create multiple tasks for the same logical work, consuming scheduler capacity and running the work more than once.

## Best Practice

Persist the GUID returned by `CreateTask` at the same scope as the logical task. Before creating a replacement, parse the stored GUID and call `TaskScheduler.TaskExists`; create and store a new task only when the previous task no longer exists. `TaskExists` checks one GUID, not whether an equivalent codeunit is already scheduled, so callers that can schedule concurrently still need serialization around this check-and-create sequence.

See sample: `store-scheduled-task-id-to-avoid-duplicate-tasks.good.al`.

## Anti Pattern

Calling `TaskScheduler.CreateTask` every time initialization, login, setup, or another repeatable path runs while ignoring its return value. Each invocation creates another independent task even when an equivalent task is already pending.

See sample: `store-scheduled-task-id-to-avoid-duplicate-tasks.bad.al`.