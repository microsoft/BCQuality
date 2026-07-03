---
kind: action-skill
id: al-performance-review
version: 1
title: AL performance review
description: Reviews AL source changes against performance guidance from BCQuality, including tCOG-specific conventions.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL performance review

Reviews AL source changes against the `performance` knowledge domain in BCQuality and emits a findings report. This custom layer variant keeps the standard BCQuality performance review behavior while allowing tCOG-specific performance knowledge to participate through the same worklist.

## Source

Read the BCQuality knowledge index once and take the entries whose `domain` is `performance` across every enabled layer. Do not open individual knowledge files at this step.

## Relevance

Apply the frontmatter matching rules from READ against the task context:

- `bc-version` from the target app version or orchestrator context.
- `technologies` must include `al`.
- `countries` from the consuming app context.
- `application-area` from the changed objects.

Discard files that explicitly do not match. Retain conditionally applicable files only when consumer configuration allows them; any findings derived from unknown dimensions must cap confidence at `medium` and name the unknown dimensions in the message.

## Worklist

Narrow the relevant files to the subset that applies to the changes under review. Weight heavily toward changed procedures and triggers that perform loops, reads, partial-record optimization, and concurrency-sensitive access patterns.

Key tokens include `SetLoadFields`, `FindSet`, `FindFirst`, `FindLast`, `Get`, `ReadIsolation`, `LockTable`, `ReadCommitted`, `ReadUncommitted`, `repeat`, `until`, `CalcFields`, and `CalcSums`.

A knowledge file enters the worklist when its keywords intersect the extracted tokens or its topic matches the changed object type or code path. After the candidate worklist is known, resolve layer precedence per READ and record any suppressed lower-precedence files.

When no applicable performance knowledge survives filtering and precedence, emit `outcome: "no-knowledge"`. When relevant performance knowledge exists but nothing matches the reviewed changes, emit `outcome: "completed"` with an empty `findings` array.

## Action

For each worklist entry, evaluate the diff against the file's `## Best Practice` and `## Anti Pattern` sections.

- Emit `major` or `blocker` for clear anti-pattern matches, using `blocker` only when the referenced guidance states a platform-level guarantee is violated.
- Emit `minor` when the code contradicts a best practice without being a full anti-pattern.
- Emit `info` when a file is clearly applicable but no concrete violation is detectable.

Set confidence to `high` for unambiguous syntax or identifier matches, `medium` for heuristic matches or unknown frontmatter dimensions, and `low` for advisory applicability-only observations.

The skill may also emit conservative performance-domain agent findings when the diff shows a concrete, material performance defect that no loaded knowledge file covers. Agent findings must use `references: []`, an `id` prefixed with `agent:`, `severity` no higher than `minor`, `confidence` no higher than `medium`, and a self-contained message with a concrete recommendation.

Populate `suggested-code` whenever the fix is small, local, and mechanical. Omit it only when the right replacement depends on unavailable context, multiple defensible choices exist, or the fix spans non-contiguous code.

## Output

Output conforms to the DO findings-report contract in [skills/do.md](skills/do.md).