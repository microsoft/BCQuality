---
kind: action-skill
id: ai-test-driven-development
version: 1
title: AI test-driven development
description: TDD for Copilot features and custom agents covering Evaluation suites, JSONL/YAML datasets, AITest codeunits, agent turn loops, intervention validation, and credit tracking.
inputs: [repository, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AI test-driven development

Drives test-driven development for Business Central Copilot features and custom agents using the Evaluation suite (the data-driven tool where datasets describe inputs and expected outputs and the test codeunit drives the loop). It covers two flows: prompt-based AI tests for PromptDialog features (JSONL or YAML datasets) and multi-turn agent accuracy tests with intervention validation (YAML only). This is a generator-style skill: it generates AITest codeunits, dataset scaffolds, and suite XML as findings whose `suggested-code` carries the artifact, and it also reviews an existing AI test setup for misconfiguration. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `repository` (the Copilot or agent extension and its test app) and a `file-path` (the capability, PromptDialog, or agent under test, or an existing AI test codeunit or dataset to review). It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `testing` as the citable candidate set across every enabled layer: AITest-codeunit attribute rules, isolation rules (`TestType = AITest`, `RequiredTestIsolation = Disabled` for agent tests), suite-setup discipline, intervention-contract rules, and credit-tracking guidance back the findings here. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. Generated artifacts and configuration observations with no curated backing are agent findings within this skill's domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the repository `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown` (the suite XML may enable multilingual evaluation, so countries can matter).
- `application-area`: the application areas of the Copilot or agent feature, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the AI test work the task requires:

- The flow: prompt-based AI test (PromptDialog plus an Azure OpenAI call, JSONL or YAML dataset) or agent accuracy test (multi-turn, YAML only).
- The AITest codeunit: `Subtype = Test`, `TestType = AITest`, `TestPermissions = Disabled`, and for agent tests `RequiredTestIsolation = Disabled` (essential, because agent tasks run in a different session and span transactions).
- The turn loop for agent tests: the `repeat ... until` delegating to `Library - Agent` (`RunTurnAndWait`, `FinalizeTurn`), with validators returning `false` and a populated `ErrorReason` rather than calling `Error()`.
- The dataset: `test_setup` and `expected_data` keys for AI tests; `turns:` with `query`/`expected_data` for agent tests; the `intervention_request` sub-key the framework reads automatically (both directions: a declared intervention must pause with matching type and suggestions, an undeclared one must not pause); `$DateFormula-<...>$` placeholders, always quoted.
- The suite XML: `TestRunnerId="130451"` (Isolation-Disabled runner, required for agent tests), `TestType="Agent"` versus `"AITest"`, `<Language>` children, and the install-time dataset load.
- Suite-setup discipline: `AITTestContext.IsSuiteSetupDone()` is sticky; re-running setup needs the Reset Suite Setup action.
- Credit and permission constraints: Evaluation runs consume Copilot credits (tracked per suite, per line, per entry; limited at environment and company level); users need the `AI TEST TOOLKIT` permission set.

A curated `testing` file enters the worklist when its `keywords` intersect these tokens. Read its full body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

When generating, emit one finding per generated artifact (the AITest codeunit, the dataset, the suite XML, the install codeunit), each carrying the artifact in `suggested-code` with a `message` stating what was generated and how to wire it. When reviewing an existing setup, emit a finding per defect: a missing `RequiredTestIsolation = Disabled` on an agent test, a wrong `TestRunnerId`, a validator calling `Error()` instead of returning `ErrorReason`, an unquoted date placeholder, an intervention contract the dataset does not exercise in both directions, or a sticky suite-setup that silently ignores edited setup YAML. Where a curated `testing` file states the rule, emit a knowledge-backed finding citing it: `id` equal to the file path, `severity` up to `major` (`blocker` only when the file states a platform-level guarantee, for example an isolation rule whose violation makes the agent runner unusable), `confidence` `high` for an unambiguous match. Where no curated file applies, emit an agent finding within this skill's domain: `references: []`, `id` slug prefixed `agent:` (for example `agent:generated-aitest-codeunit`, `agent:missing-disabled-isolation`, `agent:unquoted-date-placeholder`), `confidence` capped at `medium`, `severity` capped at `minor`, self-contained `message`. Put generated AL, YAML, or XML in `suggested-code`; for a mechanical fix to an existing file (adding the isolation attribute, quoting a placeholder) also set `suggested-code`. Where the fix is not local (restructuring a turn loop), set `suggested-code-omission-reason`. Hold every agent finding to the precision bar in `skills/do.md`.

Outcome selection: `completed` when the requested generation or review finished (including a clean review with empty `findings`); `not-applicable` when the repository has no Copilot capability, PromptDialog, or custom agent to test; `no-knowledge` when no curated knowledge survived and no agent finding was raised; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. Generated artifacts and configuration findings with no curated backing are agent findings (`references: []`, `agent:` id, severity capped at `minor`); findings citing a `testing` file carry that file path as `id` and primary reference.

```json
{
  "skill": { "id": "ai-test-driven-development", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 1, "minor": 1, "info": 0 },
    "coverage": { "worklist-size": 3, "items-evaluated": 3 }
  },
  "findings": [
    {
      "id": "agent:missing-disabled-isolation",
      "severity": "minor",
      "message": "Agent accuracy codeunit 50202 sets TestType = AITest but not RequiredTestIsolation = Disabled. Impact is major: agent tasks run in a different session and span transactions, so the runner cannot enforce isolation and the suite fails to start. Add the attribute. Promote to a curated rule so it can gate.",
      "location": { "file": "test/MyAgentAccuracyTest.Codeunit.al", "line": 4 },
      "references": [],
      "confidence": "medium",
      "suggested-code": "    RequiredTestIsolation = Disabled;"
    },
    {
      "id": "agent:generated-agent-dataset",
      "severity": "info",
      "message": "Generated a YAML agent dataset with a turns chain and an intervention_request the FinalizeTurn contract enforces in both directions. Date values use quoted $DateFormula placeholders so the dataset does not drift against WorkDate. Ship it under the test app .resources/ folder and load it in an Install codeunit.",
      "location": { "file": "test/.resources/datasets/MY-DATASET.yaml" },
      "references": [],
      "confidence": "medium",
      "suggested-code": "name: MY-DATASET\nsuite_setup: MY-AGENT\ntests:\n  - turns:\n      - query:\n          message: \"Release all open sales orders for next week\"\n        expected_data:\n          orders_released: 2"
    }
  ],
  "suppressed": []
}
```
