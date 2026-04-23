---
bc-version: [all]
domain: ui
keywords: [tour-tip, abouttext, teaching-tip, imperative, onboarding]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Tour tips describe outcomes, not instructions — never tell the user to perform an action during the tour

## Description

A tour is a guided sequence of teaching tips that runs over the page while the user is passively watching. The tour framework does not expose the page's actions during the tip — so an `AboutText` that tells the user `Enter the customer name here.` or `Now post the invoice.` asks the user to do something that is not possible in the moment. The result is a confusing first-run experience. Tour content should describe what the element represents and what the user will be able to do with it after the tour completes, in descriptive rather than imperative voice.

## Best Practice

Write tour AboutTitle as a short noun-phrase label for the element ("Who you are selling to", "When all is set, you post"). Write AboutText as one or two sentences that describe the outcome or meaning, not steps. Keep the tour itself short — one to four tips total — and let the regular ToolTip carry the per-element detail.

## Anti Pattern

`AboutText = 'Enter the customer name here.'` on a tour tip — the action is not active. `AboutText = 'Now post the invoice.'` during a tour — the user cannot, and would not want to mid-tour. Both teach nothing and confuse the reader.
