---
bc-version: [all]
domain: process
keywords: [plan, object-id-range, al-objects, task-list, data-model, sdd]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Map each feature to an object ID range

## Description

Between an approved spec and implementation comes a technical plan that maps the what onto the how: which standard BC modules to reuse, which custom AL objects are genuinely needed, and an object table giving each new object a name, type, and an ID inside the feature's reserved object ID range. The plan also captures the data model, integration points, cross-cutting concerns (permissions, telemetry, upgrade and migration, performance), and an ordered, checkable task list. Doing this before writing production AL keeps object IDs inside the assigned range, surfaces the standard-versus-custom decision explicitly, and gives implementation a sequenced list rather than an open-ended coding task.

The object table is the part that turns the constitution's reserved range into concrete allocations. Choosing each object's ID up front, against the range the technical design assigned, is what prevents two features from colliding and what lets a verifier reject an out-of-range object as a plan defect rather than a late rework. The task list does the same for sequencing: by naming explicit tasks for permissions, telemetry, tests, and upgrade steps, it stops those cross-cutting concerns from being remembered only after the feature code is written.

## Best Practice

After the spec is approved and before implementing, write a plan that decides what standard BC to reuse and what custom AL is needed, with every new object assigned an ID inside the feature's reserved range. Produce an ordered task list that includes explicit tasks for permission-set entries, telemetry, a test per acceptance criterion, the build-and-verify pass, and docs. Pre-flight the plan against the rules the verifiers will enforce later, such as object IDs in range and an upgrade step for any schema change, so implementation starts clean. Stop for review of the plan and object list before writing production AL.

## Anti Pattern

Implementing a feature directly from the spec with no object plan, so object IDs are picked ad hoc outside the reserved range, the reuse-versus-custom decision is made implicitly while coding, and there is no ordered task list to work through. The consequence is ID collisions, missed permission-set or upgrade tasks, and rework when a verifier rejects an out-of-range object late. The signal: new AL objects with IDs outside the feature's assigned range, or a feature being built with no plan mapping the spec to a concrete object list and task sequence.

## See also

- `specify-before-you-build.md`
- `ground-work-in-a-solution-constitution.md`
