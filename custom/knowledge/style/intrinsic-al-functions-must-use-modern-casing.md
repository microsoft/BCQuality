---
bc-version: [all]
domain: style
keywords: [casing, intrinsic-function, built-in-function, message, error, confirm, strsubstno, legacy, c-al, pascalcase]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Intrinsic AL function calls use modern casing, not legacy ALL-CAPS

## Description

AL is case-insensitive, so `MESSAGE(...)`, `ERROR(...)`, `CONFIRM(...)`, and
`STRSUBSTNO(...)` compile and run identically to `Message(...)`, `Error(...)`,
`Confirm(...)`, and `StrSubstNo(...)`. Modern AL — the VS Code tooling's
default formatter output, Microsoft's own current samples, and the BCApps
codebase — writes intrinsic/built-in function calls in the casing Microsoft
assigns to the function's declared name (typically PascalCase). ALL-CAPS
calls are a holdover from classic C/AL (C/SIDE) and signal code that has not
been modernized, even though it compiles and runs correctly.

This is a distinct concern from CodeCop AA0241
([[lowercase-reserved-keywords]]), which governs reserved keywords (`if`,
`begin`, `var`, `for`, ...) and explicitly excludes identifiers and function
calls. Intrinsic function names are identifiers, not keywords, so AA0241
does not catch ALL-CAPS intrinsic function calls — which is exactly why the
pattern survives unflagged from old training material and legacy modules
into new development.

## Best Practice

```al
Message('%1 records updated.', Count);
if not Confirm('Delete %1?', false, CustomerNo) then
    exit;
Error(StrSubstNo('%1 must not be blank.', FieldCaption("No.")));
```

## Anti Pattern

```al
MESSAGE('%1 records updated.', Count);
IF NOT CONFIRM('Delete %1?', FALSE, CustomerNo) THEN
    EXIT;
ERROR(STRSUBSTNO('%1 must not be blank.', FieldCaption("No.")));
```

ALL-CAPS intrinsic function calls (`MESSAGE`, `ERROR`, `CONFIRM`,
`STRSUBSTNO`, `CALCDATE`, `COPYSTR`, and similar) trip no current CodeCop
diagnostic, but they are a reliable signal that a code block was copied from
old C/AL material, a pre-2018 upgrade, or outdated training content rather
than written or reviewed against current AL conventions.
