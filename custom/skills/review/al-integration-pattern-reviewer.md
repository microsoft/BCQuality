---
kind: action-skill
id: al-integration-pattern-reviewer
version: 1
title: AL integration pattern review
description: Validates AL inbound, outbound, long-running, and manual integration code against the modern integration patterns, and emits a findings report.
inputs: [pr-diff, file-path, repository]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL integration pattern review

Validates Business Central integration code against the modern integration patterns. The single question is: when the external system is slow, down, or sends the same message twice, does this code stay correct? It audits staging via an Integration Message, inbound and outbound idempotency, polling framing records, Business Event versioning and payload safety, correlation propagation, staged pipelines, and the hard anti-patterns (HTTP calls from posting, synchronous wait loops in API handlers, inline posting from a webhook or poll handler). This skill is the executor for the `integration` knowledge domain: it cites the curated integration files by path for the concerns they cover, and supplements them with `performance` and `security` citations and agent findings. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `pr-diff`, a `file-path`, or a `repository`. It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `integration`, `performance`, or `security` as the citable candidate set across every enabled layer. The `integration` domain is the primary source: cite `custom/knowledge/integration/stage-every-integration-message.md` for the staging requirement and decoupling, and `custom/knowledge/integration/never-call-external-services-from-posting.md` for the callout-from-posting anti-pattern, and any further integration files the index lists for idempotency, framing, business-events versioning, and correlation. The `performance` and `security` domains supply supporting citations: a commit inside a fetch or send loop, a user prompt inside a posting transaction, and an integration event that leaks a secret each map onto a curated rule. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. Where a concrete integration defect has no curated rule, emit an agent finding within this skill's integration domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the changed objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the integration code paths under review:

- Codeunits that call `HttpClient`, especially any reachable from a posting routine or a posting event subscriber (`OnAfterPostSalesDoc`, `OnAfterFinalizePosting`, and similar).
- `PageType = API` pages used as inbound staging endpoints, and any handler that posts or runs business logic inline rather than writing to staging.
- Job Queue codeunits that fetch from or push to an external system, weighted toward a missing framing record (last fetch, max window, lock), an unbounded "fetch all", a missing inbound idempotency lookup on External Reference plus Type, and a missing or non-deterministic outbound `Idempotency-Key`.
- `[BusinessEvent]` declarations: a per-version events codeunit, a versioned name, a stable minimal DTO payload (not the BC record, no secrets), and validation before firing.
- Correlation ID set once at the entry point and carried onto every staged message, event payload, and outbound header.
- Long-running flows: a 202 response parked Awaiting Reply with a status URL, retry count and last error stored on the message, and staged pipelines split behind an integration-stage interface dispatched from an extensible enum with no cross-stage global state.
- Pages and actions that let a human re-run a failed message.

A curated `integration`, `performance`, or `security` file enters the worklist when its `keywords` intersect these tokens (for example `staging`, `posting`, `httpclient`, `idempotency`, `business-event`, `correlation`, `commit`, `secret`). Read its full `## Best Practice` / `## Anti Pattern` body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each worklisted code path, check it against the patterns and emit findings.

When a defect maps onto a curated knowledge file, emit a knowledge-backed finding citing that file: `id` equal to the file path, the file as primary reference, `confidence` `high` for an unambiguous match. Severity is `blocker` only when the file states a platform-level guarantee, otherwise `major`. The hard anti-patterns cite the integration corpus directly: an `HttpClient.Send` reachable from a posting routine or posting subscriber cites `custom/knowledge/integration/never-call-external-services-from-posting.md`; a webhook or poll handler that posts or runs business logic inline rather than staging cites `custom/knowledge/integration/stage-every-integration-message.md`. A commit inside a fetch or send loop, a user prompt inside a posting transaction, or an integration event that exposes a secret cite the matching `performance` or `security` file.

When a concrete, demonstrable integration defect has no curated rule (a synchronous sleep-and-poll wait loop in an inbound API handler, a missing polling framing record or lock, a missing inbound idempotency lookup keyed on the source id, a missing or non-deterministic outbound idempotency key, a mutated published Business Event signature, a dropped correlation id, cross-stage global state), emit an agent finding within this skill's integration domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:missing-inbound-idempotency-check`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` describing the failure mode under a slow, down, or duplicating external system and a concrete fix. Where the impact would normally gate (a synchronous wait loop that ties up a handler), keep `severity` at `minor` but say so plainly in the `message` and note the concern should be promoted to a knowledge-backed rule before it can gate. Hold every candidate to the precision bar in `skills/do.md`: steelman that the path is correct as written before emitting, and omit when in doubt. Before emitting any agent candidate, check the worklisted knowledge for a match and upgrade it to a knowledge-backed finding if one exists.

Set `suggested-code` when the fix is mechanical (adding a deterministic `Idempotency-Key` header from the Integration Message GUID, moving a `Commit` out of a loop); otherwise set `suggested-code-omission-reason` (for example `requires introducing a staging table and Job Queue sender`).

Outcome selection: `completed` when every worklist item was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the diff has no integration code to review; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-integration-pattern-reviewer", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 3, "items-evaluated": 3 }
  },
  "findings": [
    {
      "id": "custom/knowledge/integration/never-call-external-services-from-posting.md",
      "severity": "major",
      "message": "HttpClient.Send is called from WMS Notifier.NotifyWMS, which runs in OnAfterPostSalesDoc. The posting transaction holds locks on the shipment while waiting on the WMS. Stage an Integration Message inside the posting hook and let the Job Queue send it.",
      "location": {
        "file": "src/WMSNotifier.Codeunit.al",
        "line": 31
      },
      "references": [
        { "path": "custom/knowledge/integration/never-call-external-services-from-posting.md" }
      ],
      "confidence": "high"
    },
    {
      "id": "agent:missing-outbound-idempotency-key",
      "severity": "minor",
      "message": "The outbound POST to the WMS sets no Idempotency-Key header, so a retry after a timeout can create a duplicate shipment on the remote system. Set the header to the Integration Message GUID so it is identical on every retry. Impact would normally be major; emitted as minor because no curated rule backs it. This concern should be promoted to a knowledge-backed rule before it can gate.",
      "location": {
        "file": "src/WMSSender.Codeunit.al",
        "line": 64,
        "range": { "start-line": 64, "end-line": 68 }
      },
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "requires the Integration Message GUID variable in scope at the call site"
    }
  ],
  "suppressed": []
}
```
