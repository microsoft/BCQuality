---
kind: action-skill
id: al-translation-auditor
version: 1
title: AL translation coverage audit
description: Audits AL source strings against xliff files and the supported countries declared in AppSourceCop.json, and emits a findings report.
inputs: [repository, object-list]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL translation coverage audit

Compares every `Label`, `Caption`, `ToolTip`, `Comment`, and `Description` string in the AL source against the xliff files under the translations folder and against the `supportedCountries` declared in `AppSourceCop.json`. It catches the silent failure where an extension claims to support a market but ships only en-US text, one of the top AppSource rejection reasons. The skill checks one xliff per supported locale, every source string present and translated in every xliff, empty and verbatim targets, orphan trans-units, translator comments on substituted labels, and truncation risk. It sources from the `style` knowledge domain and cites curated label and caption rules where present; coverage gaps the corpus does not encode are agent findings within its translation domain. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `repository` or an `object-list`. It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `style` as the citable candidate set across every enabled layer: a `Label` or `Caption` missing its translator `Comment`, and the `Comment` that must explain placeholders, each map onto a curated rule and MUST cite it rather than be paraphrased, because a missing comment is the root cause of the mistranslations this skill audits. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. The coverage checks themselves (a missing xliff for a supported locale, an untranslated or empty target, an orphan trans-unit) are not encoded in the corpus; for those concrete defects, emit an agent finding within this skill's translation domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries (the `supportedCountries` from `AppSourceCop.json`), or `unknown`.
- `application-area`: the application areas of the changed objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Build the string-to-translation map and narrow to the gaps:

- Walk the AL source (or supplied `object-list`) for every `Label`, `Caption`, `ToolTip`, `Comment`, and `Description`. Walk every `*.xlf` or `*.xliff` under the translations folder. Read the `supportedCountries` array from `AppSourceCop.json`.
- Each `supportedCountries` locale with no matching xliff file; each source string with no `<trans-unit>` in a non-default xliff or no `<target>` element; empty `<target>` elements; non-en-US targets identical to the source with no `state="needs-review"` or justifying note; orphan trans-units that match no source string; labels with `%1`/`%2` substitutions whose `Comment` is missing or did not round-trip into the xliff `note`; targets whose length exceeds the source caption's apparent `MaxLength`.

A curated `style` file enters the worklist when its `keywords` intersect these tokens (for example `label`, `caption`, `comment`, `translation`, `placeholder`). Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each gap, emit a finding.

When the gap maps onto a curated `style` rule (a substituted label with no explanatory `Comment`, a `Caption` missing its `Comment`), emit a knowledge-backed finding citing that file: `id` equal to the file path, the file as primary reference, `severity` up to `blocker` only when the file states a platform-level guarantee otherwise `major`, `confidence` `high` for an unambiguous match.

When the gap is a coverage defect with no curated rule (a missing xliff for a supported locale, an untranslated or empty target, a verbatim target, an orphan trans-unit, a truncation risk), emit an agent finding within this skill's translation domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:missing-xliff-for-supported-country`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` naming the locale or string and the concrete remedy (generate the xliff, translate the target). Where the impact would normally gate (a missing locale that AppSource rejects), keep `severity` at `minor` but say so plainly in the `message` and note the concern should be promoted to a knowledge-backed rule before it can gate. Hold every candidate to the precision bar in `skills/do.md`: steelman that the locale legitimately falls back to a sibling or that an identical target is correct for that string before emitting, and omit when in doubt. Before emitting any agent candidate, check the worklisted knowledge for a match and upgrade it to a knowledge-backed finding if one exists.

Set `suggested-code` only when the fix is an exact, contiguous edit to an AL source string (adding a `Comment` attribute to a label); a missing or untranslated xliff is not a single-line source replacement, so set `suggested-code-omission-reason` (for example `requires generating and translating an xliff file`).

Outcome selection: `completed` when every supported locale and source string was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the task has no source strings or translations to compare; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-translation-auditor", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 2, "items-evaluated": 2 }
  },
  "findings": [
    {
      "id": "agent:missing-xliff-for-supported-country",
      "severity": "minor",
      "message": "AppSourceCop.json declares AU as a supported country but no Translations xliff for en-AU exists, so AU tenants see whatever the default xliff carries. Generate the en-AU xliff and translate it, or document an explicit fallback to en-NZ. Impact would normally be major because AppSource validation rejects this; emitted as minor because no curated rule backs it. This concern should be promoted to a knowledge-backed rule before it can gate.",
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "requires generating and translating a new xliff file"
    }
  ],
  "suppressed": []
}
```
