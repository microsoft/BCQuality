---
bc-version: [all]
domain: style
keywords: [optioncaption, option, member-count, aa0221, aa0223, aa0224]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Option fields need `OptionCaption`, and its element count must match `OptionMembers` (CodeCop AA0221/AA0223/AA0224)

## Description

CodeCop AA0221 requires an `OptionCaption` on every option-type field that is not sourced from a table column (table-sourced option fields inherit the captions of the underlying field). AA0223 and AA0224 add two integrity checks: the number of comma-separated entries in `OptionCaption` must equal the number of entries in `OptionMembers`, and each caption must align by position with its member. The position alignment is what the platform uses to translate option values — the `OptionMembers` list never changes per locale, the `OptionCaption` list does. A mismatch in count or order produces silent corruption: the option `Released` shows the caption that belongs to `Pending`, and the bug is locale-dependent.

## Best Practice

`OptionMembers = Open,Released,Pending;` and `OptionCaption = 'Open,Released,Pending';` — same count, same order. When adding a new member, update both lines in the same commit.

See sample: [`optioncaption-required-and-matches-membercount.good.al`](optioncaption-required-and-matches-membercount.good.al).

## Anti Pattern

`OptionMembers = Open,Released,Pending;` with no `OptionCaption` at all (the user sees the raw English members and translation is impossible), or `OptionMembers = Low,Medium,High,Critical;` paired with `OptionCaption = 'Low,Medium,High';` — count mismatch, `Critical` displays as blank or carries the wrong caption depending on platform version.

See sample: [`optioncaption-required-and-matches-membercount.bad.al`](optioncaption-required-and-matches-membercount.bad.al).
