---
kind: meta-skill
id: do
version: 1
title: Action Skill — the template every action skill follows
---

# DO

An action skill is a markdown file that tells an agent how to do one concrete job — review a pull request, audit telemetry usage, generate a skeleton — using knowledge files from BCQuality. This document is the template every action skill follows. Orchestrators rely on the template to consume any skill without skill-specific parsing.

This contract is stable. Changes require a PR approved by both maintainers.

## What an action skill is

An action skill is a single markdown file with YAML frontmatter. It lives inside a layer:

- `/microsoft/skills/` — platform-endorsed action skills.
- `/community/skills/` — community-contributed action skills.
- `/custom/skills/` — partner or customer action skills (typically in a consumer repo, not in BCQuality itself).

Action skills do not live at the repo root. The three meta-skills in `/skills/` are the only files that sit outside a layer.

## Frontmatter schema

```yaml
---
kind: action-skill
id: al-code-review
version: 1
title: AL code review
description: Reviews AL source changes against performance and security guidance.
inputs: [pr-diff, object-list]
outputs: [findings-report]
bc-version: [26..28]
technologies: [al]
countries: [w1]
application-area: [all]
---
```

`kind`, `id`, `version`, `title`, `description`, `inputs`, `outputs` are required and specific to action skills.

`bc-version`, `technologies`, `countries`, `application-area` are optional filters that let an orchestrator pre-select applicable skills for a task. They follow the same semantics as in READ.

`inputs` is a list of abstract input types the skill consumes. Standard values: `pr-diff`, `object-list`, `file-path`, `repository`, `telemetry-query`. `outputs` is always a single-element list naming the output kind; today only `findings-report` is defined.

`sub-skills` is an optional field. When present and non-empty, the skill is a **super-skill** that composes other action skills; see *Composition* below. Values are repo-relative paths to action-skill files.

## Required sections

Every action skill MUST contain these five sections, in order:

- `## Source` — declares which folders and tags to search for knowledge.
- `## Relevance` — declares how to filter the candidates.
- `## Worklist` — declares how to narrow filtered candidates to the set that applies to this task.
- `## Action` — declares what the skill does with the narrowed set.
- `## Output` — declares the shape of the produced output; typically a reference to the contract below.

## The four-step pattern

**Source.** List the folders and tag filters to collect candidates from. Sources span layers: an action skill sources from the same `domain` subfolder across every enabled layer. Example: *"Source from `/*/knowledge/performance/` and `/*/knowledge/security/`."*

**Relevance.** Apply frontmatter filters to the candidates. Typical filters: match `bc-version` against the target environment, match `technologies` against the languages in scope, match `countries` and `application-area` against the consuming codebase's context. The exact matching rules are defined in READ (*Frontmatter matching semantics*). Files that do not match are discarded.

**Worklist.** Narrow the relevant candidates to the subset that applies to the current task. This is where the task-specific signal enters: the objects changed in the PR, the queries being audited, the skeleton being generated. Typical moves: match `keywords` against task vocabulary, match file topics against changed objects, deduplicate by concern.

**Action.** Execute the skill's work against the worklist. Evaluate each item in the worklist against the task input and emit findings. The action step is where skill behavior differs; the preceding three steps are uniform.

## Output contract

Every action skill emits a single JSON document that conforms to this schema:

```json
{
  "skill": { "id": "string", "version": 1 },
  "outcome": "completed | not-applicable | no-knowledge | partial | failed",
  "outcome-reason": "string",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 0, "items-evaluated": 0 }
  },
  "findings": [
    {
      "id": "string",
      "severity": "blocker | major | minor | info",
      "message": "string",
      "location": {
        "file": "string",
        "line": 0,
        "range": { "start-line": 0, "end-line": 0 }
      },
      "references": [
        { "path": "string", "sha": "string" }
      ],
      "confidence": "high | medium | low",
      "from-sub-skill": "string"
    }
  ],
  "suppressed": [
    {
      "reference": { "path": "string", "sha": "string" },
      "reason": "layer-precedence | configuration"
    }
  ],
  "sub-results": [
    { "...full nested findings-report..." : null }
  ],
  "skipped-sub-skills": [
    {
      "skill": { "id": "string", "version": 1 },
      "reason": "configuration | not-applicable"
    }
  ]
}
```

