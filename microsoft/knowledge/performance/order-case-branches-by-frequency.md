---
bc-version: [all]
domain: performance
keywords: [case, branch, frequency, control-flow, hot-path]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Order case branches by frequency

> Contributions welcome — open a PR to refine or extend this article.

## Description

AL documentation does not guarantee that a `case` statement uses a linear comparison strategy, so branch frequency alone is not proof of a performance issue. Reordering is justified only when profiling on the target runtime shows that a large, heavily skewed `case` is a material hot path. It is not a default review finding.

## Best Practice

After profiling confirms the comparison path matters and the runtime frequency is known, list common branches first without changing the set of handled values, fallback behavior, or branch bodies.

See sample: `order-case-branches-by-frequency.good.al`.

## Anti Pattern

Reordering branches based on assumed frequency without profiling, or changing an `else` arm or handled value while making the optimization. The good and bad forms must differ only in branch order.

See sample: `order-case-branches-by-frequency.bad.al`.
