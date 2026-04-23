---
bc-version: [all]
domain: performance
keywords: [recordref, fieldref, dynamic, reflection]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer direct record access over RecordRef where possible

> Contributions welcome — open a PR to refine or extend this article.

## Description

RecordRef and FieldRef are the platform's reflection API: they work across tables the compiler does not know at authoring time. That flexibility costs per-operation overhead — every field access goes through a lookup — and loses compile-time type checking. For operations where the table is known, a strongly-typed Record variable is simpler and faster.

## Best Practice

Use Record variables for code paths that target a known table. Reach for RecordRef and FieldRef only when the table is genuinely dynamic (generic export/import, field-agnostic utilities, cross-table integrations).

See sample: `prefer-direct-record-over-recordref.good.al`.

## Anti Pattern

Using RecordRef as a habit, even when the target table is hardcoded two lines earlier, costs performance and hides intent from reviewers.

See sample: `prefer-direct-record-over-recordref.bad.al`.

