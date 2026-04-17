---
bc-version: [26..28]
domain: performance
keywords: [strsubstno, string, concatenation, format]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use StrSubstNo for message formatting

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

StrSubstNo formats values into a placeholder template in a single call. Manual concatenation with `+` produces a chain of intermediate strings, each allocated and discarded, and mixes formatting rules inconsistently across locales. The performance difference per call is small; repeated inside a tight loop it is noticeable.

## Best Practice

Declare the template as a Label (so it can be localized) and format with StrSubstNo. Pass values in the order the placeholders expect; StrSubstNo handles locale-sensitive conversions consistently.

See sample: `use-strsubstno-for-message-formatting.good.al`.

## Anti Pattern

Building a user-facing string by concatenating record field values with string literals ignores locale rules and allocates more than necessary.

See sample: `use-strsubstno-for-message-formatting.bad.al`.

