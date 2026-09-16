---
name: al-implementation-guidance
description: Consult BCQuality read-only for focused Business Central AL constraints affecting the current implementation or validation decision. Does not edit or run the workflow.
---

# AL implementation guidance

This host-native adapter translates current implementation evidence into Entry's task context. It does not generate or replace a plan, edit the target, own consumed-guidance state, run an implementation or review/fix loop, compile, deploy, stage, commit, or publish.

## Execute

1. Resolve `PLUGIN_ROOT` to the directory containing this plugin's root `plugin.json`, two levels above this file.
2. Preserve the caller's `development-plan`, readable `repository`, `implementation-diff`, and `decision-context` verbatim. Preserve optional `consumed-guidance` verbatim. The consumer must provide stable decision and evidence identifiers and normalize any workflow-specific payload.
3. Build the task context for `PLUGIN_ROOT/skills/entry.md`:
   - Set `goal` to focused, read-only BCQuality consultation for the supplied current implementation decision.
   - List only actually supplied inputs from `[development-plan, repository, implementation-diff, decision-context, consumed-guidance]` in `inputs-available`.
   - Set `technologies: [al]` only when established, and pass other applicability dimensions only when supplied or reliably determined.
   - Apply `BCQUALITY_ENABLED_LAYERS` and `BCQUALITY_DISABLED_SKILLS` as described in the `al-code-review` adapter.
4. Read and execute Entry, including Preparation. Resolve BCQuality paths against `PLUGIN_ROOT`, never the target repository. Keep index, report, and scratch artifacts outside the target. An unreadable corpus is a failure, not empty knowledge.
5. Follow Entry's dispatch and verify its output metadata before invocation. This operation accepts only `implementation-guidance-report`; return `failed` rather than execute another output kind. Pass the supplied inputs unchanged and return the report unchanged. Return Entry's `no-match` or `failed` record unchanged when nothing is dispatched.

The dispatched skill returns `not-applicable` when required focus context is missing. Exact previously consumed path/decision/evidence matches are omitted deterministically, while changed evidence can produce new guidance. `no-knowledge` is not a correctness claim. The consumer retains all implementation, validation, state, review, and delivery ownership.
