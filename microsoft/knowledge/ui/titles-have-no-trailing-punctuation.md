---
bc-version: [all]
domain: ui
keywords: [title, caption, page, dialog, punctuation, ellipsis]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Titles carry no trailing punctuation and no trailing ellipsis

## Description

Page titles, section titles, FastTab titles, and dialog titles in Business Central are labels, not sentences — they have no trailing period, question mark, or exclamation. Trailing ellipsis ("…" or "...") on a title is specifically a long-standing Windows convention for action buttons that open a dialog, and AL handles that via the action's runtime behaviour rather than the caption text. Adding the ellipsis literally into a page caption or action caption is wrong in both directions: the platform also displays its own ellipsis when appropriate, and the static three dots corrupt translations that adjust punctuation for the locale.

## Best Practice

End titles with the last word of the title. Sentence case per the capitalization rule for the phrase type (see `caption-capitalization-noun-phrase-vs-sentence-phrase`). If a dialog needs "…" behaviour, rely on the platform; do not type the characters into the caption string.

## Anti Pattern

`Caption = 'Setup wizard...'`, `Caption = 'Sales orders.'`, `page Caption = 'Customer list:'` — all three decorate the title with terminal punctuation that is noise to the reader and a translation headache.
