---
bc-version: [all]
domain: style
keywords: [identifiers, naming, english, captions, translation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Write AL Identifiers in English Only

> Contributions welcome — open a PR to refine or extend this article.

## Description

All AL identifiers — variables, procedures, parameters, fields, object names, enum values, and label identifiers — must be written in English, regardless of the developer's native language. Translations are handled separately through captions, tooltips, and XLIFF files, never by writing Danish, German, or other non-English identifiers directly into AL source code. This is not a stylistic preference: the public `microsoft/BCApps` codebase, maintained by engineers of many nationalities across hundreds of thousands of lines of AL, uses exclusively English identifiers, with all localization handled via caption properties and XLIFF rather than by changing identifier names. On any multi-contributor codebase, non-English identifiers make the code unreadable to contributors who don't share that language.

## Best Practice

Write every identifier in English, and translate developer intent rather than transliterating it — when a requirement is described in another language, the resulting variable, procedure, and field names should still read as English. Captions and tooltips may carry target-language text in the source file, with locale translations managed through XLIFF.

See sample: `al-identifiers-english.good.al`.

## Anti Pattern

Using native-language identifiers such as a Danish variable or procedure name in AL source code, relying on the fact that the code still compiles and runs correctly. This makes the code unreadable to non-native-language contributors and mixes localization concerns into source that should stay language-neutral.

See sample: `al-identifiers-english.bad.al`.
