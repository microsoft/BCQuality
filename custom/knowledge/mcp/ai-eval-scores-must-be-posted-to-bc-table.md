# CURABIS-MCP-008 — AI eval scores must be posted to the BC posting table

## Rule

When an AI agent completes a hill climbing eval iteration on a BC sub-task, all
resulting scores — compile result, test score, BCQuality score, F1 score, verdict,
and model identity — must be posted to the `CUR Project AI Score` table in Business
Central via the designated MCP tool (`bc_post_ai_score`).

Scores must **not** be stored as:
- task comments
- local files or agent memory
- inline in agent files or knowledge files
- any other location outside the BC posting table

## Why

The `CUR Project AI Score` table is a **posting table**: one immutable entry per
iteration, with a clustered key on `Entry No.`. It is the single source of truth for
hill climbing history on a sub-task.

Storing scores elsewhere breaks this guarantee:

| Alternate location | Problem |
|---|---|
| Task comment | 250-char limit, unstructured, not queryable, mixed with human notes |
| Local file | Session-scoped, repo-specific, invisible to other agents and BC reporting |
| Agent memory | Volatile, not persisted between sessions |
| Hard-coded in agent file | Frozen at time of writing, violates CURABIS-MCP-007 pattern |

The BC posting table enables:
1. Reporting across tasks and projects (MatchRate over time)
2. The Court reviewing objective score data from Edison
3. The orchestrator reading prior iterations via `bc_get_ai_scores` to decide verdict
4. BC users seeing hill climbing progress directly on the sub-task

## Compliant

After each eval iteration, the orchestrator calls:

```
bc_post_ai_score(
  projectNo    = "DEV2026-00010",
  subTaskNo    = "0014",
  iterationNo  = 3,
  compile      = true,
  testScore    = 0.80,
  bcquality    = 0.86,
  f1Score      = 0.83,
  verdict      = "Keep",
  model        = "claude-sonnet-4-6"
)
```

BC sets `Eval DateTime` automatically. The orchestrator may additionally post a
brief human-readable comment ("Iteration 3: F1=0.83 → Keep") — this is allowed,
as it communicates progress; the score itself is in BC.

## Non-compliant

```
# Storing score as task comment only
bc_add_comment(
  projectNo = "DEV2026-00010",
  subTaskNo = "0014",
  comment   = "Iter 3: compile ✅ tests 4/5 BCQ 6/7 F1=0.83 Keep"
)
# → Score is unstructured text. Not queryable. Lost to reporting.
```

```
# Storing score in agent file
## Hill climbing log
- Iteration 1: F1=0.43 Revert
- Iteration 2: F1=0.71 Keep
- Iteration 3: F1=0.83 Keep   ← frozen, session-specific, wrong location
```

## False positive

An agent that posts a human-readable summary comment **in addition to** calling
`bc_post_ai_score` is **not** violating this rule. The comment is human
communication; the score is in BC. Both are permitted.

The violation is using the comment or any other location **instead of** posting to
the BC table.

## API reference

- Page: `CUR MCP Project AI Scores` (PAG6102906)
- Entity: `projectAIScores`
- Publisher: `curabis`, Group: `projectMgmt`, Version: `v2.0`
- Insert: allowed. Modify: never. Delete: never.
- `Eval DateTime` is set by BC `OnInsertRecord` — do not pass it.

## Applies to

Agent files that implement hill climbing eval loops on BC sub-tasks.

## Eval at task boundaries (hill-climbing baseline and final)

To generate meaningful hill-climbing data, the project's eval script MUST be
run at two specific moments per task:

| Moment | When | Verdict to post |
|---|---|---|
| **Baseline** | Before the first code change for a task | `"Baseline"` |
| **Final** | After all changes are complete, before merging to track branch | `"Final"` |

The delta `Final.score - Baseline.score` is the quality impact of the task:

- **Positive delta** -- the task improved code quality.
- **Negative delta** -- technical debt was introduced; note it in the BC task comment.
- **Zero or negligible delta** -- neutral; no action required.

### Project eval script

Each project declares its eval script in `CLAUDE.md`. That script emits a score
and appends to the project's eval history. The score posted to `bc_post_ai_score`
is the score emitted by that project-specific script.

### Non-compliant

```
# Skipping the baseline "because the task is small"
# delta cannot be computed; hill-climbing history is incomplete
```

### Compliant

```
# Task start: run eval -> post baseline
bc_post_ai_score(projectNo, subTaskNo, iterationNo, ..., verdict="Baseline")

# ... implement the task ...

# Task end (before merge): run eval -> post final
bc_post_ai_score(projectNo, subTaskNo, iterationNo, ..., verdict="Final")
```

### Scope

Applies to all tasks where the project has an eval script declared in `CLAUDE.md`.
Documentation-only tasks (no code change) are exempt.
