---
bc-version: [all]
domain: ui
keywords: [caption, capitalization, title-case, sentence-case, noun-phrase]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Capitalize captions by phrase type: noun phrase is Title Case, sentence phrase is Sentence case

## Description

Business Central UI captions follow a simple capitalization rule that depends on the grammatical shape of the caption, not its location. A caption that is a pure noun phrase — no verb — uses Title Case: each major word capitalized (`Sales Orders`, `Chart of Accounts`, `Payment Terms`). A caption that is an imperative or declarative sentence phrase — contains a verb — uses Sentence case: only the first word and proper nouns capitalized (`Post and print`, `Send email`, `Create flow`). Following the rule makes unrelated captions feel consistent; ignoring it is visibly inconsistent in the user's navigation.

## Best Practice

Decide by parsing the caption as a phrase. "Sales Orders" is a thing; Title Case. "Post and print" tells the user to do something; Sentence case. For captions that are literally a single noun (`Save`, `Close`), treat them as sentence phrases — the imperative verb is implied.

See sample: `caption-capitalization-noun-phrase-vs-sentence-phrase.good.al`.

## Anti Pattern

Writing `Caption = 'Sales orders'` on a list page (noun phrase styled as a sentence) or `Caption = 'Post And Print'` on an action (sentence phrase styled as title case). Both read as typos to a native English reader and inconsistent to a translator.

See sample: `caption-capitalization-noun-phrase-vs-sentence-phrase.bad.al`.
