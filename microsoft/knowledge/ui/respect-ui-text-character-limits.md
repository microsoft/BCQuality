---
bc-version: [all]
domain: ui
keywords: [caption, tooltip, character-limit, truncation, localization]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Respect Business Central's UI text character limits to avoid truncation

## Description

Business Central UI surfaces have practical character limits before the platform truncates or the translator's localization overflows the available space. Authoring captions and tooltips close to the English limit almost guarantees truncation in languages whose translations are longer (German, French, Spanish average 20–40% longer than English). The limits are not hard compiler errors — they are product-quality thresholds that agents should flag at author time so the string reaches localization with room to grow.

## Best Practice

Author within these approximate limits (English): action and field captions ~40 chars; field-group, menu-item, page, and dialog titles ~40 chars; button captions ~20 chars; action and field tooltips ~250 chars; dialog text and error messages ~250 chars; notifications ~100 chars; checklist ShortTitleChecklist 34, LongerTitleCard 53, CardDescription 180. Leave headroom for longer translations; at 40/40 in English, German is likely to truncate.

## Anti Pattern

`action(RecalculateAndReapplyAllOutstandingCustomerDiscounts) { Caption = 'Recalculate and reapply all outstanding customer discounts'; }` — 58 characters in English, essentially guaranteed to truncate once translated. The fix is to shorten the English caption (`Recalculate customer discounts`, 30 chars) and move the full sentence into the tooltip where the budget is larger.
