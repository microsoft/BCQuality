---
kind: action-skill
id: al-major-release-readiness
version: 1
title: AL major release readiness review
description: Reviews a PR that bumps app.json application or platform versions against major-upgrade governance and the compatibility-testing gate, and emits a findings report.
inputs: [pr-diff, repository]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL major release readiness review

Governs Business Central major version bumps. A NextMajor branch is expensive (parallel maintenance), so the house rule delays it as long as the current Production version still compiles and runs cleanly. This skill reviews any PR that bumps `app.json` `application` or `platform` minimum versions, checks the compatibility-testing gate (compatibility testing is a check, not a commitment, and must not change the manifest versions), and surfaces the NextMajor branch decision. It sources from the `upgrade` knowledge domain and cites curated rules where a version-bump concern maps onto one (breaking changes only on tables without data, enum values additive at the end, no external calls in an upgrade codeunit); the governance gates the corpus does not encode are agent findings within its release-governance domain. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `pr-diff` (the standard entry point for a version-bump PR) or a `repository`. It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `upgrade` as the citable candidate set across every enabled layer: breaking changes only on tables without data, enum values additive at the end, no external calls in an upgrade codeunit, and upgrade tags instead of version checks each map onto a curated rule and MUST cite it rather than be paraphrased, because a major bump is the moment those rules bite. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. The governance gates (whether all customer environments are on the latest major before a NextMajor branch is cut, whether compatibility testing changed the manifest, whether the current Production version still compiles) are not encoded in the corpus; for those concrete defects, emit an agent finding within this skill's release-governance domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the PR branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the changed objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the governance signals in the PR:

- Changes to `app.json` `application` or `platform` minimum versions: whether the bump is a genuine commitment or compatibility testing that should not have touched the manifest.
- Whether the change could instead be made on the current Production version (the rule is to refactor on the current version first and branch NextMajor only when the change cannot work on the older version).
- The driving reason for a NextMajor branch when one is implied: a new API surface only on NextMajor, a Microsoft-required schema change, or a performance feature needed for a customer SLA; documented in the PR description.
- Schema and enum changes riding along with the bump that the `upgrade` corpus governs: a breaking change on a table that already holds data, an enum value inserted in the middle, an external call added to an upgrade codeunit.
- Deprecation-warning handling: warnings resolvable on the current version should be fixed forward, not deferred into a manifest bump.

A curated `upgrade` file enters the worklist when its `keywords` intersect these tokens (for example `breaking-change`, `enum`, `upgrade`, `version`). Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each signal, emit a finding.

When a defect maps onto a curated `upgrade` rule (a breaking change on a table with data, a non-additive enum change, an external call in an upgrade codeunit), emit a knowledge-backed finding citing that file: `id` equal to the file path, the file as primary reference, `severity` up to `blocker` only when the file states a platform-level guarantee otherwise `major`, `confidence` `high` for an unambiguous match.

When a governance defect has no curated rule (a manifest version bump made for compatibility testing rather than commitment, a change that could have stayed on the current version, a NextMajor branch implied with no documented driving feature, a deprecation warning deferred into a bump that was resolvable forward), emit an agent finding within this skill's release-governance domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:compatibility-test-changed-manifest`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` describing the governance gap and the concrete remedy (revert the manifest bump and keep compatibility testing as a check, document the driving feature, fix the warning forward). Where the impact would normally gate (premature NextMajor commitment that strands customers on older majors), keep `severity` at `minor` but say so plainly in the `message` and note the concern should be promoted to a knowledge-backed rule before it can gate. Hold every candidate to the precision bar in `skills/do.md`: steelman that the bump is a deliberate, communicated decision before emitting, and omit when in doubt. Before emitting any agent candidate, check the worklisted knowledge for a match and upgrade it to a knowledge-backed finding if one exists.

Set `suggested-code` when the fix is a single contiguous manifest revert (restoring the prior `application` or `platform` value); otherwise set `suggested-code-omission-reason` (for example `requires a PR-description note documenting the driving feature`).

Outcome selection: `completed` when every signal was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the PR does not bump the application or platform version; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-major-release-readiness", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 2, "items-evaluated": 2 }
  },
  "findings": [
    {
      "id": "agent:compatibility-test-changed-manifest",
      "severity": "minor",
      "message": "This PR bumps app.json platform from 26.0 to 27.0 but the description frames it as compatibility testing for the next major. Compatibility testing is a check, not a commitment, and must not change the manifest versions, otherwise the build commits every tenant to the new platform. Revert the platform value and run compatibility testing against a Sandbox-NextMajor environment instead. This concern should be promoted to a knowledge-backed rule before it can gate.",
      "location": {
        "file": "app.json",
        "line": 22
      },
      "references": [],
      "confidence": "medium",
      "suggested-code": "  \"platform\": \"26.0.0.0\","
    }
  ],
  "suppressed": []
}
```
