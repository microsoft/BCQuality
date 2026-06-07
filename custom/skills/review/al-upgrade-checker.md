---
kind: action-skill
id: al-upgrade-checker
version: 1
title: AL upgrade coverage review
description: Verifies that schema changes in an AL extension are handled by an upgrade codeunit for existing-tenant data, and emits a findings report.
inputs: [pr-diff, repository]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL upgrade coverage review

Compares a schema diff against the extension's upgrade codeunit and reports every migration that is missing or broken. It catches the silent install failure: a clean install on a dev sandbox, then `Install-NAVApp` errors on production tenants because existing data is not migrated. The skill covers new required fields, fields with `InitValue`, field renames, type or length narrowing, obsoleted fields, enum value changes, primary key changes, per-company versus per-database scope, idempotency, and upgrade-tag registration. It sources from the `upgrade` knowledge domain and cites curated rules where a schema change maps onto one; gaps the corpus does not encode are agent findings within its upgrade domain. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `pr-diff` (the standard PR-review entry point) or a `repository`. It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `upgrade` as the citable candidate set across every enabled layer: `InitValue` not updating existing rows, upgrade tags instead of version checks, `DataTransfer` for bulk init, enum values added at the end, guarding database reads, and no external calls in an upgrade codeunit each map onto a curated rule and MUST cite it rather than be paraphrased. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. Where a concrete migration gap has no curated rule (a per-company migration that touches a per-database surface, a non-idempotent migration, a wire-contract break that an upgrade codeunit alone cannot fix), emit an agent finding within this skill's upgrade domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the changed objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Compute the schema diff and narrow to the changes that need a migration:

- New required or non-nullable fields with no default, and new fields with an `InitValue` that downstream code assumes is populated on existing rows.
- Field renames (AL `Rename` moves only metadata, not data, and does not rewrite JSON keys that store the old field name).
- Field type or length narrowing (Code[20] to Code[10], Text[100] to Text[50], Decimal to Integer) where existing rows hold out-of-bound values.
- Obsoleted fields whose data the upgrade codeunit must migrate before the Removed cycle, and any `Obsolete Removed` with no prior `Pending`.
- Enum value reorders or renames that break serialised ordinals or AL identifier comparisons, and additions to a non-Extensible versus Extensible enum.
- Primary key changes that require existing rows to disambiguate.
- The upgrade codeunit itself: `OnUpgradePerCompany` versus `OnUpgradePerDatabase` scope, idempotency of each step, and a unique `UpgradeTag` registered per step so re-publishes skip applied work.
- Wire-contract impact when the schema change affects an exposed API shape.

A curated `upgrade` file enters the worklist when its `keywords` intersect these tokens (for example `initvalue`, `upgrade-tag`, `datatransfer`, `enum`, `rename`, `obsolete`). Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each schema change, check the upgrade codeunit covers it and emit findings.

When a gap maps onto a curated `upgrade` rule (a new field relying on `InitValue` for existing rows, a missing upgrade tag, an enum value added in the middle), emit a knowledge-backed finding citing that file: `id` equal to the file path, the file as primary reference, `severity` up to `blocker` only when the file states a platform-level guarantee otherwise `major`, `confidence` `high` for an unambiguous match. State the tenants affected in the `message`.

When a concrete migration gap has no curated rule (a per-company step that writes a per-database surface and risks duplicate writes, a non-idempotent migration that appends rows on re-run, a primary-key change with no disambiguation, a wire-contract break needing an API version bump), emit an agent finding within this skill's upgrade domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:non-idempotent-upgrade-step`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` describing the failure on tenants with existing data and a concrete fix. Where the impact would normally gate (a missing migration that fails the install), keep `severity` at `minor` but say so plainly in the `message` and note the concern should be promoted to a knowledge-backed rule before it can gate. Hold every candidate to the precision bar in `skills/do.md`: steelman that the migration is covered by a step outside the diff before emitting, and omit when in doubt. Before emitting any agent candidate, check the worklisted knowledge for a match and upgrade it to a knowledge-backed finding if one exists.

Set `suggested-code` when the fix is mechanical (wrapping a step in `UpgradeTagMgt.HasUpgradeTag`/`SetUpgradeTag`); otherwise set `suggested-code-omission-reason` (for example `requires authoring a new upgrade step body`).

Outcome selection: `completed` when every schema change was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the diff has no schema change to review; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-upgrade-checker", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 3, "items-evaluated": 3 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/upgrade/initvalue-does-not-update-existing-rows.md",
      "severity": "major",
      "message": "A required enum field Status Code was added to table Event Registration with no upgrade step. InitValue applies to new rows only, so every existing row on every tenant is left empty. Add a step to OnUpgradePerCompany that sets Status Code to Draft on existing rows, behind a fresh UpgradeTag.",
      "location": {
        "file": "src/EventRegistration.Table.al",
        "line": 30
      },
      "references": [
        { "path": "microsoft/knowledge/upgrade/initvalue-does-not-update-existing-rows.md" }
      ],
      "confidence": "high"
    }
  ],
  "suppressed": []
}
```
