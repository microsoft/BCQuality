---
kind: action-skill
id: al-permission-set-auditor
version: 1
title: AL permission set audit
description: Audits that every object an AL extension defines appears in a permission set with appropriate scope, and emits a findings report.
inputs: [object-list, repository, pr-diff]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL permission set audit

Compares the objects a Business Central AL extension defines against the entries in its permission set files and reports every gap. This catches the silent-but-fatal class of bug where a new table ships without permission, the install succeeds in the developer SUPER sandbox, and tenants hit "Permission denied" on first use. It is also the single most common cause of AppSource rejection (the AS0029 family). This skill sources from the `security` domain and cites curated permission-set guidance where present, otherwise it emits agent findings within its security and permissioning domain. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with an `object-list`, a `repository`, or a `pr-diff`. It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `security` as the citable candidate set across every enabled layer, weighted toward permission-set guidance: minimal-grant, avoiding wildcard grants, indirect and inherent permissions. A scope that grants more than the usage warrants maps onto a curated rule and MUST cite it rather than be paraphrased. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. The object-to-permission coverage gap itself (a defined object with no permission entry, a `table` line with no `tabledata` line) is not encoded in the corpus; for those concrete defects, emit an agent finding within this skill's security and permissioning domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the changed objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Build the object-to-permission map and narrow to the gaps:

- Walk the supplied `object-list` (or the source under `repository`) to build the set of `(ObjectType, ObjectName)` declarations. When a `pr-diff` is the input, narrow to the objects the diff adds or renames.
- Walk every `*.PermissionSet.al` the extension defines to build the set of granted entries.
- For each defined object, the gap set is: no matching permission entry anywhere; a `table` entry with no corresponding `tabledata` entry; a `tabledata` scope wider than the object's actual usage; a public codeunit with callable procedures and no entry, or an `Access = Internal` codeunit with a redundant entry; an orphan entry that matches no defined object; a permission set with an empty or non-meaningful `Caption`; a permission set whose own ID falls outside the `app.json` id range.

A curated `security` permission-set file enters the worklist when its `keywords` intersect these tokens (for example `permission-set`, `tabledata`, `wildcard`, `minimal-grant`). Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each gap, emit a finding.

When the gap is an over-broad or wildcard scope that maps onto a curated `security` rule (a `tabledata` grant wider than the usage, a wildcard grant), emit a knowledge-backed finding citing that file: `id` equal to the file path, the file as primary reference, `severity` up to `blocker` only when the file states a platform-level guarantee otherwise `major`, `confidence` `high` for an unambiguous match.

When the gap is a coverage defect with no curated rule (a defined object missing from every permission set, a `table` entry with no `tabledata` line, an orphan entry, a missing or noise `Caption`, a permission set out of the id range), emit an agent finding within this skill's security and permissioning domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:object-missing-from-permission-set` or `agent:table-without-tabledata`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` naming the object, the permission set, and the exact entry to add. Where the impact would normally gate (a new table absent from every permission set, which AppSource rejects), keep `severity` at `minor` but say so plainly in the `message` and note the concern should be promoted to a knowledge-backed rule before it can gate. Hold every candidate to the precision bar in `skills/do.md`: steelman that the object is intentionally not granted (a pure framework object behind `Access = Internal`) before emitting, and omit when in doubt. Before emitting any agent candidate, check the worklisted knowledge for a match and upgrade it to a knowledge-backed finding if one exists.

Set `suggested-code` when the fix is the exact permission line to add (for example `tabledata "Event Registration" = RIMD;`); otherwise set `suggested-code-omission-reason`. Group repeated instances of one concern into a single finding rather than many near-identical ones.

Outcome selection: `completed` when every object was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the task has no objects or permission sets to compare; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-permission-set-auditor", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 47, "items-evaluated": 47 }
  },
  "findings": [
    {
      "id": "agent:table-without-tabledata",
      "severity": "minor",
      "message": "Table 50100 Event Registration is granted as a table entry in permission set MyExt All but has no tabledata entry, so the metadata is exposed but read and write are denied. Add the tabledata line beneath the existing table line. Impact would normally be major because AppSourceCop AS0029 rejects this; emitted as minor because no curated rule backs it. This concern should be promoted to a knowledge-backed rule before it can gate.",
      "location": {
        "file": "src/MyExt.PermissionSet.al",
        "line": 12
      },
      "references": [],
      "confidence": "medium",
      "suggested-code": "                tabledata \"Event Registration\" = RIMD;"
    }
  ],
  "suppressed": []
}
```
