---
bc-version: [all]
domain: ui
keywords: [ampersand, caption, accelerator, translation, voice]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Write "and" in UI captions; keep the ampersand only as an accelerator-key prefix

## Description

AL Caption strings use the ampersand character in two distinct ways. Inside a caption, `&` is the accelerator-key prefix — `Caption = '&Post'` underlines the P and makes Alt+P activate the action. Outside that role, `&` is sometimes used as a shortening for the word "and" (`Post & Send`). The first usage is platform-defined and must be preserved. The second is a style choice that the Business Central voice guidelines reject: `Post and send` reads naturally in all supported locales and translates cleanly, while `Post & Send` conveys nothing extra and adds a character that localizers have to re-evaluate.

## Best Practice

Use the word "and" in caption text. Keep `&` only when it is immediately followed by a letter chosen as the keyboard accelerator. If both meanings apply, write them explicitly: `Post and &send` uses `s` as the accelerator and spells the conjunction out.

See sample: `use-and-not-ampersand-in-ui-captions.good.al`.

## Anti Pattern

`Caption = 'Post & Send'` as the full caption — the ampersand is meant as "and" but the AL parser cannot tell, and the result is inconsistent with every other "X and Y" caption in the product.

See sample: `use-and-not-ampersand-in-ui-captions.bad.al`.
