---
bc-version: [all]
domain: ui
keywords: [caption, capitalization, sentence-case, title-case, action, noun-phrase, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Sentence-phrase captions use sentence case, not title case

## Description

Business Central caption capitalization depends on whether the caption reads as a **noun phrase** or a **sentence/verb phrase**. Following the Microsoft writing-style guideline, a caption that reads as an imperative sentence — most action captions, such as `'Show source document'`, `'Post and print'`, or `'Copy from last inspection'` — uses **sentence case**: only the first word and any proper nouns are capitalized. Title case (`'Show Source Document'`) is the older convention and is not required for these captions.

Noun-phrase captions (object names, field labels such as `'Source Document No.'`) follow their own capitalization; that is a separate case and is not what this article covers. Reviewers sometimes see a lower-cased word in an action caption (`'Show source document'`) and flag it as inconsistent title case, but a sentence-phrase action caption is correct as written.

## Best Practice

For an action `Caption` that reads as a sentence or verb phrase, capitalize only the first word and proper nouns (sentence case). Do not require every significant word to be capitalized. Before flagging a caption as "should be title case", confirm it is a noun phrase; leave imperative/sentence-phrase action captions in sentence case.

See sample: [`caption-capitalization-noun-phrase-vs-sentence-phrase.good.al`](caption-capitalization-noun-phrase-vs-sentence-phrase.good.al).

## Anti Pattern

Reporting a sentence-case action caption such as `'Show source document'` as a style defect and recommending title case (`'Show Source Document'`), or calling it inconsistent with BC conventions. Sentence case is the current guideline for sentence-phrase captions.
