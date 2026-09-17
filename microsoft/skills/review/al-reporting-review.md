---
kind: action-skill
id: al-reporting-review
version: 1
title: AL reporting review
description: Reviews AL Report and ReportExtension code against BCQuality reporting guidance.
inputs: [pr-diff, file-path, folder-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL reporting review

Reviews AL source changes against the `reporting` knowledge domain in BCQuality. This is a leaf action skill composed by `al-code-review`.

## Source

Use READ's **Bounded retrieval for review skills** workflow with `-Domain reporting`. Consume every catalog page across enabled layers before applying this leaf's Relevance and Worklist; preserve each exact catalog path and open complete bodies only for exact paths selected by the Worklist. If the helper or prepared index is unavailable or invalid, use READ's explicit path-discovery and bounded native-read fallback.

## Relevance

Apply READ's frontmatter matching rules against the task context. Use the target version from `app.json` when available and `[al]` for technologies. Retain conditionally applicable files only when configured; cap resulting confidence at `medium` and name every unknown dimension in the finding message.

Return `not-applicable` when the input contains no Report or ReportExtension declaration and no Report variable or method call.

## Worklist

Match relevant entries against changed `report` and `reportextension` objects, variables typed as `Report`, and the tokens `CurrReport`, `Skip`, `Break`, `Quit`, `Run`, `RunModal`, `RunRequestPage`, `Execute`, `Print`, `SaveAs`, `DownloadFromStream`, `Data Compression`, `SetTableView`, `DataItemTableView`, `OnPreReport`, `OnPostReport`, `OnPreDataItem`, `OnAfterGetRecord`, and report-extension dataset triggers.

Apply this targeted check even when token overlap would rank the article below the worklist cutoff:

- The same Report variable has two logically independent `RunModal()` executions without `Clear` before the second configuration — `clear-report-variable-before-independent-runmodal`.
- `CurrReport.Break()` is used inside an explicit loop while reachable statements after the loop are expected to finish the current trigger — `currreport-break-ends-the-current-trigger`.
- `CurrReport.Quit()` follows database writes or the report relies on `OnPostReport` finalization — `currreport-quit-rolls-back-and-skips-onpostreport`.
- `CurrReport.Skip()` is followed by reachable code in the same trigger, or later record triggers contain work that is unsafe for skipped records — `currreport-skip-does-not-stop-trigger-code`.
- A loop reachable from one Web client action calls `Report.Run`, `Report.RunModal`, or `DownloadFromStream` more than once instead of producing one archive download — `report-output-in-a-loop-needs-one-client-download`. Do not select this article when the context is non-Web or the loop is provably single-iteration.
- A ReportExtension before-trigger establishes a filter or value that visible base-trigger code subsequently replaces — `reportextension-dataitem-trigger-order-is-explicit`. Do not select this article from a before-trigger alone.
- A ReportExtension `OnPreReport` prepares state consumed by the base `OnPreReport`, or its `OnPostReport` prepares state already consumed by the base `OnPostReport` — `reportextension-report-triggers-run-after-base-triggers`. Require visible base behavior or equivalent established evidence.
- A report's `DataItemTableView` and a caller's `SetTableView` apply mutually exclusive filters to the same field — `settableview-cannot-broaden-dataitemtableview`. Require both views or equivalent direct evidence; `SetTableView` alone is not a finding.
- The value returned by `Report.RunRequestPage()` reaches `Report.Execute`, `Report.Print`, or `Report.SaveAs` without an empty-string cancellation check — `stop-when-runrequestpage-returns-empty-parameters`.

Resolve layer conflicts per READ. When no reporting knowledge exists, emit `no-knowledge`; when knowledge exists but no article matches the changed report code, emit `completed` with no findings.

## Action

Evaluate every worklist article against the diff's report control flow and surrounding triggers.

- Emit `major` for an unambiguous Anti Pattern that causes incorrect output, persisted side effects, or lost work.
- Emit `minor` when code contradicts a Best Practice but the effect depends on unseen report or caller context.
- Do not emit applicability-only information. A reporting article produces a finding only when changed code violates its normative guidance.

Set confidence to `high` for locally visible control flow and `medium` when base-report behavior, callers, or missing context affect the conclusion. Domain-scoped agent findings follow DO's precision bar and remain capped at `minor`/`medium`.

Provide `suggested-code` only when the replacement is complete, local, and unambiguous. Otherwise set `suggested-code-omission-reason`.

Outcome selection follows DO: `completed`, `no-knowledge`, `not-applicable`, `partial`, or `failed`.

## Output

Output conforms to the DO findings-report contract. Every finding this skill emits MUST set `findings[].domain` to `"Reporting"`.