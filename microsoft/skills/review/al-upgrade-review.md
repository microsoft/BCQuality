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

Read the BCQuality knowledge index once — the `knowledge-index.json` BCQuality builds at the root of the knowledge checkout (Entry's preparation step regenerates it over the live, already-filtered clone — see `skills/entry.md`). It lists every article that survived layer and allow/deny filtering and carries, per article, its `path`, `layer`, `domain`, frontmatter dimensions, `keywords`, `title`, and a one-line `description` hint — exactly the fields Relevance and Worklist consume. Take the index entries whose `domain` is `upgrade` as this skill's candidate set across every enabled layer; do not open the individual article files at this step. Open an article's full body only once it enters the Worklist below, so a review reads the index plus the handful of worklisted articles instead of every file under `*/knowledge/upgrade/**`.

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
- The changed triggers and procedures, weighted toward `OnCheckPreconditionsPerCompany`/`PerDatabase`, `OnUpgradePerCompany`/`PerDatabase`, `OnValidateUpgradePerCompany`/`PerDatabase`, `OnInstallAppPerCompany`/`PerDatabase`, the `OnGetPerCompanyUpgradeTags`/`OnGetPerDatabaseUpgradeTags` subscribers, and helper procedures transitively reachable from those entry points.
- Tokens extracted from the diff that relate to upgrade concerns (`Subtype = Upgrade`, `Subtype = Install`, `Upgrade Tag`, `HasUpgradeTag`, `SetUpgradeTag`, `OnCheckPreconditions`, `OnUpgrade`, `OnValidateUpgrade`, `OnInstallApp`, `DataTransfer`, `CopyFields`, `Insert`, `Modify`, `Delete`, `Rename`, `InitValue`, `ObsoleteState`, `ObsoleteReason`, `ObsoleteTag`, `DataVersion`, `ExecutionContext`, `PrimaryKey`, `key(`, `field(`, `value(`, `enum`, `enumextension`, `HybridSL`, `HybridGP`, `HybridBC`, `HybridBaseDeployment`).
- For each `OnCheckPreconditions...` and `OnValidateUpgrade...` trigger, build the best available call graph from surrounding unchanged source as well as changed hunks, tracing resolved calls through reachable local or internal helpers. Worklist the check-only rule when a database write occurs either directly in the trigger or in any helper procedure reachable from it. Writes include `Insert`, `Modify`, `ModifyAll`, `Delete`, `DeleteAll`, `Rename`, and `DataTransfer`. Also perform the reverse check when a PR changes a writing helper body: worklist the rule when that helper is invoked directly or transitively by an unchanged check or validation trigger.
- Treat a direct write or a fully resolved call chain as high-confidence evidence. When cross-object dispatch, unavailable declarations, or an incomplete call graph prevents proving the complete chain, cap confidence at `medium`, name the unresolved edge in the finding, and do not claim a violation without a resolved path from a check or validation trigger to a write.
- Worklist the install-versus-upgrade rule when migration helpers are reachable only from an install codeunit.

A file enters the candidate worklist when its `keywords` intersect the extracted tokens or its topic (derived from the index entry's `path`, `title`, and `description`) matches a changed object type. Read an article's full file — its `## Best Practice` / `## Anti Pattern` bodies — only after it makes the worklist; candidate selection uses the index alone. When the diff contains no upgrade-related changes by any of the above signals, return `outcome: "not-applicable"` without evaluating files.

Once the candidate worklist is known, resolve layer-precedence conflicts per READ. Drop lower-precedence files whose normative guidance directly contradicts a higher-precedence candidate, and record each dropped file in `suppressed` with `reason: "layer-precedence"`. Files suppressed by configuration are recorded with `reason: "configuration"`.

When the post-conflict worklist is empty because no applicable upgrade knowledge exists, or because configuration suppressed every candidate, emit `outcome: "no-knowledge"`. When the worklist is empty because no applicable upgrade knowledge matched the changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections. Emit findings as follows:

- When the diff contains a clear match for an Anti Pattern, emit a finding with severity `major` or `blocker`, a message summarizing the anti-pattern, `location` pointing to the offending line or range, and a `references` entry pointing to the knowledge file. Use `blocker` for irreversible data corruption (enum-ordinal shift, unguarded reads that abort the upgrade) and for changes that would ship to customers without a migration path (new InitValue on an existing table without upgrade code).
- When the diff contains code that contradicts a Best Practice without being a full anti-pattern, emit `minor` with the same reference shape.
- When the skill cannot detect a violation but the file is clearly applicable to the change, emit `info` citing the file.

Set `confidence` to:

- `high` when the detection is based on an unambiguous pattern match and any required helper reachability is fully established.
- `medium` when detection relies on heuristics or when any frontmatter dimension was `unknown`.
- `low` when the finding is an advisory derived only from applicability.

After evaluating each worklist entry, also consider whether the diff exhibits a upgrade defect the agent recognises from its general AL knowledge that no knowledge file in the worklist covers. Such candidates are agent findings within this skill's domain — emit them with `references: []`, an `id` slug prefixed with `agent:`, `confidence` capped at `medium`, `severity` capped at `minor` (agent findings are advisory and non-gating), and a `message` that is self-contained (describing both the issue and a concrete recommendation, since there is no knowledge-file footer for the consumer to fall back on). Hold every candidate to the precision bar in `skills/do.md` (*Agent findings*): emit only a concrete, material upgrade or breaking-change defect a knowledgeable BC reviewer would agree is wrong — steelman it first and drop anything stylistic, speculative, dependent on code outside the diff, or merely a valid alternative; when in doubt, omit. The scope is strictly upgrade; defects outside this domain belong to other leaves and MUST NOT be emitted here. Before emitting, check the worklist for a knowledge file that matches the candidate — if one exists, upgrade the candidate to a knowledge-backed finding instead. See `skills/do.md` for the full contract.

For every emitted finding, decide whether the fix is mechanical. A fix is mechanical when it is small, local, and unambiguous from the diff context (for example: delete unreachable lines; replace `Count() > 0` with `not IsEmpty()`; move a local `Label` to object scope; add a missing `ToolTip`, `OptionCaption`, or `DataClassification`; replace a string-concatenated `Error` with a Label-backed call; change an over-broad permission token; or add an obvious `else`/guard branch). For mechanical findings, emit `findings[].suggested-code` with the literal replacement for the source lines indicated by `location`. The payload must be a verbatim replacement — no diff markers, no fences, no commentary — that the consumer can render as a one-click suggestion. When a `.good.al` companion exists and the diff context matches the `.bad.al` shape, adapt the `.good.al` replacement into `suggested-code`.

Omit `suggested-code` only when the appropriate fix depends on context the skill cannot determine, when multiple defensible replacements exist, or when the fix spans non-contiguous code. If a finding is mechanical-looking but you omit `suggested-code`, set `findings[].suggested-code-omission-reason` to a short explanation. See `skills/do.md` for the full contract.

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
      "id": "microsoft/knowledge/upgrade/enum-values-additive-at-end.md",
      "severity": "blocker",
      "message": "A new enum value was inserted at ordinal 1, shifting every subsequent value by one. Rows that store the old ordinal 1 will silently resolve to the new value. Per the referenced guidance, enum values must be appended at the end.",
      "location": {
        "file": "src/Shared/OrderStatus.Enum.al",
        "line": 7
      },
      "references": [
        { "path": "microsoft/knowledge/upgrade/enum-values-additive-at-end.md" }
      ],
      "confidence": "high"
    }
  ],
  "suppressed": []
}
```
