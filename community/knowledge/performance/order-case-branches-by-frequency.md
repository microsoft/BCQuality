---
bc-version: [all]
domain: performance
keywords: [case, branch, frequency, control-flow, hot-path]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Order case branches by frequency

> **Seed article.** Ported from BC Code Intelligence to seed the community corpus. Community contributors are invited to expand or refine.

## Description

The AL `case` statement evaluates branches in the order they appear. When the distribution of the discriminator is heavily skewed — one or two values handle the vast majority of records, and the rest handle edge cases — the average cost of the statement is dominated by how many branches precede the common one. For evenly distributed discriminators the order does not matter; for skewed distributions it changes the hot-path cost of every call site.

## Best Practice

Where the runtime frequency of values is known or measurable, list the common branches first. An `else` arm that handles unexpected values belongs last. When the common branch is also the simplest to evaluate, the placement compounds: the hot path is both short and cheap, and the uncommon branches are never touched on typical records.

See sample: `order-case-branches-by-frequency.good.al`.

## Anti Pattern

Ordering branches alphabetically, by enum declaration order, or by "logical grouping" when the runtime distribution is heavily skewed. Every common record pays the cost of evaluating every uncommon branch first; on a posting routine processing thousands of rows the overhead is measurable.

See sample: `order-case-branches-by-frequency.bad.al`.
