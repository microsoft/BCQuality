---
kind: entry-point
id: entry
version: 1
title: Entry — route a task to the action skill(s) that apply
---

# Entry

When an agent is pointed at BCQuality to perform a task, it invokes this skill first. Entry returns a **dispatch record** naming the action skill or skills to invoke next. Routing logic lives here, not in the orchestrator.

Entry is its own `kind`: `entry-point`. It structurally follows the DO four-step pattern (Source → Relevance → Worklist → Action) but the units it selects are action skills, not knowledge files, and its output is a dispatch record, not a findings-report.

This contract is stable. Changes require a PR approved by both maintainers.

## Inputs

The agent invokes Entry with a **task context** supplied by the orchestrator:

```yaml
task-context:
  goal: string            # free-text description of what needs doing
  action: review           # optional explicit intent: review | generate
  inputs-available:       # values the orchestrator has ready to pass to a chosen skill
    - pr-diff
    - file-path
  accepted-outputs:       # exact output capability negotiation
    - kind: findings-report
      version: 1
  technologies: [al]
  bc-version: 28
  countries: [w1]
  application-area: [finance]
  enabled-layers: [microsoft, community, custom]
  disabled-skills: []     # repo-relative paths the consumer has opted out of
```

`goal` and `inputs-available` are required. `action` is optional for backward compatibility and, when present, is exactly `review` or `generate`. `accepted-outputs` is optional for legacy review contexts; when supplied, every entry is an exact `{kind, version}` pair. Filter dimensions (`technologies`, `bc-version`, `countries`, `application-area`) are optional; omitting a dimension is equivalent to "unconstrained" — see Relevance for the exact matching rule. `enabled-layers` defaults to all three. `disabled-skills` defaults to empty.

Generation is capability-gated. It requires all three of:

1. `action: generate`;
2. `inputs-available` containing `requirement-spec`; and
3. `accepted-outputs` containing exactly `{kind: generated-files-report, version: 1}`.

The `requirement-spec` value passed after dispatch is only a path to a bounded UTF-8 JSON file; its contents are not part of `goal` or Entry routing.

Legacy review contexts remain valid without `action` or `accepted-outputs`. For those contexts Entry treats the intended output as `findings-report` version 1. A current consumer that advertises only existing review inputs, and does not advertise `action`, `requirement-spec`, and `generated-files-report` v1 (including BCAppsBCQuality), is generation-ineligible.

## Preparation — knowledge index

Before routing, ensure the knowledge index is current for the **live** clone. Dispatched review and generation skills read `knowledge-index.json` (at the clone root) at their Source step instead of opening every knowledge file — see READ's [Retrieval workflow](read.md). Because a consumer prunes its clone to policy *before* the agent runs, the index MUST be built over the clone as it exists now, so it lists exactly the articles that survived pruning and never an article the consumer denied:

- If `knowledge-index.json` is absent — or you cannot confirm it reflects the current knowledge tree — regenerate it by running, from the checkout root:

  ```
  pwsh ./tools/Build-KnowledgeIndex.ps1
  ```

  It defaults to indexing this checkout and writes `knowledge-index.json` at the root in well under a second. When in doubt, rebuild: a sub-second rebuild is always cheaper than a stale or over-listing index, which is a correctness risk.
- This is a side step. It MUST NOT change Entry's output — the dispatch record below is the only thing Entry emits, and build logs are never part of the dispatch JSON.

Generation is **owned by BCQuality**: the generator ships here next to the skills and knowledge it derives from, and the consuming orchestrator neither builds nor knows about the index.

## Source

All action skills under `*/skills/**/*.md` across the layers named in `enabled-layers`. Meta-skills in `/skills/` (including this file) are not candidates and MUST be excluded. Entry never dispatches Entry.

## Relevance

A candidate is relevant when every condition below holds:

1. Its frontmatter `kind` is `action-skill`.
2. It belongs to the selected action family. `generated-files-report` is the `generate` family; `findings-report` is the `review` family.
3. `task-context.inputs-available` intersects its declared `inputs` — the orchestrator has at least one of the input types the skill accepts. A skill is NOT required to accept every input the orchestrator can supply; it is the skill's responsibility to return `outcome: "not-applicable"` if the supplied subset is insufficient.
4. The candidate's single declared output kind and version are accepted exactly. `output-version` defaults to 1 for existing findings-report skills that omit it.
5. Its frontmatter filter dimensions (`bc-version`, `technologies`, `countries`, `application-area`) match the task context per READ's matching semantics. A dimension omitted from `task-context` is treated as a wildcard and matches any value the skill declares; a dimension explicitly supplied in `task-context` must match the skill's declared values per READ. Conditionally-applicable candidates (any dimension `unknown` per READ) are admitted; they are not filtered out at Entry and are the dispatched skill's concern.
6. Its repo-relative path is not in `task-context.disabled-skills`.

