---
kind: action-skill
id: azure-integration-review
version: 1
title: Azure integration review
description: The integration-plane review playbook for the Azure side of a BC integration, pairing with the BC-side validator.
inputs: [repository, pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [bicep, csharp]
countries: [w1]
application-area: [all]
---

# Azure integration review

Reviews the Azure side of a Business Central integration as a playbook: the webhook receiver that catches a storefront event, the Logic App that routes a shipment to a WMS, the Service Bus topic that carries Business Events, the Durable Function that schedules a retry, and the Bicep, ARM, or Terraform that provisions them. The integration plane earns its keep by keeping retry, dead-letter, observability, and credential handling outside BC, so BC stays free of external credentials and third-party schema changes do not break it. This skill pairs with the BC-side `azure-integration-validator` so the inbound, outbound, long-running, and manual arrows line up end to end. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `repository`, a `pr-diff` (a change to the integration plane), or a `file-path` (a specific artifact to review). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `integration` or `security` as the citable candidate set across every enabled layer; the playbook's rules about receivers, idempotency, retry, dead-letter, correlation, observability, long-running poll, subscription health, and secret handling can match a curated file. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. The Azure-side house rules are largely not covered by a BC-focused curated file, so most findings are agent findings within this skill's domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the BC version the plane integrates with, or `unknown` if unavailable.
- `technologies`: `[bicep, csharp]` (the infrastructure-as-code and Function handler code the playbook reviews).
- `countries`: the consuming solution's declared countries, or `unknown`.
- `application-area`: the application areas of the integration, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the artifacts present and the playbook rules each draws. If the repository has no Azure artifacts, report that plainly rather than inventing findings. Read Bicep, ARM, and Terraform that provision Functions, Logic Apps, APIM, Service Bus, and Storage; Logic App and workflow definitions; Function app config (`host.json`, `function.json`); APIM policy XML; and pipeline files. Place each artifact on the four arrows (inbound, outbound, long-running, manual) and build the worklist against the playbook rules: receiver stages to BC, receiver acknowledges fast, idempotency key forwarded, idempotent consumer, retry in the plane, dead-letter configured, transient versus permanent classification, durable retry not a tight loop, correlation header on every hop, observability wired, 202 status poll for long-running, subscription health check, secrets in Key Vault, Managed Identity, HTTPS only. Also worklist the cross-checks with the BC side: an outbound BC call's idempotency key the plane must forward, a BC Correlation ID the plane must carry, a parked long-running message the plane must drive the poll for, and Business Event subscriptions the plane must monitor.

A curated `integration` or `security` file enters the worklist when its `keywords` intersect these tokens. Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each worklisted artifact and rule, evaluate the plane against the playbook. Where a curated `integration` or `security` knowledge file states the rule, emit a knowledge-backed finding citing it: `id` equal to the file path, `severity` up to `blocker` only when the file states a platform-level guarantee, otherwise `major`, `confidence` `high` for an unambiguous match. Where no curated file covers the rule (the common case for the Azure-side checks), emit an agent finding within this skill's domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:az-receiver-stages-to-bc`, `agent:az-correlation-header`, `agent:az-subscription-health-check`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` naming the artifact, what the playbook expects, what the artifact does, and the concrete fix. When the underlying impact would otherwise be a blocker (a receiver running BC business logic inline, a missing dead-letter path swallowing poison messages, a stripped correlation id breaking end-to-end tracing), keep the emitted `severity` at `minor` but say so plainly in the `message` and flag that the rule should be promoted to a curated knowledge file before it can gate. Set `suggested-code` when the fix is a mechanical edit to a contiguous artifact span; otherwise set `suggested-code-omission-reason`. Hold every agent candidate to the precision bar in `skills/do.md`: steelman that the plane's choice is deliberate before emitting, and omit when in doubt.

Outcome selection: `completed` when every worklisted artifact was reviewed (including a clean plane with empty `findings`); `not-applicable` when the repository contains no Azure integration artifacts (report this in `outcome-reason`); `no-knowledge` when artifacts exist but no curated knowledge survived and no agent finding was raised; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. Playbook rules with no curated backing are agent findings (`references: []`, `agent:` id mirroring the `az-*` rule, severity capped at `minor`, gating impact stated in the message); findings citing an `integration` or `security` file carry that file path as `id` and primary reference.

```json
{
  "skill": { "id": "azure-integration-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 3, "items-evaluated": 3 }
  },
  "findings": [
    {
      "id": "agent:az-correlation-header",
      "severity": "minor",
      "message": "functions/ShipmentRouter reads the inbound message but does not set the Correlation ID on the outbound Service Bus header, so a trace cannot be joined across BC, the plane, and the WMS. Read the correlation id from the inbound message and set it on the Service Bus message header and every outbound HTTP header, and log it at each step. Promote to a curated rule before it can gate.",
      "location": { "file": "functions/ShipmentRouter/run.csx" },
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "fix spans message construction and logging, not a single contiguous span"
    }
  ],
  "suppressed": []
}
```
