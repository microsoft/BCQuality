---
bc-version: [24..]
domain: upgrade
keywords: [no-series, noseriesmanagement, codeunit-310, getnextno, peeknextno, testmanual, arerelated, no-series-batch, business-foundation, obsolete-codeunit]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Migrate No. Series Calls From NoSeriesManagement To The BC24 No. Series Module

> Contributions welcome — open a PR to refine or extend this article.

## Description
In BC24 (2024 Wave 1) Microsoft moved number generation into the Business Foundation `No. Series` codeunit (310) and obsoleted the legacy `NoSeriesManagement` codeunit (396). Code that still declares `Codeunit NoSeriesManagement` or calls its methods compiles only against the temporary obsolete shim and will break once Microsoft removes it. The new API is not a drop-in rename: the facade exposes a small, specific set of real methods, parameter shapes changed, and the old single method that both previewed and consumed a number was split into two. Getting the mapping wrong silently consumes numbers when you only meant to preview, leaving gaps in the sequence.

## Best Practice
Replace the `NoSeriesManagement` variable with `Codeunit "No. Series"` and map each call deliberately using the facade's actual methods — `GetNextNo`, `PeekNextNo`, `GetLastNoUsed`, `TestManual`, `IsManual`, and `AreRelated`. Use `GetNextNo(SeriesCode, RefDate)` only when you intend to consume and advance the series for a committed document, and `PeekNextNo(SeriesCode, RefDate)` for any display, validation, or preview-posting path where you must not consume. Replace `InitSeries` with a guarded `if "No." = '' then "No." := NoSeries.GetNextNo(...)`. Map `SelectSeries` to `LookupRelatedNoSeries`, relationship checks the old code did by hand to `AreRelated`, and both `TestManual` and `ManualNoAllowed` to `TestManual` (which now raises its own error). For multi-document allocation use `Codeunit "No. Series - Batch"` and persist its state once with `SaveState` instead of committing per iteration. Treat the migration as an opportunity to add preview-posting support, since `PeekNextNo` now makes that trivial.

## Anti Pattern
Mechanically swapping the codeunit reference while keeping the old boolean call shape. The legacy `GetNextNo(Series, Date, false)` meant "peek" and `GetNextNo(Series, Date, true)` meant "consume"; the new `GetNextNo` always consumes and takes no boolean. Equally common is inventing validation helpers such as `IsValidNo`, `VerifySeriesExists`, `IsValidForDate`, or `TryGetNextNo` — these names are not on the `No. Series` or `No. Series - Batch` codeunits and will not compile, a frequent LLM hallucination for this migration. A reviewer can detect the defect by the residual third boolean argument, by any lingering `NoSeriesMgt`/`NoSeriesManagement` identifier, by a fabricated method name, or by an `OnBeforeGetNextNo`/`OnAfterGetNextNo` subscriber — those events were removed without replacement, so that logic must be rewritten as inline pre/post procedures, not re-subscribed. A subtler signal is `GetNextNo` used merely to display a preview, which silently advances the series and creates number gaps; that should be `PeekNextNo`.
