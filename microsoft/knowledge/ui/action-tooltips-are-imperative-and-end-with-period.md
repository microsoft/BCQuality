---
bc-version: [all]
domain: ui
keywords: [tooltip, action, imperative, voice, period]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Action tooltips are imperative, verb-first sentences ending with a period

## Description

Action tooltips describe what the user will cause by invoking the action. The house style is an imperative verb-first sentence — `Post the current sales invoice and finalize the transaction.` — not a declarative one ("This will post …") and not a fragment ("Post invoice"). The imperative voice matches how the user reads the action bar: each tooltip completes the sentence "If I click this, the system will …" in the same grammatical form. Shortcut-key hints, when present, belong at the end of the tooltip and are retained verbatim.

## Best Practice

Start the tooltip with the verb. Use Sentence case, end with a period, stay within the ~250-character budget. Keep one sentence unless the action genuinely needs two; avoid editorializing ("Easily post …") or narrating ("This action posts …"). Preserve any existing shortcut annotation.

See sample: `action-tooltips-are-imperative-and-end-with-period.good.al`.

## Anti Pattern

`ToolTip = 'This will post the invoice'` — declarative rather than imperative, no period. `ToolTip = 'Post'` — one-word fragment that duplicates the Caption and says nothing new. Both fail the scan-the-action-bar comprehension test.

See sample: `action-tooltips-are-imperative-and-end-with-period.bad.al`.