Determine the action family before fuzzy goal matching:

- If `action` is explicit, consider only that family even when inputs from both families are present.
- If both `requirement-spec` and any review input (`pr-diff`, `object-list`, `file-path`, `repository`, or `telemetry-query`) are present without `action`, fail with `outcome-reason: "ambiguous-action"`. Do not use `goal` to break the tie.
- If only review inputs are present and `action` is absent, use the legacy review family.
- If `requirement-spec` is present without `action: generate`, fail with `outcome-reason: "explicit-generate-action-required"`.

Candidates that fail a condition go to `skipped` with the corresponding reason (`action-mismatch`, `inputs-unsatisfied`, `output-negotiation`, `filter-mismatch`, `configuration`). Skills excluded because they are not `kind: action-skill` are not reported in `skipped`.

## Worklist

Narrow the relevant set to the skills that will actually be dispatched:

1. **Goal match.** Within the already-selected action family, score each candidate's `description` and `id` against `task-context.goal`. Drop candidates that do not plausibly address the goal; record them in `skipped` with `reason: "goal-mismatch"`. Scoring is implementation-defined; agents MUST prefer exact keyword overlap before fuzzy signals. Never use fuzzy goal text to choose between review and generation.
2. **Super-skill precedence.** When a super-skill and any skill listed in its `sub-skills` are both in the remaining set, the super-skill supersedes the sub-skill **only when the goal is a broader match for the super-skill than for the sub-skill**. When the goal specifically names a concern the sub-skill handles (for example, goal = *"performance review"* with `al-code-review` and `al-performance-review` both present), the sub-skill wins and the super-skill is dropped with `reason: "narrower-sub-skill-selected"`. Otherwise the super-skill wins and each listed sub-skill in the set is dropped with `reason: "superseded-by-super-skill"`. The principle is: Entry dispatches the narrowest skill that satisfies the goal. A dropped sub-skill's `skipped` entry MUST carry `superseded-by` naming the super-skill that won; a dropped super-skill's entry MUST carry `superseded-by` naming the winning sub-skill.
3. **Layer precedence.** When two remaining candidates share the same `id` across layers, keep the highest-precedence one. Skill layer precedence is `/custom/` over `/community/` over `/microsoft/` — the same ordering READ defines for knowledge files. Drop the losers with `reason: "layer-precedence"` and `superseded-by` naming the winning path.

Each dropped candidate appears in `skipped[]` at most once; record the first reason that caused the drop.

The post-filter set is the **dispatch list**.

## Action

Emit a single JSON document conforming to the output contract below. Entry does not invoke the selected skills — that is the agent's responsibility after receiving the dispatch record.

## Output

```json
{
  "skill": { "id": "entry", "version": 1 },
  "outcome": "routed | no-match | failed",
  "outcome-reason": "string",
  "dispatch": [
    {
      "skill": {
        "id": "al-code-review",
        "version": 1,
        "path": "microsoft/skills/review/al-code-review.md"
      },
      "rationale": "string",
      "inputs": ["pr-diff"],
      "output": { "kind": "findings-report", "version": 1 }
    }
  ],
  "skipped": [
    {
      "skill": { "id": "string", "path": "string" },
      "reason": "action-mismatch | inputs-unsatisfied | output-negotiation | filter-mismatch | goal-mismatch | layer-precedence | superseded-by-super-skill | narrower-sub-skill-selected | configuration",
      "superseded-by": { "id": "string", "path": "string", "version": 1 }
    }
  ]
}
```

### Field semantics

**`outcome`** (required) —

- `routed` — `dispatch` is non-empty; the agent proceeds to invoke each listed skill.
- `no-match` — no action skill applied to the task; `dispatch` is empty. Set `outcome-reason`. Candidates that were considered and dropped MUST appear in `skipped[]`.
- `failed` — Entry itself could not complete (for example, the action-skill folders could not be enumerated, or `task-context` was malformed). Set `outcome-reason`. Agents MUST NOT synthesize a dispatch in this case. This is distinct from an action skill's own `outcome: "failed"` per DO, which applies during skill execution after dispatch.

**`dispatch[]`** — each entry names one action skill to invoke.

