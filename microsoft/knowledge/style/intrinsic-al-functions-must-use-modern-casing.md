---
bc-version: [all]
domain: style
keywords: [casing, intrinsic-function, built-in-function, message, error, confirm, strsubstno, legacy, c-al, pascalcase]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Intrinsic AL function calls use modern casing, not legacy ALL-CAPS

> Contributions welcome — open a PR to refine or extend this article.

## Description

AL is case-insensitive, so `MESSAGE(...)`, `ERROR(...)`, `CONFIRM(...)`, and `STRSUBSTNO(...)` compile and run identically to `Message(...)`, `Error(...)`, `Confirm(...)`, and `StrSubstNo(...)`. Modern AL — the VS Code tooling's default formatter output, Microsoft's own current samples, and current reference codebases — writes intrinsic/built-in function calls in the casing Microsoft assigns to the function's declared name, typically PascalCase. ALL-CAPS calls are a holdover from classic C/AL and signal code that has not been modernized, even though it compiles and runs correctly. Reserved keywords such as `if`, `begin`, and `for` are a separate, already-tooled concern; intrinsic function names are identifiers, not keywords, so that tooling does not catch ALL-CAPS intrinsic function calls.

## Best Practice

Call intrinsic functions in their modern, PascalCase form.

See sample: `intrinsic-al-functions-must-use-modern-casing.good.al`.

## Anti Pattern

ALL-CAPS intrinsic function calls trip no compiler error, but they are a reliable signal that a code block was copied from old C/AL material or outdated training content rather than written against current AL conventions.

See sample: `intrinsic-al-functions-must-use-modern-casing.bad.al`.
