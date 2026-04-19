---
bc-version: [26..28]
domain: performance
keywords: [setloadfields, case, conditional, branch, field-loading]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Load common fields before branching on case

> **Seed article.** Ported from BC Code Intelligence to seed the community corpus. Community contributors are invited to expand or refine.

## Description

When record processing branches on state, different branches typically read different fields. A single `SetLoadFields` at the top listing every field any branch might touch pulls more data than any individual execution path needs — on the hot path, the rest is loaded for nothing. A two-tier approach matches loading to actual usage: load the fields the `case` expression evaluates plus any fields every branch uses, then add a branch-local `SetLoadFields` inside each branch for that branch's extra fields.

## Best Practice

Before the `case`, call `SetLoadFields` with the minimal set — the discriminator field and fields common to every branch. Inside each branch, before the first access to a branch-specific field, add a second `SetLoadFields` covering those fields. The platform honors the in-branch call for the next record operation, so the extra data is fetched only when the branch runs.

See sample: `load-common-fields-before-branching-on-case.good.al`.

## Anti Pattern

A single top-level `SetLoadFields` enumerating every field any branch might read. On records whose state routes them to the fast common branch, the rarely-needed fields are still loaded — the optimization becomes a net-neutral or net-negative change on the hot path.

See sample: `load-common-fields-before-branching-on-case.bad.al`.