- `skill.path` — repo-relative, forward slashes. The agent fetches and executes the file directly from this path.
- `skill.version` — copied from the dispatched skill's frontmatter so the orchestrator can detect drift between dispatch time and execution.
- `rationale` — short human-readable string, for logs and traceability.
- `inputs` — the intersection of `task-context.inputs-available` and the skill's declared `inputs`. The agent MUST pass exactly this subset when invoking the skill. Sending a strict intersection avoids accidental information leakage between skills.
- `output` — the candidate's single declared output kind and contract version. This field is additive for existing consumers and is present in every dispatch entry. The version is `output-version` from frontmatter, defaulting to 1 for existing findings-report skills.

Ordering of `dispatch[]` is not significant.

**`skipped[]`** — MUST list every candidate that was considered and dropped. Each dropped candidate appears at most once; the first drop reason wins. Reasons:

- `inputs-unsatisfied` — `task-context.inputs-available` did not intersect the skill's declared `inputs`.
- `action-mismatch` — the skill belongs to the action family not selected by explicit intent or legacy review inference.
- `output-negotiation` — the skill's exact output kind/version was not accepted by the consumer.
- `filter-mismatch` — one or more frontmatter filter dimensions explicitly did not match.
- `goal-mismatch` — Relevance admitted the candidate but it failed the goal-match step.
- `layer-precedence` — a higher-precedence skill with the same `id` won. `superseded-by` is required.
- `superseded-by-super-skill` — a super-skill listing this skill as a sub-skill was dispatched instead. `superseded-by` is required.
- `narrower-sub-skill-selected` — a sub-skill listed by this super-skill was dispatched because the goal specifically matched it. `superseded-by` is required.
- `configuration` — the skill is listed in `task-context.disabled-skills`.

**`superseded-by`** — required for `layer-precedence`, `superseded-by-super-skill`, and `narrower-sub-skill-selected`; omitted otherwise. Names the winning skill by `id`, `path`, and `version`.

Empty-dispatch example (no action skills exist in any enabled layer):

```json
{
  "skill": { "id": "entry", "version": 1 },
  "outcome": "no-match",
  "outcome-reason": "No action skills found under */skills/ in the enabled layers.",
  "dispatch": [],
  "skipped": []
}
```

Populated example (PR review on a repo where only `al-performance-review` is enabled; `al-code-review` and `al-security-review` were disabled by configuration):

```json
{
  "skill": { "id": "entry", "version": 1 },
  "outcome": "routed",
  "dispatch": [
    {
      "skill": { "id": "al-performance-review", "version": 1, "path": "microsoft/skills/review/al-performance-review.md" },
      "rationale": "Goal 'review pull request' matched; inputs-available contains pr-diff.",
      "inputs": ["pr-diff"],
      "output": { "kind": "findings-report", "version": 1 }
    }
  ],
  "skipped": [
    { "skill": { "id": "al-code-review", "path": "microsoft/skills/review/al-code-review.md" }, "reason": "configuration" },
    { "skill": { "id": "al-security-review", "path": "microsoft/skills/review/al-security-review.md" }, "reason": "configuration" }
  ]
}
```

Deterministic generation-only example:

```yaml
task-context:
  goal: "Generate the bounded AL requirement"
  action: generate
  inputs-available: [requirement-spec]
  accepted-outputs:
    - kind: generated-files-report
      version: 1
  technologies: [al]
```

This dispatches only `microsoft/skills/generate/al-code-generation.md`, with `inputs: [requirement-spec]` and `output: {kind: generated-files-report, version: 1}`.

Deterministic review-only example:

```yaml
task-context:
  goal: "Review the AL changes"
  inputs-available: [pr-diff]
  technologies: [al]
```

This remains backward compatible and routes to the applicable review skill with `output: {kind: findings-report, version: 1}`.

When both input families are available, `action: generate` routes only generation and `action: review` routes only review, subject to exact accepted-output negotiation. The same context without `action` fails:

```yaml
task-context:
  goal: "Handle these AL inputs"
  inputs-available: [pr-diff, requirement-spec]
```

The result is `outcome: failed`, `outcome-reason: "ambiguous-action"`, and an empty `dispatch`. Goal text never resolves this ambiguity.

## How the agent uses the dispatch

1. Invoke Entry with the orchestrator-supplied task context.
2. Receive the dispatch record.
3. For each entry in `dispatch[]`, read the referenced action skill, execute its Source → Relevance → Worklist → Action steps per DO, and produce exactly the negotiated `output` kind/version.
4. Return the action-skill reports to the orchestrator. When `outcome` is `no-match` or `failed`, return the dispatch record itself so the orchestrator can log the reason.

READ and DO are the contracts that govern what the dispatched skills do. An agent that has not yet read READ and DO reads them when it executes the first dispatched skill — they are not prerequisites for invoking Entry.
