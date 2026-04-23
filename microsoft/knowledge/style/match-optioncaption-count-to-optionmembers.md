---
bc-version: [all]
domain: style
keywords: [option, optionmembers, optioncaption, aa0221, aa0223, aa0224]
technologies: [al]
countries: [w1]
application-area: [all]
---

# OptionCaption must list exactly as many captions as OptionMembers

## Description

Option fields declare their values in `OptionMembers` and their localized display text in `OptionCaption`. The two lists are positionally paired — the Nth caption maps to the Nth member — and a mismatch either in count or in intent produces a field that renders blank for some values or shows the wrong caption for others. CodeCop rules AA0221, AA0223, and AA0224 flag the variants of this mistake: missing OptionCaption entirely on non-table-sourced option fields, OptionCaption with a different element count than OptionMembers, and OptionCaption content that does not correspond to the member names.

## Best Practice

Whenever OptionMembers is declared, declare OptionCaption with the same number of entries in the same order. For table-sourced option fields, the base table's caption applies and a per-page override is usually unnecessary — the rule applies to option fields defined in pages, reports, and non-table sources.

See sample: `match-optioncaption-count-to-optionmembers.good.al`.

## Anti Pattern

`OptionMembers = Low,Medium,High,Critical;` paired with `OptionCaption = 'Low,Medium,High';` — three captions for four members. `Critical` rows render with the empty caption, or fall back to the member name, depending on where the option is displayed.

See sample: `match-optioncaption-count-to-optionmembers.bad.al`.
