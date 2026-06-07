---
bc-version: [all]
domain: integration
keywords: [polling, framing-record, cursor, lock, stale-lock, incremental-window, overlap]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use a framing record for inbound polling

## Description

When Business Central polls an external paged API on a schedule, two facts about the schedule create problems that a naive poll handler ignores. First, the handler needs durable memory of where it left off, because the Job Queue run that fetched the last window is gone by the time the next one starts. Second, the Job Queue can overlap: a run that takes longer than its recurrence interval is still working when the next run begins, so two runs are live at once. A framing record is the small per-feed table that solves both: it holds the last fetch datetime, a maximum window size, an optional cursor token, and a lock flag with a stale-lock timeout.

Without a framing record a poll fails in one of two ways, both of which get worse the busier the feed is. A handler with no last-fetch memory re-fetches the entire collection every run, so the cost of a poll grows with the total data set rather than with what is new, and resolved messages are restaged and reprocessed. A handler with no lock lets overlapping runs fetch the same window concurrently, so the same records are staged twice and downstream they become duplicate documents. The fix is the same record in both cases: bounded windows fix re-fetching, the lock fixes overlap.

## Best Practice

Keep one framing record per inbound feed and drive every poll through it. At the start of a run, acquire the lock, honouring a stale-lock timeout so a run that crashed without releasing the lock does not wedge the feed forever; if the lock is held and fresh, the run exits and lets the holder finish. Then compute a bounded window from the last fetch datetime up to a capped end (never an open-ended "everything since"), fetch exactly that window, advance the cursor and last fetch datetime, and release the lock. The mechanism that prevents double-staging is the lock plus the advancing watermark: the second overlapping run sees the lock held and backs off, and even sequential runs never overlap their windows because each one starts where the previous one's watermark ended. See `use-a-framing-record-for-inbound-polling.good.al`.

The window cap is a deliberate trade-off: capping the end datetime means a feed that has been quiet for a long time catches up over several runs rather than pulling a huge window in one go, which keeps each run bounded and each lock window short. Pair this with idempotent staging (see `deduplicate-inbound-messages-with-an-idempotency-check.md`) so that even a window boundary that overlaps slightly cannot create duplicates.

## Anti Pattern

A poll handler that fetches the full collection every run, or that has no lock so concurrent Job Queue runs fetch and stage the same records. The detection signal: a polling codeunit whose `HttpClient` call has no last-fetch datetime or cursor feeding the request (a bare "get all"), no cap on the requested window, or no lock acquisition guarding the fetch. The consequence of fetch-all is wasted work that scales with the whole data set and reprocessing of already-resolved messages; the consequence of a missing lock is duplicate staging whenever two runs overlap, which surfaces downstream as duplicate documents. The fix is a per-feed framing record with a watermark, a window cap, and a stale-aware lock. See `use-a-framing-record-for-inbound-polling.bad.al`.

## See also

- `deduplicate-inbound-messages-with-an-idempotency-check.md`
- `stage-every-integration-message.md`
- `split-multi-step-flows-into-staged-job-queue-entries.md`
