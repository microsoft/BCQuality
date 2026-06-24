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

Action skills do not live at the repo root. The files in `/skills/` — the three meta-skill contracts (READ, DO, WRITE) and the entry-point skill (`entry.md`, `kind: entry-point`) — are the only skills that sit outside a layer. The entry-point skill structurally follows this same four-step pattern but produces a dispatch record rather than a findings-report; see `skills/entry.md` for its contract.

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

`inputs` is a list of abstract input types the skill **accepts**. Standard values: `pr-diff`, `object-list`, `file-path`, `repository`, `telemetry-query`. Semantics are any-of: the orchestrator supplies whichever listed input types it has, and the skill is invoked with a non-empty subset of its declared `inputs`. A skill that cannot proceed with the supplied subset MUST return `outcome: "not-applicable"`. `outputs` is always a single-element list naming the output kind; today only `findings-report` is defined.

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
      "from-sub-skill": "string",
      "suggested-code": "string",
      "suggested-code-omission-reason": "string"
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

### JSON validity

The emitted document MUST be strict, valid JSON per [RFC 8259](https://www.rfc-editor.org/rfc/rfc8259). Inside every string value, all double quotes MUST be escaped as `\"` and all line breaks as `\n`; other control characters MUST use their JSON escapes. This is not optional polish — it is the difference between a parseable report and one a consumer silently drops.

AL source is the common failure case. Quoted identifiers (for example `Rec."No."`) and multi-line snippets routinely appear in `message`, `suggested-code`, and `suggested-code-omission-reason`, and each embedded quote or newline MUST be escaped when placed in a string value. A `suggested-code` payload that spans several lines is a single JSON string with `\n` separators, not a literal multi-line block. Emit the document as one JSON value with no trailing commentary, and do not rely on the consumer to repair unescaped output.

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

**Agent findings.** A skill MAY emit findings that the agent identified through its own reasoning rather than from a BCQuality knowledge file. BCQuality is an **additive** knowledge layer: it augments the agent's pre-existing review judgement, it does not replace it. An agent finding is encoded by:

- `references: []` — required. An agent finding has no knowledge-file citation by definition; if a citation existed, the finding would be a knowledge-backed finding instead.
- `id` — a skill-defined slug, prefixed with `agent:` (mirroring the `<from-sub-skill>:` rule). For example, `agent:obsolete-find-signature`.
- `confidence` — capped at `medium`. Without a knowledge-file citation there is no authoritative basis for `high` confidence.
- `severity` — capped at `minor`. Agent findings are advisory and non-gating: without a curated rule behind them they MUST NOT carry `major` or `blocker` weight, which the severity taxonomy reserves for gating defects. A genuinely severe issue the agent is confident about almost always matches an existing knowledge file (upgrading it to a knowledge-backed finding) or warrants authoring a new one — not a high-severity agent finding. When the underlying impact would otherwise be `major` or `blocker`, keep the emitted `severity` at `minor` but say so plainly in the `message`, and flag that the concern should be promoted to a knowledge-backed rule before it can gate.
- `message` — non-empty and self-contained. It MUST describe the issue and a concrete recommendation, since a consumer rendering the finding has no knowledge-file footer to fall back on.
- `from-sub-skill` — set by super-skills only. The literal string `"agent"` when the super-skill itself produced the finding from its own cross-cutting reasoning; or the producing leaf's `skill.id` when the super-skill is rolling up a leaf's agent finding. Absent on findings emitted directly by a leaf (the leaf's own report carries the finding under its `skill.id` already).

**Precision bar — emit agent findings conservatively.** Agent findings are the lowest-precision output BCQuality produces: there is no curated rule behind them, so a false positive costs reviewer trust with nothing to point back to. Hold them to a deliberately high bar:

- Emit only a **concrete, demonstrable defect with material impact** that a knowledgeable BC reviewer would agree is wrong — not merely different, suboptimal in theory, or not-how-I-would-write-it.
- **Steelman before emitting.** State the strongest case that the code is correct as written: a deliberate choice, a valid alternative, or behaviour that depends on code outside the diff. If that case is plausible, do not emit.
- **Never emit** as agent findings: stylistic or formatting preferences (outside a dedicated style skill's own domain); speculative or hypothetical concerns — anything you would phrase with "could", "might", or "consider"; issues that depend on code not visible in the diff; valid alternative approaches; or generic software-engineering advice a competent model already applies without prompting (the same exclusion the knowledge-file admission test enforces).
- **When in doubt, omit.** Recall is the knowledge files' responsibility; the agent channel exists only for the high-confidence, concrete defect the corpus has not captured yet. A missed low-severity observation is cheaper than a false positive.

Agent findings may be emitted by both leaf sub-skills and super-skills, with different scope boundaries:

- A **leaf sub-skill** MAY emit agent findings strictly within its declared `domain`. al-security-review MAY surface an agent security finding that no knowledge file covers (for example, a `case` over a security-relevant enum with no `else` arm), but MUST NOT emit a style or performance agent finding — those are out of scope for the leaf and belong to other leaves or to the super-skill. The leaf's domain is the bounding box.
- A **super-skill** MAY emit agent findings of any kind, but its self-review pass is most useful for **cross-cutting** concerns that span multiple leaf domains (architecture-level smells, error-handling gaps that touch security and reliability, resource lifecycle issues). Domain-specific agent reasoning is the leaves' job; the super-skill should not duplicate it.

Before emitting an agent finding, a skill MUST validate the candidate against the BCQuality knowledge it has already loaded for the task — if a knowledge file matches, the candidate is upgraded to a knowledge-backed finding (and merged or deduplicated against any existing finding that already covers the same concern); if a knowledge file explicitly contradicts the candidate, it is suppressed. For a super-skill rolling up leaf reports, this validation is done against the union of knowledge files all leaves loaded, not just one leaf's set.

Consumers that render output MAY treat agent findings differently from knowledge-backed findings (for example, by labelling them and routing them to a separate review domain). The `references: []` marker, together with the `agent:` `id` prefix, is the contract they rely on; `from-sub-skill: "agent"` is the additional marker for super-skill-emitted agent findings.

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

The first reference is the **primary** reference: the knowledge file the finding most directly cites. Additional references provide supporting context and are not ranked. `references` MAY be empty only for **agent findings** (see the `findings[].id` section above for the full encoding); any other finding MUST have at least one reference.

**`findings[].confidence`** — the skill's confidence that the finding is a true positive, given the evidence it evaluated. Not applicability confidence, not severity confidence. Values: `high`, `medium`, `low`.

**`findings[].from-sub-skill`** — optional. Set only by super-skills. The `skill.id` of the sub-skill that produced the finding, or the literal string `"agent"` for an agent finding the super-skill produced from its own cross-cutting reasoning. Absent on findings emitted directly by a leaf skill — including agent findings the leaf emits within its own domain, which appear in the leaf's own report without this field.

**`findings[].suggested-code`** — optional in the schema but **expected for mechanical findings**. It is a concrete code-replacement payload for the lines indicated by `location`. When present, the string MUST be a literal replacement for the source lines covered by `location.line` (or `location.range` if set) — i.e., what the file would contain after the fix, with no surrounding diff markers, fences, or commentary. Consumers MAY render it as a one-click suggestion in the delivery surface (for example, a GitHub ```` ```suggestion ```` block).

Emit `suggested-code` whenever the fix is small, local, and mechanical: deleting unreachable code; replacing one expression (`Count() > 0` → `not IsEmpty()`); moving a local `Label` to object scope; adding a missing property such as `ToolTip`, `OptionCaption`, or `DataClassification`; replacing a string-concatenated `Error` with a Label-backed call; changing a permission token; or adding a missing `else`/guard branch whose replacement is unambiguous from the surrounding diff. When a `.good.al` companion exists and the diff context matches the `.bad.al` shape, prefer adapting the `.good.al` replacement into `suggested-code`.

Omit `suggested-code` only when the appropriate fix depends on context the skill cannot determine, when multiple defensible replacements exist, or when the fix spans non-contiguous code. If a finding is mechanical-looking but `suggested-code` is omitted, set `findings[].suggested-code-omission-reason` to a short explanation (for example, `requires choosing a real event id` or `fix spans multiple non-contiguous locations`). The `suggested-code` payload supplements `message`; it does not replace the explanation in `message`.

**`findings[].suggested-code-omission-reason`** — optional. Required when a finding is mechanical-looking but `suggested-code` is omitted. Short, human-readable reason explaining why no safe one-click replacement was emitted. Consumers MAY use this for telemetry or diagnostics; they do not have to render it in review comments.

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