### Field semantics

**`outcome`** (required) —

- `completed` — the skill ran end-to-end; `findings` reflects the full result (including the empty set).
- `not-applicable` — the skill's frontmatter filters did not match the task context; the skill declined to run.
- `no-knowledge` — the skill ran but found no applicable knowledge files; `findings` MUST be empty.
- `partial` — the skill evaluated part of its worklist but did not finish. `summary.coverage` reflects the evaluated subset. Set `outcome-reason` to explain.
- `failed` — the skill encountered an error and produced no reliable findings. Set `outcome-reason`. Consumers SHOULD ignore `findings` on a failed outcome.

`outcome-reason` is optional for `completed`, `not-applicable`, and `no-knowledge`; required for `partial` and `failed`.

An empty `findings` array with `outcome: completed` means the skill ran and found nothing to flag. Orchestrators MUST NOT conflate this with `not-applicable` or `no-knowledge`.

**`findings[].id`** — a stable identifier for the rule or concern that produced the finding. For citation-based findings (any finding with a non-empty `references`), `id` MUST equal `references[0].path` — the primary knowledge file's repo-relative path. For skills that detect concerns without a direct citation, `id` is a skill-defined slug (kebab-case, stable across versions of the skill). The same `id` produced in two runs MUST refer to the same concern; consumers MAY deduplicate findings by `id`.

When a super-skill rolls up a non-citation finding from a sub-skill (an `id` that is a slug, not a path), the super-skill MUST prefix the `id` with `<from-sub-skill>:` to avoid collisions across sub-skills (for example, a slug `missing-test` from `al-security-review` becomes `al-security-review:missing-test`). Citation-based findings are already globally unique through their repo-relative path and MUST NOT be rewritten.

**`findings[].severity`** — see the taxonomy below.

**`findings[].message`** — human-readable explanation of the finding. Single short paragraph. No markdown formatting assumptions.

**`findings[].location`** — optional. When present:

- `file` MUST be a repo-relative path using forward slashes.
- `line` is the primary line number, 1-based.
- `range` is optional and describes a contiguous line span; `start-line` and `end-line` are 1-based and inclusive. `start-line` MUST equal `line` when both are present.

Findings without a `location` are permitted (for example, repository-wide observations).

**`findings[].references`** — array of knowledge-file references. Each reference is an object:

- `path` (required) — repo-relative path to the knowledge file, forward slashes.
- `sha` (optional) — commit SHA the skill read when producing the finding. Consumers SHOULD include `sha` when the skill was invoked with a specific repo state.

The first reference is the **primary** reference: the knowledge file the finding most directly cites. Additional references provide supporting context and are not ranked. `references` MAY be empty for findings the skill generates without a knowledge-file citation.

**`findings[].confidence`** — the skill's confidence that the finding is a true positive, given the evidence it evaluated. Not applicability confidence, not severity confidence. Values: `high`, `medium`, `low`.

**`findings[].from-sub-skill`** — optional. Set only by super-skills. The `skill.id` of the sub-skill that produced the finding. Absent on findings produced directly by the emitting skill.

**`suppressed`** — MUST list every knowledge file that was discarded due to layer precedence or consumer configuration, whenever that file would otherwise have contributed to the worklist. Each entry contains:

- `reference` — the suppressed file (same object shape as `findings[].references`).
- `reason` — `layer-precedence` when another layer won under READ's precedence rules; `configuration` when the consumer disabled the file's layer.

**`sub-results`** — super-skills only. Array of complete findings-reports, one per sub-skill that was invoked (i.e., every sub-skill not listed in `skipped-sub-skills`). Each entry MUST itself conform to this output contract. Leaf skills MUST NOT emit `sub-results`.

**`skipped-sub-skills`** — super-skills only. Array of sub-skills that were declared in frontmatter but not invoked. `reason` is `configuration` when the orchestrator disabled the sub-skill, or `not-applicable` when the super-skill's Relevance step ruled it out.

Severity taxonomy:

- `blocker` — violates platform-level guarantees; the work cannot proceed as-is.
- `major` — significant defect; should be fixed before merge.
- `minor` — quality concern; worth flagging but not a gate.
- `info` — observation or context; not actionable on its own.

## Composition (super-skills)

