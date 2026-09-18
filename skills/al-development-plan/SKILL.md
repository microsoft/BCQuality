---
name: al-development-plan
description: Enrich an existing Business Central AL development plan with read-only BCQuality knowledge constraints. Does not generate a plan or implement code.
---

# AL development plan guidance

This host-native adapter translates an existing plan and repository into Entry's task context. It does not plan new work, edit the target repository, run an implementation or review/fix loop, stage, commit, or publish changes.

## Execute

1. Resolve `PLUGIN_ROOT` to the directory containing this plugin's root `plugin.json`, two levels above this file.
2. Preserve the caller's existing `development-plan` verbatim. Consumer-specific workflow payloads must be normalized by the consumer; do not interpret workflow state or manufacture a plan from a coding request.
3. Build the task context for `PLUGIN_ROOT/skills/entry.md`:
   - Set `goal` to read-only BCQuality knowledge enrichment of the supplied plan, preserving the caller's intended change.
   - List only actually supplied inputs from `[development-plan, repository]` in `inputs-available`.
   - Set `technologies: [al]` only when established, and pass other applicability dimensions only when supplied or reliably determined.
   - Apply `BCQUALITY_ENABLED_LAYERS` and `BCQUALITY_DISABLED_SKILLS` as described in the `al-code-review` adapter.
4. Read and execute Entry, including Preparation. Resolve its paths against `PLUGIN_ROOT`, not the target repository. Keep all generated index and scratch artifacts outside the target repository. Use READ's path-based fallback if index generation is unavailable; an unreadable corpus is a failure, not empty knowledge.
5. Follow Entry's dispatch, checking its output metadata against the referenced skill before invocation. This operation accepts only `development-guidance-report`; return `failed` rather than execute another output kind. Pass the supplied existing plan and readable repository, and return the report unchanged. Return Entry's `no-match` or `failed` record unchanged when nothing is dispatched.

Missing inputs remain missing; the dispatched action skill returns `not-applicable` when it cannot proceed. A `no-knowledge` report is additive: it means no additional BCQuality constraints, not a refusal to let the consumer implement under its own gates. The consumer retains all implementation and delivery ownership.
