---
kind: action-skill
id: al-query-review
version: 1
title: AL Query review
description: Reviews AL Query objects and Query instance usage against BCQuality guidance.
inputs: [pr-diff, file-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL Query review

Reviews AL source changes against the `query` knowledge domain in BCQuality. This is a leaf action skill composed by `al-code-review`.

## Source

Read `knowledge-index.json` once and take entries whose `domain` is `query` across enabled layers. Open an article body only after it enters the Worklist. If the index is unavailable, discover `*/knowledge/query/*.md` by path.

## Relevance

Apply READ's frontmatter matching rules against the task context. Use the target version from `app.json` when available and `[al]` for technologies. Retain conditionally applicable files only when configured; cap resulting confidence at `medium` and name every unknown dimension in the finding message.

Return `not-applicable` when the input contains no Query object declaration and no Query variable method call.

## Worklist

Match relevant entries against changed `query` objects, variables typed as `Query`, and the tokens `QueryType`, `dataitem`, `column`, `DataItemLink`, `SqlJoinType`, `SetFilter`, `SetRange`, `Open`, `Read`, `Close`, and `Clear`.

The following targeted checks cover every current `query` article:

- `SetFilter` or `SetRange` occurs after `Open()` without a new `Open()` before the next `Read()` — `set-query-filters-before-open`.
- An already-open query is opened again as if that advanced the cursor, or a query variable is reused for an independent operation without `Clear` even though old filters must not carry over — `reopening-query-resets-cursor-but-keeps-filters`.

Resolve layer conflicts per READ. When no query knowledge exists, emit `no-knowledge`; when knowledge exists but no article matches the changed Query usage, emit `completed` with no findings.

## Action

Evaluate every worklist article against the diff's Query call order and surrounding control flow.

- Emit `major` for an unambiguous Anti Pattern that can close the dataset, restart processing, or retain an unintended filter.
- Emit `minor` when code contradicts a Best Practice but the resulting behavior depends on unseen control flow.
- Do not emit applicability-only information. A Query article produces a finding only when the changed code violates its normative guidance.

Set confidence to `high` for a locally visible call sequence and `medium` when aliases, helper calls, or missing context obscure the sequence. Domain-scoped agent findings follow DO's precision bar and remain capped at `minor`/`medium`.

Provide `suggested-code` only when moving a filter before `Open()` or adding `Clear` is a complete, local, unambiguous replacement. Otherwise set `suggested-code-omission-reason`.

Outcome selection follows DO: `completed`, `no-knowledge`, `not-applicable`, `partial`, or `failed`.

## Output

Output conforms to the DO findings-report contract. Every finding this skill emits MUST set `findings[].domain` to `"Query"`.
