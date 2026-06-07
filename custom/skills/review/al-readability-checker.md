---
kind: action-skill
id: al-readability-checker
version: 1
title: AL readability review
description: Reviews AL source changes for readability to a fresh reader, covering naming, structure, labels, and comments, and emits a findings report.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL readability review

Reviews Business Central AL for whether a human reviewer who has never seen the file can understand it without help: identifier clarity (PascalCase, verb-first procedures, no Hungarian notation, no opaque abbreviations), structure (one object per file, short procedures, shallow nesting, no magic numbers), labels and captions (every user-facing string through a `Label` with a translator `Comment`), and comments (no commented-out code, no untracked TODOs). This skill sources primarily from the `style` knowledge domain and cites a curated rule wherever a readability concern maps onto one; where no curated rule exists, it emits an agent finding within its style and readability domain. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `pr-diff` (the standard PR-review entry point) or a `file-path` (single-file review). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `style` or `ui` as the citable candidate set across every enabled layer: the corpus encodes most naming, label, caption, layout, and keyword-casing rules, so a readability concern that maps onto one MUST cite it rather than be paraphrased. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. Where a concrete readability defect has no curated rule (an opaque project abbreviation, commented-out code, a TODO with no work-item reference), emit an agent finding within this skill's style and readability domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the changed objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow the relevant files to the subset that applies to the changes, computing overlap against:

- Changed identifiers: object, variable, and procedure names, weighted toward Hungarian-prefixed names, single-letter variables outside trivial loops, non-verb-first procedure names, and abbreviations with no obvious BC meaning.
- Changed structure: procedures over roughly 80 lines, nesting at five levels or deeper, more than one object per file, and magic numbers or magic strings.
- Changed user-facing strings: `Label`, `Caption`, `ToolTip` declarations, weighted toward a missing translator `Comment`, an inline rather than object-scope `Label`, and a `Locked` flag missing on a non-translatable label.
- Changed comments: commented-out code, TODO or FIXME without a work-item reference, and public API or library procedures missing XML doc comments.

A curated `style` or `ui` file enters the worklist when its `keywords` intersect these tokens or its topic matches a changed object kind. Read an article's full `## Best Practice` / `## Anti Pattern` body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. When the diff clearly matches an anti-pattern (a `Label` with no `Comment`, a lowercase-keyword violation, a missing `Caption` on a page field), emit a knowledge-backed finding citing the file: `id` equal to the file path, `severity` `major` when the file states a hard rule otherwise `minor`, `location` on the offending line or range, `confidence` `high` for an unambiguous match. When the diff contradicts a best practice without being a full anti-pattern, emit `minor` with the same reference shape.

When a concrete readability defect has no curated rule (commented-out code, an opaque abbreviation that a fresh reader cannot decode, a TODO with no tracking reference), emit an agent finding within this skill's style and readability domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:opaque-abbreviation`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` naming the issue and a concrete rename or removal. Hold every candidate to the precision bar in `skills/do.md`: as a dedicated style skill, readability preferences are inside this skill's domain, but still steelman that the choice is a deliberate, established convention before emitting, and omit when in doubt. Defects outside style and readability belong to other skills. Before emitting any agent candidate, check the worklisted knowledge for a match and upgrade it to a knowledge-backed finding if one exists.

Set `suggested-code` when the fix is mechanical (adding a `Comment` to a label, lowercasing a reserved keyword, moving an inline `Label` to object scope, deleting commented-out lines); otherwise set `suggested-code-omission-reason`. Group repeated instances of one concern into a single finding with a line range rather than many near-identical ones.

Outcome selection: `completed` when every worklist item was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the diff has no AL to review; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-readability-checker", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 3, "items-evaluated": 3 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/style/label-comment-explains-placeholders.md",
      "severity": "major",
      "message": "The Label declared on line 42 has no Comment attribute. Translators need a Comment that explains the placeholders so word order is preserved in other locales.",
      "location": {
        "file": "src/EventRegistrationMgt.Codeunit.al",
        "line": 42
      },
      "references": [
        { "path": "microsoft/knowledge/style/label-comment-explains-placeholders.md" }
      ],
      "confidence": "high"
    }
  ],
  "suppressed": []
}
```
