---
bc-version: [all]
domain: performance
keywords: [watermark, incremental-sync, last-sync-at, earliest-sync-at, delta-query, graph-api, polling, out-of-order-arrival]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not advance a sync watermark past an item's original timestamp

> Contributions welcome — open a PR to refine or extend this article.

## Description

Not every "advance the watermark after a successful poll" pattern is a safe optimization. When the field used to build the lower-bound filter reflects an item's *original* timestamp (for example an email's `receivedDateTime`) rather than the event that made it newly visible to the integration (for example being moved into a monitored folder), advancing that lower bound after a successful, low-volume run can permanently exclude items that become relevant later but still carry an old timestamp. A run that retrieves fewer than the max batch size is not proof that nothing older is left to see — it only proves nothing older was visible *yet*. Treat "raise the lower-bound filter after every successful poll" as a correctness change, not a pure performance one, and confirm what event the watermark field actually measures before recommending it.

## Best Practice

Keep the configured start date / earliest-retrieval bound fixed when the source system can present old-timestamped items as newly relevant (moved-in items, restored items, re-categorized items, etc.), and rely on a separate exclusion mechanism — such as a processed-category flag sent as part of the server-side `$filter` — to keep already-handled items from being reprocessed or from consuming the retrieval batch. A distinct "last run at" field can still be recorded for diagnostics/telemetry without being used as the retrieval watermark. Only advance the lower-bound filter when the field driving it is guaranteed to be monotonic with respect to the integration's visibility of the item, e.g. a server-assigned change-sequence number or a delta/skip token, not a mutable business timestamp.

See sample: `keep-sync-watermark-fixed-for-late-arriving-items.good.al`.

## Anti Pattern

Recommending or adding a "restore the watermark update" step that sets `EarliestSyncAt := CurrentDateTime` (or similar) purely because a batch returned fewer than the max page size, without checking whether the underlying timestamp can be moved into scope after the fact. Widening this every-poll advance to a folder-monitoring or moved-item scenario silently drops items whose original timestamp precedes the new lower bound, even though the server-side category/state filter would have safely deduplicated them without shrinking the window.

See sample: `keep-sync-watermark-fixed-for-late-arriving-items.bad.al`.