A **super-skill** is an action skill whose frontmatter declares a non-empty `sub-skills: [...]`. A super-skill does not evaluate knowledge files directly; it invokes other action skills and composes their output.

Composition is flat: a super-skill MAY list only leaf skills (skills without their own `sub-skills`). Nested super-skills are not permitted in v1.

### Section interpretation for super-skills

The five required sections still apply. Their meaning shifts from knowledge files to sub-skills:

- `## Source` — names the sub-skills invoked (mirrors `sub-skills` in frontmatter).
- `## Relevance` — rules for deciding which sub-skills apply to the current task. A sub-skill is relevant when its declared `inputs` are satisfied by the orchestrator's provided inputs and the orchestrator has not disabled it via configuration. The super-skill MUST NOT filter sub-skills by task content (for example, by inspecting the diff or the file). Task-level applicability is the sub-skill's own responsibility; sub-skills signal non-applicability by returning `outcome: "not-applicable"` or `outcome: "no-knowledge"`.
- `## Worklist` — the final list of sub-skills to invoke; the rest go to `skipped-sub-skills`.
- `## Action` — invoke each worklisted sub-skill with the appropriate subset of inputs, collect its findings-report verbatim into `sub-results`, and copy its `findings[]` into the super-skill's top-level `findings[]` with `from-sub-skill` set. Findings from a sub-skill with `outcome: "failed"` MUST NOT be copied into the super-skill's top-level `findings[]` and MUST NOT contribute to the super-skill's `summary.counts` (their report is still preserved in `sub-results` for traceability, consistent with DO's rule that consumers ignore a failed skill's findings).
- `## Output` — the super-skill's output contract, including `sub-results` and, if any, `skipped-sub-skills`.

### Outcome rollup

A super-skill's `outcome` is derived from its sub-skills' outcomes. Let S be the multiset of sub-skill outcomes for sub-skills in the worklist (skipped sub-skills do not contribute):

- `failed` — every element of S is `failed`.
- `partial` — S contains at least one `partial`, OR S contains at least one `failed` alongside at least one non-`failed` outcome.
- `not-applicable` — every element of S is `not-applicable`.
- `no-knowledge` — every element of S is `no-knowledge` or `not-applicable`, and at least one is `no-knowledge`.
- `completed` — otherwise (every element of S is `completed`, `no-knowledge`, or `not-applicable`, with at least one `completed`).

When the worklist is empty (every sub-skill was skipped), `outcome` is `not-applicable`; `outcome-reason` SHOULD describe the skip reasons, for example *"all sub-skills disabled by configuration"* or *"no sub-skill accepted the supplied inputs"*.

`outcome-reason` is required for `partial` and `failed` and SHOULD summarize per-sub-skill state.

### Rolled-up summary

`summary.counts` is the sum of sub-skill counts. `summary.coverage.worklist-size` and `items-evaluated` are the sums across invoked sub-skills.

### Suppression scope

A super-skill's top-level `suppressed[]` remains knowledge-file-only and is typically empty. Knowledge-file suppression is reported by the leaf sub-skill inside its own entry in `sub-results`. Sub-skills the super-skill chose not to invoke belong in `skipped-sub-skills`, never in `suppressed`.

## Worked example

A minimal action skill that cites applicable guidance for a changed AL file, without generating findings of its own:

```yaml
---
kind: action-skill
id: cite-applicable-guidance
version: 1
title: Cite applicable guidance
description: Lists knowledge files relevant to a changed AL file.
inputs: [file-path]
outputs: [findings-report]
technologies: [al]
---
```

```markdown
## Source
All files under `/*/knowledge/` across enabled layers.

## Relevance
Filter by `technologies: [al]` and `bc-version` matching the target environment.

## Worklist
Intersect `keywords` with tokens derived from the target file's object name and changed members.

## Action
For each worklist entry, emit one finding with severity `info`, a message naming the concern, and a reference object pointing to the knowledge file.

## Output
Conforms to the DO output contract.
```

## How orchestrators consume output

An orchestrator invokes an action skill with an input appropriate to the skill's declared `inputs`, receives the JSON output, and maps findings to its delivery surface (PR comments, build gates, IDE diagnostics). The orchestrator MUST NOT interpret skill-specific fields beyond the schema above. Skills that need richer semantics MUST encode them within the schema (for example, by adding structured `message` text) rather than extending the output shape.
