---
bc-version: [all]
domain: ui
keywords: [tooltip, teaching-tip, abouttitle, abouttext, onboarding]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Tooltips describe what a thing is; teaching tips guide what the user can do with it

## Description

Business Central exposes two distinct affordances for explaining the UI: ToolTip and the AboutTitle/AboutText teaching tip. They answer different questions and are complementary, not alternatives. ToolTip answers "What is this field/action?" and is expected on every field and action. The teaching tip answers "What can I do with this page or this important element?" and is reserved for the few entry points where an onboarding hint is worth the user's attention. Authors who put teaching-tip content in tooltips make tooltips noisy; authors who put tooltip content in teaching tips make teaching tips useless.

## Best Practice

Write ToolTip as a concise descriptive sentence following the "Specifies …" or imperative voice rules. Reserve AboutTitle/AboutText for the top-level card and list pages where first-time users benefit from discovering the page's purpose and outcome. On list pages, title uses the plural form ("About sales invoices"). On card or document pages, title uses the entity name plus "details" ("About sales invoice details").

## Anti Pattern

A field ToolTip that tells the user "You can create new customers from here and update their payment terms, and the list also shows…" — that is teaching-tip content. Conversely, an AboutText that simply repeats the page Caption tells the user nothing they did not already read in the title bar.
