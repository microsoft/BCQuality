---
kind: action-skill
id: al-development
version: 1
title: AL development
description: Implements Business Central AL features, bug fixes, refactors, upgrades, and maintenance changes using BCQuality knowledge.
inputs: [development-request, repository]
outputs: [implementation-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
guidance-skill: microsoft/skills/development/al-development-plan.md
quality-skill: microsoft/skills/review/al-code-review.md
quality-round-limit: 3
---

# AL development

Implements a Business Central change in an existing AL repository. Feature work, bug fixing, refactoring, upgrades, and maintenance share one public contract and one quality pipeline; their different investigation disciplines are execution modes within this skill.

Both a writable `repository` and a `development-request` are required. A structured request has this shape:

```yaml
development-request:
  kind: auto # feature | bug | refactor | upgrade | maintenance
  description: string # optional when plan states the requested outcome
  plan: string # optional
  acceptance-criteria: [string] # optional
```

A plain-text request is normalized to `kind: auto` with the text as `description`. A plan-only request is valid when the plan states the requested outcome. Return `not-applicable` without changing files when either input is absent, both description and plan are empty, or the repository is not an AL project.

## Source

Read the frontmatter `guidance-skill`; it owns BCQuality discovery and returns the knowledge constraints for the implementation plan. Inspect the target repository for `app.json`, existing objects, tests, permission sets, analyzers, build scripts, naming and object-ID conventions, dependencies, target/runtime versions, localization layout, and uncommitted user changes. For bugs, refactors, and upgrades, inspect enough history and surrounding code to establish the behavior being changed.

## Relevance

Resolve and pass this context to the guidance-skill:

- `bc-version` from the target application's platform/application/runtime settings or supplied context. For an upgrade, distinguish source and target versions.
- `technologies: [al]`, plus any additional technology actually required by the request.
- `countries` from `app.json`, workspace configuration, or supplied context.
- `application-area` from the request and affected objects.

Record unresolved dimensions in the development plan rather than silently substituting broad values. The guidance-skill applies READ's matching semantics and returns any conditional applicability in its report.

## Worklist

1. Normalize the request, deriving a concise description from a plan-only input, and classify `kind: auto` as:
   - `feature` for new or intentionally expanded behavior;
   - `bug` for observed behavior that contradicts an expected result;
   - `refactor` for structural change with no intended behavior change;
   - `upgrade` for schema, data, dependency, runtime, or application-version migration;
   - `maintenance` for bounded development work that fits none of the above.
   Preserve an explicit valid kind. When repository evidence conflicts with it, record the mismatch and ask for clarification before changing files rather than silently switching disciplines.
2. Establish the mode-specific implementation contract:
   - **Feature:** define user-visible behavior and cover data lifecycle, UI/API, permissions, extensibility, upgrade impact, telemetry, and tests where applicable.
   - **Bug:** state expected versus actual behavior, reproduce or otherwise prove the defect, trace the root cause, and define a regression test that fails for that cause.
   - **Refactor:** identify the behavior and public contracts that must remain invariant, plus the checks that establish a before/after baseline.
   - **Upgrade:** identify source and target states, data migration, compatibility, idempotency, and validation requirements.
   - **Maintenance:** define the bounded outcome and the behavior that must not change.
3. Treat a supplied plan as an input constraint, not as proof. Reconcile it with repository reality and BCQuality; preserve its intent, correct unsafe assumptions, and record consequential deviations.
4. Discover existing implementation patterns and reusable objects before proposing new ones. Preserve repository conventions and current user changes.
5. Materialize a `development-plan` containing the classified kind, request, assumptions, affected files and symbols, design or root cause, proposed changes, validation strategy, and acceptance criteria.
6. Invoke the frontmatter `guidance-skill` with that plan, the repository, and the resolved context. It performs Source, Relevance, and knowledge worklisting independently and read-only.
7. Require a complete guidance result before editing product code:
   - `completed` — use every returned constraint and validation consideration.
   - `no-knowledge` — intentionally refuse to implement: return `no-knowledge` with no request changes, set `outcome-reason` to `No applicable BCQuality knowledge was found for this development plan.`, and add a `remaining` entry directing the caller to use a repository-specific workflow/general coding agent or contribute the missing BC-specific knowledge.
   - `not-applicable`, `partial`, or `failed` — return the corresponding non-completed outcome without editing product code; preserve its reason in `remaining`.
8. Copy the guidance report's selected paths into the eventual implementation report only when the corresponding constraint materially shaped the implementation. Carry its suppression records forward.

## Action

1. Record the starting working-tree state so unrelated changes are preserved and excluded from `changes`.
2. Apply the execution mode:
   - **Feature:** implement the smallest complete vertical slice; do not leave placeholder surfaces.
   - **Bug:** reproduce first when feasible, fix the root cause rather than the symptom, keep the patch surgical, and add a regression test.
   - **Refactor:** capture a behavioral baseline, avoid unrelated behavior changes, and prove the declared invariants afterward.
   - **Upgrade:** make migrations rerunnable where required, preserve data and compatibility, and validate both upgraded and fresh-install paths when applicable.
   - **Maintenance:** make only the bounded requested change and preserve surrounding behavior.
3. Produce a coherent design that satisfies the implementation contract and every constraint returned by the guidance-skill. Reuse existing abstractions and object ranges. Do not hard-code a Business Central fact in this skill or invent a rule absent from both the repository and reliable platform knowledge.
4. Implement the request end to end. Include all surfaces required by the mode, acceptance criteria, and repository conventions. Do not create success-shaped stubs.
5. Treat the guidance report as design constraints throughout implementation. Adapt its referenced companion samples to the target codebase; never copy demonstration IDs or names blindly.
6. Run the smallest existing build, analyzer, and test commands that cover the change. Fix failures caused by the implementation. Record every command and real outcome in `validation`; unavailable checks are `not-run`, never `passed`.
7. Invoke the frontmatter `quality-skill` against the final implementation diff, bounded by `quality-round-limit`:
   - Record every invocation in `review-rounds`, including its gating `blocker` and `major` IDs.
   - When no gating finding remains, mark the round `clean` and stop.
   - Otherwise fix every justified, safely actionable gating finding, rerun affected validation, mark the round `fixing`, and start the next review round.
   - Stop early as `stalled` when the gating ID set is unchanged from the preceding round, no gating finding can be fixed safely, or validation cannot be restored.
   - When the final allowed round still has gating findings, mark it `limit-reached`.
   Preserve the last complete findings-report in `review` and add a `validation` entry with `id: "review"`. A `stalled` or `limit-reached` loop returns `partial` with the unresolved gating findings in `remaining`. If review is disabled or unavailable, record `not-run` and return `partial`.
8. Verify the persisted files against the implementation contract, acceptance criteria, and mode-specific evidence. If behavior, validation, guidance, or review remains incomplete, return `partial` and list the exact gap in `remaining`.

## Output

Return one `implementation-report` conforming to DO. Set `plan.kind` to the classified execution mode. `knowledge` lists only articles opened in full and materially used. `changes` lists only files changed by this skill. `completed` requires a persisted implementation, passing required validation, and no unresolved `blocker` or `major` finding in `review`. `no-knowledge` is a visible coverage decision, not an error or silent fallback.
