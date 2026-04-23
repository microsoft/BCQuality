---
bc-version: [all]
domain: ui
keywords: [tooltip, field, specifies, voice, period]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Field tooltips start with "Specifies" and end with a period

## Description

Field tooltips describe what a value means, and the Business Central house style for them is a declarative sentence that starts with "Specifies" and ends with a period. The convention is not cosmetic: it yields a consistent voice across thousands of fields so a user scanning several tooltips in quick succession can compare them without re-parsing each opening clause. Alternative phrasings ("Shows …", "The …") are accepted when they describe the field clearly, but "Specifies …" is the default and the easiest to translate consistently.

## Best Practice

Write field tooltips as `Specifies <what the field represents>.` — a single sentence, Sentence case, terminating period. Keep under the ~250-character tooltip budget (see `respect-ui-text-character-limits`). When the field's meaning is genuinely not a "specifies" sentence, use "Shows …" or a clearly descriptive alternative; avoid bare fragments.

See sample: `field-tooltips-start-with-specifies-and-end-with-period.good.al`.

## Anti Pattern

`ToolTip = 'The name of the customer'` — missing "Specifies" opener, missing period. `ToolTip = 'Customer name'` — a fragment rather than a sentence. Both sit inconsistently next to adjacent "Specifies …" tooltips on the same page.

See sample: `field-tooltips-start-with-specifies-and-end-with-period.bad.al`.
