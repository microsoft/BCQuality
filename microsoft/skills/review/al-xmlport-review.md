---
kind: action-skill
id: al-xmlport-review
version: 1
title: AL XMLport review
description: Reviews AL XMLport objects and XMLport calls against BCQuality guidance.
inputs: [pr-diff, file-path, folder-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL XMLport review

Reviews AL source changes against the `xmlport` knowledge domain in BCQuality. This is a leaf action skill composed by `al-code-review`.

## Source

Use READ's **Bounded retrieval for review skills** workflow with `-Domain xmlport`. Consume every catalog page across enabled layers before applying this leaf's Relevance and Worklist; preserve each exact catalog path and open complete bodies only for exact paths selected by the Worklist. If the helper or prepared index is unavailable or invalid, use READ's explicit path-discovery and bounded native-read fallback.

## Relevance

Apply READ's frontmatter matching rules against the task context. Use the target version from `app.json` when available and `[al]` for technologies. Retain conditionally applicable files only when configured; cap resulting confidence at `medium` and name every unknown dimension in the finding message.

Return `not-applicable` when the input contains no XMLport object declaration and no call on the `Xmlport` data type.

## Worklist

Match relevant entries against changed `xmlport` objects, variables typed as `XmlPort`, and the tokens `Direction`, `Format`, `VariableText`, `FixedText`, `TextEncoding`, `FieldSeparator`, `FieldDelimiter`, `RecordSeparator`, `UseRequestPage`, `Xmlport.Run`, `Xmlport.Import`, `Xmlport.Export`, and `currXMLport`.

The following targeted checks cover every current `xmlport` article:

- An XMLport declares `Format = VariableText` or `Format = FixedText` with no `TextEncoding` property and no run-time `TextEncoding` call — `xmlport-text-encoding-defaults-to-msdos`. Do not match `Format = Xml` or an explicit `TextEncoding = MSDOS`.
- `Xmlport.Run` is called without its `Import` argument, or with one that contradicts the target, and the target XMLport's `Direction` is visible as `Export` or `Import` — `xmlport-run-import-argument-must-match-direction`. Require the target's `Direction` from its definition; do not infer it from the object name.
- The Boolean result of `Xmlport.Import` or `Xmlport.Export` is assigned or tested but does not control the statements that follow — `xmlport-import-export-return-value-controls-failure-handling`. Do not match a call that omits the return value.
- Filters are set on a record variable before an `Xmlport.Export`, `Xmlport.Import`, or `Xmlport.Run` call whose arguments do not include that record — `pass-the-filtered-record-to-limit-xmlport-data`. Do not match a call without a record argument when no caller-side filter is visible.

Resolve layer conflicts per READ. When no XMLport knowledge exists, emit `no-knowledge`; when knowledge exists but no article matches the changed XMLport usage, emit `completed` with no findings.

## Action

Evaluate every worklist article against the XMLport definition and the calls that run it.

- Emit `major` for an unambiguous Anti Pattern that fails at run time or corrupts exchanged data.
- Emit `minor` when code contradicts a Best Practice but the resulting behavior depends on context the input does not show, such as the encoding the other system expects.
- Do not emit applicability-only information. An XMLport article produces a finding only when the changed code violates its normative guidance.

Set confidence to `high` when the property or call and the target definition are both locally visible, and `medium` when the target XMLport or the counterpart's requirements are not in scope. Domain-scoped agent findings follow DO's precision bar and remain capped at `minor`/`medium`.

Provide `suggested-code` only when adding the missing `Import` argument is a complete, local, unambiguous replacement. Do not suggest a `TextEncoding` value unless the input states the encoding the counterpart requires; otherwise set `suggested-code-omission-reason`.

Outcome selection follows DO: `completed`, `no-knowledge`, `not-applicable`, `partial`, or `failed`.

## Output

Output conforms to the DO findings-report contract. Every finding this skill emits MUST set `findings[].domain` to `"XMLport"`.
