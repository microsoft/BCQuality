---
kind: action-skill
id: al-appsource-validator
version: 1
title: AL AppSource submission validation
description: Audits an AL extension against AppSourceCop rules, app.json metadata, artefacts, links, and the dependency chain, and emits a findings report.
inputs: [repository, object-list]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL AppSource submission validation

Audits a Business Central extension against the rules Microsoft's AppSource validation applies, plus the soft conventions that surface in the manual review pass, so the developer fixes gates locally rather than after a multi-day Microsoft review cycle. It reports each finding against the `AS0xxx` rule that will flag it. Coverage spans `app.json` metadata completeness, object suffix discipline, object id ranges, permission-set coverage, prohibited objects, translations, logo and screenshots, EULA and privacy and help and url links, the dependency chain, runtime-versus-target-versus-application alignment, demo and dev artefacts, telemetry consent, id collisions, and the marketplace listing checklist folded in from the AppSource validation playbook. It sources from the `security` and `style` knowledge domains and cites curated rules where present; the AppSource-specific gates the corpus does not encode are agent findings within its AppSource compliance domain. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `repository` or an `object-list`. It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `security` or `style` as the citable candidate set across every enabled layer: permission-set minimal-grant and wildcard guidance, captions and tooltips required on page fields, and label discipline each map onto a curated rule and MUST cite it rather than be paraphrased. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. The AppSource gates themselves (a `AS0xxx` rule violation, a dead link, a missing logo, a runtime mismatch, the listing-metadata checklist) are not encoded in the corpus; for those concrete defects, emit an agent finding within this skill's AppSource compliance domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries (the `supportedCountries`), or `unknown`.
- `application-area`: the application areas of the extension's objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the submission gates for the extension under review:

- `app.json` metadata: `id` a stable GUID, `name`/`publisher`/`version` matching the listing, `brief` (empty is AS0036) and `description`, `privacyStatement`, `EULA`, `help`, `url`, `logo`, `runtime`, `target` (`Cloud` for AppSource), `application`, `platform`, all set and not the AL scaffold default; `showMyCode` set only when intentional.
- Object suffix discipline against the `AppSourceCop.json` `mandatorySuffix` (AS0040/AS0041), object ids inside `idRanges` (AS0072), no objects in the system range, no use of Microsoft `Access = Internal` platform objects.
- Permission-set coverage (the AS0029-class tabledata gap), and `supportedCountries` each having an xliff (AS0091).
- Logo PNG at least 350 by 350 and square; at least one screenshot present per the manifest; EULA, privacy, help, and url links resolving with a 2xx HEAD response.
- Dependencies each with `id`/`name`/`publisher`/`version`, version either `0.0.0.0` or a real published version, `propagateDependencies` set when downstream consumers need access (AS0078/AS0079); `runtime` aligned with `target` and `application`; object ids not colliding with the platform or other dependency-chain extensions.
- No demo or dev artefacts in src (`RunModal` in startup paths, hardcoded passwords, demo `Confirm` boxes, `Sleep` in production codeunits); telemetry consent stated in the privacy statement when `applicationInsightsConnectionString` is set.
- Marketplace listing checklist folded in from the AppSource validation playbook: search summary 100 characters or under, description leading with the value proposition, signing via the Key Vault pipeline, README/SETUP/SUPPORT files, support email pointing at the team inbox rather than a personal address, privacy and terms URLs live.

A curated `security` or `style` file enters the worklist when its `keywords` intersect these tokens (for example `permission-set`, `caption`, `tooltip`, `label`). Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each gate, emit a finding.

When the gate maps onto a curated `security` or `style` rule (an over-broad permission grant, a page field missing a `Caption` or `ToolTip`), emit a knowledge-backed finding citing that file: `id` equal to the file path, the file as primary reference, `severity` up to `blocker` only when the file states a platform-level guarantee otherwise `major`, `confidence` `high` for an unambiguous match.

When the gate is an AppSource-specific defect with no curated rule, emit an agent finding within this skill's AppSource compliance domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:as0036-empty-brief` or `agent:runtime-target-mismatch`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` naming the `AS0xxx` rule or listing requirement and the concrete fix. Where the impact would normally gate (any hard AppSource rejection), keep `severity` at `minor` but say so plainly in the `message` and note the concern should be promoted to a knowledge-backed rule before it can gate. Hold every candidate to the precision bar in `skills/do.md`: steelman that the field is intentionally set as-is before emitting, and omit when in doubt. Before emitting any agent candidate, check the worklisted knowledge for a match and upgrade it to a knowledge-backed finding if one exists.

Set `suggested-code` when the fix is a single contiguous metadata edit (setting a `brief` value, correcting a `runtime` number); otherwise set `suggested-code-omission-reason` (for example `requires creating a logo asset` or `requires a live privacy-policy URL`).

Outcome selection: `completed` when every gate was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the task has no extension manifest to validate; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-appsource-validator", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 14, "items-evaluated": 14 }
  },
  "findings": [
    {
      "id": "agent:as0036-empty-brief",
      "severity": "minor",
      "message": "app.json brief is empty. AppSource validation rejects an empty brief under AS0036. Set brief to a one-sentence summary of 100 characters or fewer. Impact would normally be a blocker because it is a hard AppSource rejection; emitted as minor because no curated rule backs it. This concern should be promoted to a knowledge-backed rule before it can gate.",
      "location": {
        "file": "app.json",
        "line": 9
      },
      "references": [],
      "confidence": "medium",
      "suggested-code": "  \"brief\": \"Stage-and-forward integration for warehouse shipments.\","
    }
  ],
  "suppressed": []
}
```
