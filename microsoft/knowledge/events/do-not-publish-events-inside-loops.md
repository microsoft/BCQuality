---
bc-version: [all]
domain: events
keywords: [performance, loops, event-publishing, batch, onbefore, onafter, subscriber-cost]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not publish events inside loops

## Description

Raising an event on every iteration of a loop multiplies the cost of every subscriber by the number of records. A subscriber doing even a little work per call can turn a fast batch into a timeout when the loop runs over thousands of rows, and the publisher has no control over how expensive a subscriber is. Unless a genuine per-row hook is required, publish once before the loop and once after it, passing enough context — filters, a key, or a buffer — for subscribers to act on the whole set at once. Generated code tends to drop an event inside the `repeat … until` without weighing the per-iteration multiplier.

## Best Practice

Raise `OnBeforeProcessLines` before the loop and `OnAfterProcessLines` after it, outside the `repeat … until`, so each subscriber runs once per batch rather than once per row. Give those events the record or filters they need to operate on the whole set.

See sample: `do-not-publish-events-inside-loops.good.al`.

## Anti Pattern

An event raised inside the loop body, fired once per iteration, so subscriber cost scales with the row count and large batches slow down or time out. Detection: an `OnBefore…`/`OnAfter…`/`On…` raise located between `repeat` and `until` in a record loop.

See sample: `do-not-publish-events-inside-loops.bad.al`.
