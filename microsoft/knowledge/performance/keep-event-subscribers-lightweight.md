---
bc-version: [26..28]
domain: performance
keywords: [event, subscriber, publisher, extension]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep event subscribers lightweight

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

Event subscribers run synchronously on the publisher's thread. If a subscriber does heavy work — a database query, a web service call, a layout render — every caller of the publisher pays that cost. Subscribers on hot events (OnAfterValidate on common fields, OnBeforeInsert on ledger-entry-like tables) can multiply a small per-call cost into a system-wide regression.

## Best Practice

Keep subscribers small: guard early with inexpensive checks, defer heavy work to a task queue or a background session, and cache results across invocations when the data is stable.

## Anti Pattern

Calling an external web service, running a report, or iterating a large table from inside an event subscriber on a hot publisher makes every operation on that publisher as slow as the heaviest subscriber.

See sample: `samples/performance/keep-event-subscribers-lightweight/bad.al`.

