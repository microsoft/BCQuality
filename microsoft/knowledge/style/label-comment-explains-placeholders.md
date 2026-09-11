---
bc-version: [all]
domain: style
keywords: [label, comment, placeholder, strsubstno, translation, aa0470]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Document each Label placeholder with the Comment parameter

## Description

`Label` and `TextConst` strings that contain placeholders (`%1`, `%2`, …) need a `Comment` parameter that names what each placeholder is. Translators do not see the call site, so without the Comment they cannot disambiguate `'Customer %1 not found in %2.'` — is `%2` a location code, a posting date, a company name? The pattern is `Comment = '%1 = <description>, %2 = <description>'`. The Comment is not required when the placeholder meaning is obvious from the surrounding text — `'Customer %1'` is unambiguously a Customer No. — but for any non-trivial label the Comment is a hard requirement.

## Best Practice

Write the Comment in the form `'%1 = Customer No., %2 = Sales Header No.'` — one entry per placeholder, matched by ordinal, named in the vocabulary of the BC domain. When the label is reused across multiple call sites, the Comment names the canonical meaning all call sites must conform to.

See sample: [`label-comment-explains-placeholders.good.al`](label-comment-explains-placeholders.good.al).

## Anti Pattern

A label with two or more placeholders and no Comment, leaving the translator to guess. Equally bad is a Comment that only restates the placeholders (`'%1 and %2 are values'`) without naming what they are. Both fail in translation: the localized string ends up grammatically or semantically wrong, and the bug surfaces only in a non-English tenant.

See sample: [`label-comment-explains-placeholders.bad.al`](label-comment-explains-placeholders.bad.al).
