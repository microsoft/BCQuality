---
bc-version: [all]
domain: style
keywords: [error, strsubstno, label, parameters, concatenation, aa0231]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pass parameters directly to `Error()`, do not wrap with `StrSubstNo`

## Description

`Error()` accepts a format string and a variable number of arguments — `Error(SomeLabelErr, Arg1, Arg2)`. The platform performs the substitution itself, which is the path the translation pipeline understands. Wrapping the same call as `Error(StrSubstNo(SomeLabelErr, Arg1, Arg2))` hides the placeholders from the platform and removes the format-string identity from the call-site, so analyzers cannot match the call to its label and translators lose the link between the formatted message and its template. The corresponding anti-pattern for hardcoded strings — `Error('Customer ' + CustomerNo + ' not found')` — is even worse: it builds an untranslatable, unanalyzable string at runtime.

## Best Practice

Declare a `Label` with the `Err` suffix and the appropriate `Comment` for placeholders, then call `Error(YourErr, arg1, arg2)`. The same rule applies to `Message`, `Confirm`, and other UI primitives: format string in, parameters as separate arguments, no `StrSubstNo` wrapper at the call site, no string concatenation. An `Error('')` (empty message) is acceptable when the calling code expects another layer to emit the actual diagnostic.

See sample: [`error-passes-parameters-directly-not-strsubstno.good.al`](error-passes-parameters-directly-not-strsubstno.good.al).

## Anti Pattern

`Error(StrSubstNo(CustomerNotFoundErr, CustomerNo))` and `Error(CustomerNotFoundErr + ': ' + CustomerNo)` both defeat the translation and analysis machinery. Reviewers should treat `StrSubstNo` appearing as an argument to `Error`, `Message`, `Confirm`, or `StrMenu` as an unconditional signal to rewrite.

See sample: [`error-passes-parameters-directly-not-strsubstno.bad.al`](error-passes-parameters-directly-not-strsubstno.bad.al).
