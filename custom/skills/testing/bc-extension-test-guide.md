---
kind: action-skill
id: bc-extension-test-guide
version: 1
title: BC extension test guide generator
description: Inventories every page, field, relation, enum, action, state machine, permission set, and telemetry event and emits a category-driven release-audit TEST_GUIDE.md.
inputs: [repository, object-list]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# BC extension test guide generator

Produces an exhaustive `DOCS/TEST_GUIDE.md` for a Business Central AL extension. The guide is exhaustive by construction: every field, relation, action, and reachable data state in the AL source appears in at least one of twelve category inventories, so the state pivots happy-path testing misses are caught. This is a generator-style skill: the generated guide markdown is carried as a finding's `suggested-code`, and the `## Action` step explains what is generated. It produces the artifact; it does not run tests. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `repository` (the extension root with `app.json` and AL `src/`) and optionally an `object-list` (a scope narrowing the inventory). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `testing`, `ux`, `security`, or `telemetry` as the citable candidate set across every enabled layer: the twelve categories pull on lookup, type-conditional relation, visibility-refresh, state-machine, permission-boundary, cross-company isolation, and telemetry-event rules, so a category whose contract matches a curated rule cites it. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. The generated guide itself, where no curated rule covers a category, is an agent finding within this skill's domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the repository `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the inventoried objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the full AL inventory the twelve categories require. Discover the repo (`app.json`, `.AL-Go/settings.json`, the primary app folder, the `src/**/*.al` file list), then build the inventory across these categories:

1. Lookup audit: every page field whose underlying table field has a `TableRelation`, both directions.
2. Type-conditional `TableRelation`: every relation conditional on a sibling field, and each sibling enum or option value mapped to its target table.
3. Eligibility filters: every lookup whose downstream `OnValidate` or OK handler rejects a subset of the target table, and whether the lookup pre-filters it.
4. Visibility and Editable conditionals: every dynamic `Visible`/`Editable`, its driver, and whether the driver's `OnValidate` forces a `CurrPage.Update(false)` refresh.
5. StandardDialog Mode pivots: every `PageType = StandardDialog` with a Mode selector, the visible-field set, OK side effect, and error per Mode.
6. Subpage FK persistence: every `part(...)` with a `SubPageLink`, the FK propagated, and whether the explicit-push pattern or default-value behaviour alone is in use.
7. State machine transitions: every status enum, its full from-by-to matrix marking allowed and disallowed transitions, and every code path mutating the status.
8. Permission boundaries: every permission set with full RIMD per table and page or codeunit execute claims.
9. Telemetry events: every custom-event log call site with event id, trigger, and payload keys.
10. Mobile and tablet smoke: every top-level user-facing page.
11. Cross-company isolation: every table with its `DataPerCompany` value, singletons called out.
12. Upgrade paths: every upgrade codeunit and per-release schema delta with seed instructions.

Scope the inventory by `object-list` when supplied. A curated `testing`, `ux`, `security`, or `telemetry` file enters the worklist when its `keywords` intersect a category's tokens. Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

Generate `DOCS/TEST_GUIDE.md` with exactly the twelve categories in order, each carrying a definition, a procedure, and a populated inventory drawn from the actual AL (no placeholders). Run the self-audit pass: every `TableRelation` lands in category 1 or 2, every dynamic `Visible`/`Editable` in category 4, every `SubPageLink` in category 6, every status enum in category 7, every permission set in category 8, every telemetry call site in category 9; if an inventory has fewer rows than the AL warrants, the guide is incomplete and the missing rows are added. Emit one finding carrying the generated guide. Where a curated file backs a category contract (a state-machine rule, a cross-company isolation rule, a telemetry payload rule), cite it: `id` equal to the file path, `references` carrying it, `severity` `info`, `confidence` `high` for an unambiguous match. Where no curated file applies, emit an agent finding: `references: []`, `id` slug prefixed `agent:` (for example `agent:generated-test-guide`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` stating the guide was generated, the categories that genuinely do not apply (stated explicitly, not stubbed), and the path to write it to. Put the generated markdown in `suggested-code`. Emit an `info` finding recommending the cross-link in `USER_GUIDE.md`. Hold every agent finding to the precision bar in `skills/do.md`.

Outcome selection: `completed` when the full inventory was built and the guide generated (including categories that do not apply, stated as such); `not-applicable` when the repository has no `app.json` and AL `src/`; `partial` when a token budget truncated the inventory (`summary.coverage` reflects the categories completed); `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. The generated guide with no curated backing is an agent finding (`references: []`, `agent:` id, severity capped at `minor`, markdown in `suggested-code`); findings citing a `testing`, `ux`, `security`, or `telemetry` file carry that file path as `id` and primary reference.

```json
{
  "skill": { "id": "bc-extension-test-guide", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 1 },
    "coverage": { "worklist-size": 12, "items-evaluated": 12 }
  },
  "findings": [
    {
      "id": "agent:generated-test-guide",
      "severity": "minor",
      "message": "Generated DOCS/TEST_GUIDE.md with all 12 categories populated from src/ (47 TableRelation rows in cat 1/2, 3 status enums in cat 7, 2 permission sets in cat 8). Category 12 (Upgrade paths) is empty: the extension ships no upgrade codeunit, stated explicitly in the guide rather than stubbed.",
      "location": { "file": "DOCS/TEST_GUIDE.md" },
      "references": [],
      "confidence": "medium",
      "suggested-code": "# <Extension Name>, Test Guide\n\n## 0. Category index\n... (12 categories, each with definition, procedure, and inventory table) ..."
    },
    {
      "id": "agent:userguide-cross-link",
      "severity": "info",
      "message": "Add a cross-link in the USER_GUIDE.md header pointing to the new TEST_GUIDE.md so QA can find the audit companion.",
      "references": [],
      "confidence": "medium"
    }
  ],
  "suppressed": []
}
```
