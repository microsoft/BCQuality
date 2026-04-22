---
kind: action-skill
id: bc-domain-context
version: 1
title: BC domain context
description: Returns Business Central domain-knowledge references for a task's application area.
inputs: [file-path, repository]
outputs: [findings-report]
bc-version: [1..99]
technologies: [al]
countries: [w1]
application-area: [all]
---

# BC domain context

Surfaces the Business Central domain-knowledge files that apply to a task's application area. This is a leaf action skill — it invokes no sub-skills and produces informational findings that cite the relevant knowledge files. Consumers that need to reason about a BC module (triage bots, code assistants, review helpers) invoke this skill, read the cited files, and bring that content into their own context.

The skill produces a single JSON document conforming to the DO output contract.

## Source

Collect knowledge files under `*/knowledge/<area>/**/*.md` for every value in `task-context.application-area`, across every enabled layer (`/microsoft/`, `/community/`, `/custom/`). When `application-area` is absent, empty, or `[all]`, source from every area-named knowledge folder across the enabled layers — the full domain corpus.

## Relevance

Apply the frontmatter matching rules defined in READ (*Frontmatter matching semantics*) against the task context:

- `bc-version` — match the task's BC version. If the orchestrator did not supply one, the dimension is `unknown`.
- `technologies` — `[al]`. Knowledge files that declare other technologies (e.g. `[powershell]`) must still intersect with `[al]`; discard those that do not.
- `countries` — `[w1]` matches any task context; country-specific files match only when the task-context `countries` overlaps the file's declared countries.
- `application-area` — the file's `application-area` must include every value the task supplied, OR be `[all]`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium`, AND the `message` MUST name the dimensions that were unknown.

## Worklist

Narrow the relevant set to the files that will be cited:

1. **Goal-directed narrowing.** When `task-context.goal` contains concrete domain tokens beyond the `bc-domain-context for <area>` prefix (for example, *"VAT on prepayment credit memo"*, *"flushing method scrap"*, *"warehouse directed pick"*), score each candidate's `keywords`, filename, and `## Description` content against those tokens. Keep the highest-scoring 15 files. Ties are broken by keyword-overlap count, then filename specificity.

2. **Full-area fallback.** When the goal contains no tokens beyond the prefix (the consumer wants the whole area), skip scoring and keep every relevant file.

3. **Layer precedence.** Resolve conflicts per READ: `/custom/` wins over `/microsoft/`, `/microsoft/` wins over `/community/`. For knowledge files sharing the same `<domain>/<slug>.md` path across layers, keep the highest-precedence file and record each suppressed file in `suppressed[]` with `reason: "layer-precedence"`. Files hidden because their layer is disabled in consumer configuration are recorded with `reason: "configuration"`. Files that never became candidates are NOT recorded in `suppressed`.

If the post-conflict worklist is empty because no area knowledge applies to the task, emit `outcome: "no-knowledge"`. If the relevance filter ruled out every file because of a mismatch (e.g. the task targets a BC version no file supports), emit `outcome: "not-applicable"`.

## Action

For each worklist file, emit one finding:

- `id` — the file's repo-relative path (per DO, citation-based findings use the primary reference path as the id).
- `severity` — `info`. This skill never blocks; it is purely informational.
- `message` — the file's H1 title followed by the first two to three sentences of its `## Description` section. Strip leading whitespace and heading markers. When any frontmatter dimension was `unknown` during Relevance, append `" (conditional on: <dimensions>)"` to the message.
- `location` — omitted. Findings from this skill are not tied to a source-code location.
- `references` — a single reference object: `{ "path": "<repo-relative>", "sha": "<commit-sha>" }`. Include `sha` when the consumer invoked the skill against a specific BCQuality commit.
- `confidence` — `high` when every frontmatter dimension matched exactly; `medium` when any dimension was `unknown`.

Populate `summary.counts` with every emitted finding counted as `info`. Populate `summary.coverage` with `worklist-size` and `items-evaluated` — both equal the number of worklist files when the skill finishes normally.

## Output

Conforms to the DO output contract. A populated example for a finance-area task:

```json
{
  "skill": { "id": "bc-domain-context", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 13 },
    "coverage": { "worklist-size": 13, "items-evaluated": 13 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/finance/vat-on-prepayment-chains.md",
      "severity": "info",
      "message": "VAT on prepayment chains. The VAT amount on a prepayment invoice is computed on the prepayment percentage, then adjusted when the final invoice posts and again when a credit memo reverses either leg. Each step must reconcile against the sales-header prepayment account to avoid rounding drift.",
      "references": [
        { "path": "microsoft/knowledge/finance/vat-on-prepayment-chains.md" }
      ],
      "confidence": "high"
    }
  ],
  "suppressed": []
}
```

The empty-corpus case — the state before any area knowledge lands in BCQuality — produces:

```json
{
  "skill": { "id": "bc-domain-context", "version": 1 },
  "outcome": "no-knowledge",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 0, "items-evaluated": 0 }
  },
  "findings": [],
  "suppressed": []
}
```
