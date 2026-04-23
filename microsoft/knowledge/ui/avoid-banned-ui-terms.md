---
bc-version: [all]
domain: ui
keywords: [terminology, disabled, invalid, whitelist, blacklist, voice]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Avoid banned UI terms; prefer the inclusive and direct replacements

## Description

Business Central's UI voice guidelines exclude four terms that carry connotations the product does not want to push onto users: "Disabled" (clinical/negative), "Invalid" (pejorative), "Whitelist" and "Blacklist" (terms with racial associations the industry has moved away from). The replacements read naturally, match the product's warm-and-direct voice, and align with Microsoft's cross-product terminology. The concern applies to user-visible text — captions, tooltips, error messages, notifications — not to variable names or code comments.

## Best Practice

Replace "Disabled" with "Turned off" or "Not available". Replace "Invalid" with "Not valid" or "Incorrect". Replace "Whitelist" with "Allow list". Replace "Blacklist" with "Block list". Apply the substitution in all UI text surfaces: Caption, ToolTip, AboutTitle, AboutText, Label values, Message/Confirm/Error strings.

## Anti Pattern

`ErrorLbl: Label 'Invalid input.'`, `Caption = 'Disabled Users'`, `ToolTip = 'Specifies the blacklist of blocked senders.'` — all three terms in places the user will read. The fix is literal substitution with the approved alternative.
