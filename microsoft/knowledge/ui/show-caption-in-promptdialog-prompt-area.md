---
bc-version: [all]
domain: ui
keywords: [show-caption, promptdialog, copilot, prompt, accessibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# ShowCaption in a PromptDialog prompt area

## Description

On `PageType = PromptDialog` pages, input fields inside `area(Prompt)` are labeled by the dialog's heading — the page `Caption`. Setting `ShowCaption = false` on such an input field is the standard pattern and should not be flagged, provided the page has a `Caption`.

Fields in the `area(Content)` section of the same PromptDialog page are **not** labeled by the dialog heading and follow the normal `ShowCaption` rules.

## Best Practice

In a PromptDialog, give the page a meaningful `Caption` (the dialog heading) and let prompt-area input fields hide their own captions. Treat content-area fields like any other editable field — keep their captions.

See sample: [`show-caption-in-promptdialog-prompt-area.good.al`](show-caption-in-promptdialog-prompt-area.good.al).
