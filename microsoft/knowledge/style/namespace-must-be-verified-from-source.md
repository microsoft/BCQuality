---
bc-version: [all]
domain: style
keywords: [namespace, verification, source-of-truth, using-statement]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Resolve a namespace from the referenced object's source or symbols, never by guessing

> Contributions welcome — open a PR to refine or extend this article.

## Description

Since Business Central 2024 release wave 1, Microsoft's own objects are organized under a deep `Microsoft.*` namespace tree that has been renamed and restructured repeatedly. When adding a `using` directive for an existing AL object (table, codeunit, page, enum, interface, etc.), guessing its namespace from the object's name, from an older codebase, or from general familiarity produces a statement that can look plausible and still resolve to the wrong object, or fail to resolve at all, once checked against the object's actual current namespace. The reliable sources are the object's own source file (its `namespace` declaration) or, for a dependency without accessible source, its AL symbol package — not the object's name or a remembered convention.

## Best Practice

When referencing an existing AL object, resolve its namespace from that object's actual source file or symbol definition — never infer or invent one from its name, functional area, or naming convention.

See sample: `namespace-must-be-verified-from-source.good.al`.

## Anti Pattern

Writing a `using` statement from memory, from an incomplete path, or from a plausible-looking guess. It can appear correct while actually resolving to the wrong object, or fail to resolve, once checked against stale or mismatched symbols, a different build configuration, or the object's actual current source — not because the compiler and the AL Language Server apply different namespace-resolution rules; they don't.

See sample: `namespace-must-be-verified-from-source.bad.al`.
