---
kind: action-skill
id: al-appsource-review
version: 1
title: AL AppSource review
description: Performs an AL AppSource review against source and app metadata guidance from BCQuality.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL AppSource review

Reviews AL source and app metadata changes against the `appsource` knowledge domain in BCQuality and emits a findings report. This is a leaf action skill: it invokes no sub-skills. It is one of the skills composed by `al-code-review`.

An orchestrator invokes this skill with either a `pr-diff` (the standard PR-review entry point) or a `file-path` (single-file review). AppSource findings are narrow by design — they apply when the diff touches AppSourceCop configuration, AL object or extension-member names, or AppSource-facing `app.json` metadata. The skill returns `not-applicable` when none of those apply.

## Source

Read the BCQuality knowledge index once — the `knowledge-index.json` BCQuality builds at the root of the knowledge checkout (Entry's preparation step regenerates it over the live, already-filtered clone — see `skills/entry.md`). It lists every article that survived layer and allow/deny filtering and carries, per article, its `path`, `layer`, `domain`, frontmatter dimensions, `keywords`, `title`, and a one-line `description` hint — exactly the fields Relevance and Worklist consume. Take the index entries whose `domain` is `appsource` as this skill's candidate set across every enabled Microsoft, community, and custom layer; do not open the individual article files at this step. Open an article's full body only once it enters the Worklist below, so a review reads the index plus the handful of worklisted articles instead of every file under `*/knowledge/appsource/**`.

## Relevance

Apply the frontmatter matching rules defined in READ (*Frontmatter matching semantics*) against the task context:

- `bc-version` — the target BC version from the PR branch's `app.json` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. Default to the orchestrator's configured context; if absent, `unknown`.
- `application-area` — the union of application areas declared by the changed objects. Pass the actual set; do not substitute `[all]`. If the area cannot be determined from the changes, the dimension is `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium`, AND the finding's `message` MUST name the dimension or dimensions that were unknown.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review. For each relevant file, compute overlap against:

- The changed files and AL object types — especially `app.json`, `AppSourceCop.json`, new objects, and table/page/report extensions that add fields, keys, controls, or actions to base objects.
- The changed object and member names, weighted toward prefix/suffix consistency with `mandatoryAffixes` or `mandatoryPrefix`, plus AppSource-facing help metadata.
- Tokens extracted from the diff that relate to AppSource (`AppSourceCop`, `mandatoryAffixes`, `mandatoryPrefix`, `AS0011`, `prefix`, `suffix`, `tableextension`, `pageextension`, `reportextension`, `field`, `key`, `control`, `action`, `app.json`, `help`, `ContextSensitiveHelpPage`, `Copilot`, `https`).

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic (derived from the index entry's `path`, `title`, and `description`) matches a changed object type. Read an article's full file — its `## Best Practice` / `## Anti Pattern` bodies — only after it makes the worklist; candidate selection uses the index alone. When the diff contains no AppSource-related source or metadata changes by any of the above signals, return `outcome: "not-applicable"` without evaluating files.

The following targeted checks cover every current `appsource` article across the Microsoft and community layers. Treat each as a candidate-selection cue: when the signal appears in changed code, add the named article to the worklist and evaluate it in Action.

- A new or renamed object lacks the reserved prefix/suffix, or a tableextension/pageextension/reportextension adds an unaffixed field, key, control, or action to a base object despite `mandatoryAffixes`/`mandatoryPrefix` and AS0011 — `object-affixes-prevent-collisions`.
- For BC v27 or later, `app.json` adds or changes the `help` URL to a path deeper than two levels, or a changed Copilot/context-sensitive help arrangement would ground the app under an overly broad truncated parent — `keep-copilot-help-url-to-two-path-levels`.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ. Drop lower-precedence files whose normative guidance (`## Best Practice` or `## Anti Pattern`) directly contradicts a higher-precedence candidate, and record each dropped file in `suppressed` with `reason: "layer-precedence"`. Files that would have been candidates but are hidden because their layer is disabled in consumer configuration are recorded with `reason: "configuration"`. Files that never became candidates are NOT recorded in `suppressed`.

When the post-conflict worklist is empty because no applicable AppSource knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable AppSource knowledge matched the changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. Emit findings as follows:

- When the diff contains a clear match for an Anti Pattern, emit a finding with severity `major` or `blocker`, a message summarizing the anti-pattern, `location` pointing to the offending line or range, and a `references` entry pointing to the knowledge file. Use `blocker` only when the knowledge file states the change violates an AppSource submission requirement; otherwise the ceiling is `major`.
- When the diff contains code that contradicts a Best Practice without being a full anti-pattern, emit `minor` with the same reference shape.
- When the skill cannot detect a violation but the file is clearly applicable to the change, emit `info` citing the file.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match (affix configuration/name or URL path depth).
- `medium` when detection relies on heuristics or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

After evaluating each worklist entry, also consider whether the diff exhibits an AppSource defect the agent recognises from its general AL knowledge that no knowledge file in the worklist covers. Such candidates are agent findings within this skill's domain — emit them with `references: []`, an `id` slug prefixed with `agent:`, `confidence` capped at `medium`, `severity` capped at `minor` (agent findings are advisory and non-gating), and a `message` that is self-contained (describing both the issue and a concrete recommendation, since there is no knowledge-file footer for the consumer to fall back on). Hold every candidate to the precision bar in `skills/do.md` (*Agent findings*): emit only a concrete, material AppSource defect a knowledgeable BC reviewer would agree is wrong — steelman it first and drop anything stylistic, speculative, dependent on code outside the diff, or merely a valid alternative; when in doubt, omit. The scope is strictly AppSource; defects outside this domain belong to other leaves and MUST NOT be emitted here. Before emitting, check the worklist for a knowledge file that matches the candidate — if one exists, upgrade the candidate to a knowledge-backed finding instead. See `skills/do.md` for the full contract.

For every emitted finding, decide whether the fix is mechanical. A fix is mechanical when it is small, local, and unambiguous from the diff context (for example: add the configured affix to one object or extension member, or replace a deep help URL with a known two-level canonical URL). For mechanical findings, emit `findings[].suggested-code` with the literal replacement for the source lines indicated by `location`. The payload must be a verbatim replacement — no diff markers, no fences, no commentary — that the consumer can render as a one-click suggestion. When a `.good.al` companion exists and the diff context matches the `.bad.al` shape, adapt the `.good.al` replacement into `suggested-code`.

Omit `suggested-code` only when the appropriate fix depends on context the skill cannot determine, when multiple defensible replacements exist, or when the fix spans non-contiguous code. If a finding is mechanical-looking but you omit `suggested-code`, set `findings[].suggested-code-omission-reason` to a short explanation. See `skills/do.md` for the full contract.

Outcome selection:

- `completed` — the skill evaluated every worklist item.
- `no-knowledge` — no applicable AppSource knowledge survived filtering.
- `not-applicable` — the diff touches no AppSource source, analyzer configuration, or app-metadata surface.
- `partial` — a budget was hit before the worklist was exhausted.
- `failed` — an unrecoverable error occurred.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-appsource-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 1, "items-evaluated": 1 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/appsource/object-affixes-prevent-collisions.md",
      "severity": "major",
      "message": "The tableextension adds an unaffixed Loyalty Points field to Customer, so it violates the configured AppSource affix and can collide with another extension.",
      "location": {
        "file": "src/CustomerExt.TableExt.al",
        "line": 8
      },
      "references": [
        { "path": "microsoft/knowledge/appsource/object-affixes-prevent-collisions.md" }
      ],
      "confidence": "high",
      "suggested-code": "field(50100; \"Loyalty Points ABC\"; Integer)"
    }
  ],
  "suppressed": []
}
```

The empty-corpus case produces:

```json
{
  "skill": { "id": "al-appsource-review", "version": 1 },
  "outcome": "no-knowledge",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 0, "items-evaluated": 0 }
  },
  "findings": [],
  "suppressed": []
}
```
