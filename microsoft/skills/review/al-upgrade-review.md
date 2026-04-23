---
kind: action-skill
id: al-upgrade-review
version: 1
title: AL upgrade review
description: Reviews AL source changes against upgrade-code and migration guidance from BCQuality.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL upgrade review

Reviews AL source changes against the `upgrade` knowledge domain in BCQuality and emits a findings report. This is a leaf action skill: it invokes no sub-skills. It is one of the skills composed by `al-code-review`.

An orchestrator invokes this skill with either a `pr-diff` (the standard PR-review entry point) or a `file-path` (single-file review). Upgrade findings are narrow by design — they apply when the diff touches upgrade codeunits, install codeunits, table schema, enums, or objects under migration namespaces. The skill returns `not-applicable` when none of those apply.

## Source

Collect all knowledge files under `*/knowledge/upgrade/**/*.md`, across every enabled layer (`/microsoft/`, `/community/`, `/custom/`). Relevance trims the result to the subset that applies.

## Relevance

Apply the frontmatter matching rules defined in READ (*Frontmatter matching semantics*) against the task context:

- `bc-version` — the target BC version from the PR branch's `app.json` or the orchestrator-supplied version. If unavailable, the dimension is `unknown`.
- `technologies` — `[al]`.
- `countries` — the countries declared in the consuming app's `app.json`. Default to the orchestrator's configured context; if absent, `unknown`.
- `application-area` — the union of application areas declared by the changed objects. Pass the actual set; do not substitute `[all]`. If the area cannot be determined from the changes, the dimension is `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when the orchestrator's configuration permits them; findings derived from those files MUST have `confidence` no higher than `medium`, AND the finding's `message` MUST name the dimension or dimensions that were unknown.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review. For each relevant file, compute overlap against:

- The changed AL object names and types — especially codeunits with `Subtype = Upgrade` or `Subtype = Install`, tables and tableextensions adding or changing fields, enums and enumextensions, and objects under `Hybrid*`/`Migration`/`Upgrade` namespaces.
- The changed triggers and procedures, weighted toward `OnUpgradePerCompany`, `OnUpgradePerDatabase`, `OnInstallAppPerCompany`, and the `OnGetPerCompanyUpgradeTags`/`OnGetPerDatabaseUpgradeTags` subscribers.
- Tokens extracted from the diff that relate to upgrade concerns (`Subtype = Upgrade`, `Upgrade Tag`, `HasUpgradeTag`, `SetUpgradeTag`, `DataTransfer`, `InitValue`, `ObsoleteState`, `ObsoleteReason`, `ObsoleteTag`, `DataVersion`, `ExecutionContext`, `value(`, `enum`, `enumextension`).

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic matches a changed object type. When the diff contains no upgrade-related changes by any of the above signals, return `outcome: "not-applicable"` without evaluating files.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ. Drop lower-precedence files whose normative guidance directly contradicts a higher-precedence candidate, and record each dropped file in `suppressed` with `reason: "layer-precedence"`. Files suppressed by configuration are recorded with `reason: "configuration"`.

When the post-conflict worklist is empty because no applicable upgrade knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable upgrade knowledge matched the changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. Emit findings as follows:

- When the diff contains a clear match for an Anti Pattern, emit a finding with severity `major` or `blocker`, a message summarizing the anti-pattern, `location` pointing to the offending line or range, and a `references` entry pointing to the knowledge file. Use `blocker` for irreversible data corruption (enum-ordinal shift, unguarded reads that abort the upgrade) and for changes that would ship to customers without a migration path (new InitValue on an existing table without upgrade code).
- When the diff contains code that contradicts a Best Practice without being a full anti-pattern, emit `minor` with the same reference shape.
- When the skill cannot detect a violation but the file is clearly applicable to the change, emit `info` citing the file.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match.
- `medium` when detection relies on heuristics or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

Outcome selection:

- `completed` — the skill evaluated every worklist item.
- `no-knowledge` — no applicable upgrade knowledge survived filtering.
- `not-applicable` — the diff touches no upgrade, install, schema, or enum surface.
- `partial` — a budget was hit before the worklist was exhausted.
- `failed` — an unrecoverable error occurred.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-upgrade-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 1, "major": 0, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 1, "items-evaluated": 1 }
  },
  "findings": [
    {
      "id": "microsoft/knowledge/upgrade/enum-changes-must-be-additive-at-the-end.md",
      "severity": "blocker",
      "message": "A new enum value was inserted at ordinal 1, shifting every subsequent value by one. Rows that store the old ordinal 1 will silently resolve to the new value. Per the referenced guidance, enum values must be appended at the end.",
      "location": {
        "file": "src/Shared/OrderStatus.Enum.al",
        "line": 7
      },
      "references": [
        { "path": "microsoft/knowledge/upgrade/enum-changes-must-be-additive-at-the-end.md" }
      ],
      "confidence": "high"
    }
  ],
  "suppressed": []
}
```
