---
kind: action-skill
id: al-event-subscriber-auditor
version: 1
title: AL event subscriber audit
description: Audits AL event subscribers for publisher existence, signature match, IsHandled contract, and thin-handler discipline, and emits a findings report.
inputs: [pr-diff, file-path, repository]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL event subscriber audit

Verifies that every `[EventSubscriber]` in a Business Central extension is wired correctly: the targeted publisher still exists, the signature matches the publisher parameter for parameter, the `IsHandled` contract is honoured, and the handler is thin enough to belong in a subscriber. The failure mode is silent: a typo'd publisher name or a `var` mismatch never fires and never errors at compile time on older event shapes. This skill sources from the `style`, `performance`, and `security` domains and cites curated rules where a subscriber concern maps onto one (subscriber parameter naming, guarding subscribers before a database call, integration events that leak secrets); the binding-correctness checks are mostly agent findings within its event-subscriber domain. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `pr-diff`, a `file-path`, or a `repository`. It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `style`, `performance`, or `security` as the citable candidate set across every enabled layer: subscriber parameter names that must match the publisher, guarding an event subscriber before a database call, and an integration event that must not expose secrets each map onto a curated rule and MUST cite it rather than be paraphrased. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. The binding-correctness checks (publisher existence, exact signature match, the `IsHandled` flow, `BindSubscription` for `Manual` instances) are mostly not encoded in the corpus; for those concrete defects, emit an agent finding within this skill's event-subscriber domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the changed objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the procedures decorated with `[EventSubscriber]` and their immediate radius:

- The targeted publisher for each subscriber, resolved from `.alpackages` symbols when the publisher is in a dependency or from the extension's own source when internal. Flag a publisher that does not resolve (typo or removed event), a signature that does not match the publisher parameter for parameter (name, type, var-ness, order), and a missing `var` on a parameter the publisher passes by var.
- The `IsHandled` flow: a subscriber that ignores `var IsHandled: Boolean` on a first-handler-wins event, or sets it true without honouring the contract; a subscriber to `OnBeforeValidateEvent` that sets `IsHandled := true` without replicating the base-app validation.
- `OnRun` subscriptions (almost always a mistake), missing `Element` on a control-event binding, and `EventSubscriberInstance = Manual` subscribers with no `BindSubscription` in the call path.
- Handler thickness: subscriber bodies with more than roughly 25 lines of inline business logic that belong in a delegated codeunit; subscribers that call `Commit`, `Confirm`, or `HttpClient` inside a posting hot path.

A curated `style`, `performance`, or `security` file enters the worklist when its `keywords` intersect these tokens (for example `event-subscriber`, `publisher`, `guard`, `integrationevent`, `secret`). Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each worklisted subscriber, emit findings.

When a defect maps onto a curated file (subscriber parameter names that diverge from the publisher, a subscriber that hits the database with no early guard, an integration event payload that leaks a secret), emit a knowledge-backed finding citing that file: `id` equal to the file path, the file as primary reference, `severity` up to `blocker` only when the file states a platform-level guarantee otherwise `major`, `confidence` `high` for an unambiguous match.

When a concrete binding-correctness defect has no curated rule (a publisher that does not resolve, a `var` mismatch that silently drops mutations, a broken `IsHandled` flow, a `Manual` subscriber nobody binds, a thick handler with inline business logic), emit an agent finding within this skill's event-subscriber domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:subscriber-signature-drift`), `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` describing why the subscriber will not fire or will misbehave at runtime and the concrete fix. Where the impact would normally gate (a signature drift that silently breaks `IsHandled`), keep `severity` at `minor` but say so plainly in the `message` and note the concern should be promoted to a knowledge-backed rule before it can gate. Hold every candidate to the precision bar in `skills/do.md`: steelman that the loose signature or unbound manual instance is intentional and resolved by code outside the diff before emitting, and omit when in doubt. Before emitting any agent candidate, check the worklisted knowledge for a match and upgrade it to a knowledge-backed finding if one exists.

Set `suggested-code` when the fix is mechanical (adding a missing `var` to a parameter, adding an early-exit guard); otherwise set `suggested-code-omission-reason` (for example `requires the publisher's exact signature from the dependency symbols`).

Outcome selection: `completed` when every subscriber was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the task has no event subscribers to audit; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. A populated example:

```json
{
  "skill": { "id": "al-event-subscriber-auditor", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 12, "items-evaluated": 12 }
  },
  "findings": [
    {
      "id": "agent:subscriber-signature-drift",
      "severity": "minor",
      "message": "Posting Subscribers.HandleAfterFinalize binds to Sales-Post.OnAfterFinalizePosting but omits the var prefix on RecRef. The publisher passes RecRef by var, so without var the subscriber receives a copy and any mutation is dropped, breaking the IsHandled flow silently. Change RecRef: RecordRef to var RecRef: RecordRef to match the publisher. Impact would normally be major; emitted as minor because no curated rule backs it. This concern should be promoted to a knowledge-backed rule before it can gate.",
      "location": {
        "file": "src/PostingSubscribers.Codeunit.al",
        "line": 18
      },
      "references": [],
      "confidence": "medium",
      "suggested-code-omission-reason": "requires the publisher's exact parameter list from the base app symbols"
    }
  ],
  "suppressed": []
}
```
