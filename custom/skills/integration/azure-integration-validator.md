---
kind: action-skill
id: azure-integration-validator
version: 1
title: Azure integration validator
description: Validates the Azure plane for a BC integration, checking receivers, Service Bus, Durable Functions, retry/dead-letter, idempotency, correlation, secrets, and subscription health.
inputs: [repository, file-path, pr-diff]
outputs: [findings-report]
bc-version: [all]
technologies: [bicep, csharp]
countries: [w1]
application-area: [all]
---

# Azure integration validator

Validates the Azure component build that sits between Business Central and external systems: webhook receivers (Functions, Logic Apps, APIM), Service Bus topics and queues, Durable Functions, and the Bicep, ARM, or Terraform that provisions them. The single question is whether, when BC stages a message or fires an event, the plane delivers it reliably, traceably, and exactly once. It reads the artifacts and reports where the plane fails its half of the contract; the developer chooses which fixes to apply. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `repository`, a `file-path` (a narrow scope such as the storefront webhook Function), or a `pr-diff` (a change touching Azure integration artifacts). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `integration` or `security` as the citable candidate set across every enabled layer: receiver-staging, idempotency, retry-and-dead-letter, correlation, observability, secret-handling, and managed-identity rules can back a finding. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. The integration-plane house rules (the `az-*` checks below) are largely Azure-side and rarely map onto a BC-focused curated file, so most findings here are agent findings within this skill's domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version the plane integrates with, or `unknown` if unavailable.
- `technologies`: `[bicep, csharp]` (the infrastructure-as-code and Function handler code the checks actually touch).
- `countries`: the consuming solution's declared countries, or `unknown`.
- `application-area`: the application areas of the integration, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the Azure artifacts present and the integration-plane checks each draws. If the repository contains no Azure integration artifacts, do not invent findings: report that plainly. Read Bicep (`*.bicep`), ARM (`azuredeploy.json`, `*.template.json`), Terraform (`*.tf`), Logic App and workflow definitions (`workflow.json`, `*.logicapp.json`), Function app config (`host.json`, `function.json`, retry and binding config) and handler source, and APIM policy XML (inbound, backend, outbound, on-error). Build the worklist against these checks:

- Receiver stages to BC and does not run BC business logic or block on BC completion inline.
- Receiver acknowledges fast (a 2xx, or 202 for async); no long synchronous work inside it.
- Idempotency key forwarded: outbound calls carry the BC Message ID as `Idempotency-Key`; inbound receivers forward the source system id; the plane does not strip it.
- Idempotent consumer: receivers and queue consumers dedup on the event id or business key before a second side effect.
- Retry in the plane: explicit on the Logic App action, the Function `host.json`, or the Service Bus delivery count, not a silent default or a hand-written loop.
- Dead-letter configured: Service Bus queues and subscriptions enable dead-lettering with a defined max delivery count.
- Transient versus permanent: retries 408, 429, 5xx, and timeouts; routes 4xx and invalid data to DLQ or alert. Retrying a 4xx forever is the most severe failure.
- Durable retry, not a tight loop: long retries scheduled by a Durable Function or a Logic App timer carrying the same idempotency key.
- Correlation header: the Correlation ID is read from the inbound message, set on the Service Bus header and every outbound HTTP header, and logged at each step.
- Observability wired: Functions and Logic Apps have Application Insights or equivalent.
- 202 status poll: a long-running external process is parked and polled or callback-driven, then written back to the same Integration Message; no synchronous connection held open for hours.
- Subscription health check: where the plane relies on BC Business Event subscriptions, a scheduled job lists them and alerts on drift, since they expire silently.
- Secrets in Key Vault: credentials and connection strings come from Key Vault via Managed Identity, not inline. A literal secret is the most severe failure.
- Managed Identity: plane-to-BC and plane-to-resource auth uses Managed Identity where supported.
- HTTPS only: receivers and Function apps enforce HTTPS with a current TLS minimum; the Function is not public where APIM is the intended front door.

A curated `integration` or `security` file enters the worklist when its `keywords` intersect these tokens. Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each worklisted artifact, evaluate it against the checks. Where a curated `integration` or `security` knowledge file states the rule (for example a secret-handling or idempotency rule), emit a knowledge-backed finding citing it: `id` equal to the file path, `severity` up to `blocker` only when the file states a platform-level guarantee, otherwise `major`, `confidence` `high` for an unambiguous match. Where no curated file covers the integration-plane check (the common case), emit an agent finding within this skill's domain: `references: []`, `id` slug prefixed `agent:` mirroring the house rule (for example `agent:az-secrets-in-keyvault`, `agent:az-dead-letter-configured`, `agent:az-classify-transient-vs-permanent`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` naming the artifact and line, what is wrong, and the concrete fix. When the underlying impact would otherwise be a blocker (a literal secret checked into source, a 4xx retried forever, a receiver running BC logic inline, a stripped idempotency key), keep the emitted `severity` at `minor` but say so plainly in the `message` and flag that the check should be promoted to a curated rule before it can gate. Set `suggested-code` when the fix is a mechanical edit to a contiguous artifact span (a Key Vault reference replacing a literal, a `maxDeliveryCount` plus dead-letter setting on a subscription); otherwise set `suggested-code-omission-reason`. Hold every agent candidate to the precision bar in `skills/do.md`: steelman that the configuration is deliberate (the secret may be a non-sensitive placeholder, the retry default may be intended) before emitting, and omit when in doubt.

Outcome selection: `completed` when every worklisted artifact was evaluated (including a clean plane with empty `findings`); `not-applicable` when the repository contains no Azure integration artifacts (report this in `outcome-reason`); `no-knowledge` when artifacts exist but no curated knowledge survived and no agent finding was raised; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. Integration-plane checks with no curated backing are agent findings (`references: []`, `agent:` id mirroring the `az-*` rule, severity capped at `minor`, gating impact stated in the message); findings citing an `integration` or `security` file carry that file path as `id` and primary reference.

```json
{
  "skill": { "id": "azure-integration-validator", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 2, "info": 0 },
    "coverage": { "worklist-size": 4, "items-evaluated": 4 }
  },
  "findings": [
    {
      "id": "agent:az-secrets-in-keyvault",
      "severity": "minor",
      "message": "infra/main.bicep line 142: the WMS API key is a literal string in the Function app settings, checked into source and visible in deployment history. Impact is a blocker: move the key to Key Vault and reference it via @Microsoft.KeyVault(...), granting the Function access through its Managed Identity. Promote to a curated rule before it can gate.",
      "location": { "file": "infra/main.bicep", "line": 142 },
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "fix requires creating a Key Vault secret and a reference whose name is not derivable from the diff"
    },
    {
      "id": "agent:az-dead-letter-configured",
      "severity": "minor",
      "message": "infra/servicebus.bicep line 60: the shipments subscription sets neither deadLetteringOnMessageExpiration nor maxDeliveryCount, so poison messages loop or vanish. Enable dead-lettering with a defined max delivery count and add a consumer or alert on the DLQ.",
      "location": { "file": "infra/servicebus.bicep", "line": 60 },
      "references": [],
      "confidence": "medium"
    }
  ],
  "suppressed": []
}
```
