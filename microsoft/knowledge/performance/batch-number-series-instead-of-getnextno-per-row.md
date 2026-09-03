---
bc-version: [22..]
domain: performance
keywords: [no-series, getnextno, no-series-batch, savestate, numbersequence, lock]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Batch number-series calls instead of GetNextNo per insert

> Contributions welcome — open a PR to refine or extend this article.

## Description

`Codeunit "No. Series".GetNextNo` on a **gapless (Normal)** series updates and locks the number-series line on every call. A tight `Insert` loop that asks for a number per row serializes every concurrent writer on that series — the classic SaaS posting bottleneck. Training data still copies the per-row C/AL `NoSeriesManagement` shape. Series configured with **Allow Gaps** instead obtain numbers through `NumberSequence` and do not hold the series-line lock between calls, so they are not affected by this pattern. Codeunit `"No. Series - Batch"` issues gapless numbers in memory and writes the series line once via `SaveState`.

## Best Practice

Inside a multi-row insert, call `"No. Series - Batch".GetNextNo` per row and `SaveState` once after the loop when the series must remain gapless. Use `NumberSequence.Next` when holes are allowed. Do not replace a single `OnInsert` `GetNextNo` for one master record; that path is not the hotspot.

See sample: `batch-number-series-instead-of-getnextno-per-row.good.al`.

## Anti Pattern

`NoSeries.GetNextNo(...)` inside `repeat ... Insert ... until Next() = 0` where the series is **gapless** (Allow Gaps = false). Each iteration takes the series-line lock. The signal is `"No. Series"` (not `"No. Series - Batch"`) in a loop that inserts more than one row; do not flag the same pattern when the series has Allow Gaps enabled, as the `NumberSequence` path already avoids the lock.

See sample: `batch-number-series-instead-of-getnextno-per-row.bad.al`.
