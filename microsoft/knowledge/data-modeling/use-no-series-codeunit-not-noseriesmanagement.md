---
bc-version: [22..]
domain: data-modeling
keywords: [no-series, getnextno, ismanual, noseriesmanagement, obsolete-pending, testmanual]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Assign numbers with codeunit `"No. Series"`, not the obsolete `NoSeriesManagement`

## Description

Since 2023 release wave 1 (v22) the number-series API is codeunit **310** `"No. Series"`, called by name in AL. Its methods include `GetNextNo`, `PeekNextNo`, `IsManual`, `TestManual`, and `LookupRelatedNoSeries`. The older codeunit **396** `NoSeriesManagement` and its `InitSeries` / `SelectSeries` / `SetSeries` / `TestManual` methods are marked obsolete-pending: they still compile but raise a deprecation warning and are scheduled for removal, so they must not appear in new code.

LLMs reproduce the legacy `NoSeriesManagement` pattern because it dominates pre-2023 training data. Prefer the new codeunit: it has a cleaner surface and is the only version that survives the deprecation. (The numbers matter — `310` is the current codeunit; `396` is the legacy one being retired.) Verify signatures on learn.microsoft.com or in the `microsoft/BCApps` source before use.

## Best Practice

`OnInsert` assigns the number with `NoSeries.GetNextNo("No. Series")` where `NoSeries` is `Codeunit "No. Series"`. The `No.` field's `OnValidate` guards manual entry by calling `NoSeries.IsManual(...)` (or `TestManual`) before clearing `No. Series`.

See sample: `use-no-series-codeunit-not-noseriesmanagement.good.al`.

## Anti Pattern

`NoSeriesMgt.InitSeries(...)` for assignment and `NoSeriesMgt.TestManual(...)` for the manual check, where `NoSeriesMgt` is `Codeunit NoSeriesManagement`. Both are obsolete-pending and emit compiler warnings.

See sample: `use-no-series-codeunit-not-noseriesmanagement.bad.al`.
