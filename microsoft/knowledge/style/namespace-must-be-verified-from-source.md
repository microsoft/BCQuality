---
bc-version: [all]
domain: style
keywords: [namespace, verification, source-of-truth, using-statement]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Verify a namespace from the object's own source file, never by inference

> Contributions welcome — open a PR to refine or extend this article.

## Description

Since Business Central 2024 release wave 1, Microsoft's own objects are organized under a deep `Microsoft.*` namespace tree that has been renamed and restructured repeatedly. Guessing a namespace from an object's name, from an older codebase, or from general familiarity produces a `using` statement that can look plausible, compile in isolation, and still resolve to the wrong object or fail in the AL Language Server that VS Code actually uses to report errors. The only reliable source for an object's namespace is line one of that object's own source file.

## Best Practice

Locate the object's source file, read its `namespace` declaration on line one, and copy that exact value into the consuming file's `using` statement.

See sample: `namespace-must-be-verified-from-source.good.al`.

## Anti Pattern

Writing a `using` statement from memory, from an incomplete path, or from a plausible-looking guess. It can compile in one build environment while still failing to resolve in VS Code, because the two use different namespace resolution.

See sample: `namespace-must-be-verified-from-source.bad.al`.
