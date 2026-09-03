---
bc-version: [all]
domain: data-modeling
keywords: [xrec, before-image, onmodify, onrename, oninsert, ondelete, table-trigger, page-driven]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `xRec` is a before-image in `OnRename` and `OnDelete`, but mirrors `Rec` in `OnInsert` and `OnModify` from code

## Description

`xRec` is widely believed to be "the previous record" inside every table trigger, and — in reaction to that — is often dismissed with the folk rule *"`xRec` only works from a page, never from code"*. Both are wrong, and the second is wrong in the place it matters most.

The behaviour is per-trigger. In `OnRename` and `OnDelete`, `xRec` is a genuine before-image regardless of what drove the write. In `OnInsert` and `OnModify`, a **code-driven** write leaves `xRec` mirroring `Rec` — there is no before-image at all — while a **page-driven** write does supply one.

That combination produces a defect that is unusually hard to catch. A comparison such as `if Rec.Status <> xRec.Status then` inside `OnModify` works when a tester clicks through a page, and silently never fires when the same code path runs from a job queue, a batch routine, or an API call. It fails as a no-op, not as an error.

The `OnRename` case is the useful half: because `xRec` there holds the previous primary key even from code, it is the one place a hand-written key fix-up is reliable. Note that in `OnRename` only the key differs between `Rec` and `xRec` — non-key field values are identical on both sides.

See also `validate-table-relation-false-suppresses-rename-propagation.md`, which describes when such a hand-written `OnRename` fix-up is required.

## Best Practice

Use `xRec` for the previous key in `OnRename`, and for the record being removed in `OnDelete`. In `OnModify`, obtain the before-image by re-reading the stored row rather than trusting `xRec`, so the logic behaves identically whether a page, a job queue or an API drove the write.

See sample: `xrec-is-a-before-image-only-in-some-triggers.good.al`.

## Anti Pattern

Comparing `Rec` against `xRec` inside `OnModify` (or `OnInsert`) to detect a change. From code the two are equal, so the branch is dead and whatever it guards never happens.

Detection signal: any read of `xRec` inside `OnModify` or `OnInsert`. Treat "but it works when I test it on the page" as confirmation of the defect rather than a refutation.

See sample: `xrec-is-a-before-image-only-in-some-triggers.bad.al`.
