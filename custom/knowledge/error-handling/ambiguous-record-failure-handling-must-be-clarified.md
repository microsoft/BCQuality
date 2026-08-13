---
bc-version: [all]
domain: error-handling
keywords: [insert, modify, delete, get, rename, boolean-return, clarify-before-building, ambiguous]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Ambiguous record-failure handling must be clarified, not guessed

## Description

`Insert`, `Modify`, `Delete`, `Get`, and `Rename` all return a Boolean
indicating success. There are two legitimate ways to use that: let AL
raise its own runtime error when the return value is ignored and the call
fails, or check the return value explicitly and decide what happens on
failure (`if not Rec.Insert() then ...`). Both are correct in the right
context — an ignored `Get()` failing is often exactly the right behavior
when the record is expected to exist and its absence is a genuine bug;
an ignored `Insert()` failing on a duplicate key might instead be a normal,
recoverable case the caller should handle gracefully.

Because both are legitimate, this is not a pattern an AI assistant should
resolve by guessing. When it is unclear from the surrounding code, the
task description, or the object's existing conventions whether a given
failure should surface as AL's implicit runtime error or be handled
explicitly, ask the developer which behavior is intended before writing
the call — the same way [[clarify-before-building]] applies to any other
underspecified requirement. Silently picking one approach risks either
swallowing a failure the developer needed to see, or crashing a flow the
developer expected to degrade gracefully.

## Best Practice

```al
// Failure is expected and recoverable — handle it explicitly.
if not Customer.Insert() then
    Error('Customer %1 already exists.', Customer."No.");

// Failure would indicate a genuine bug — let it surface as AL's own error.
Customer.Get(CustomerNo);
```

When genuinely unsure which case applies, ask: "Should a failed
Insert/Modify/Delete/Get here be handled as an expected, recoverable
outcome, or is it a bug we want to surface immediately?"

## Anti Pattern

Silently choosing to ignore the return value (or silently choosing to wrap
every call in an `if not ... then` with a generic error message) without
first checking whether the surrounding code, task, or object convention
already signals which behavior is intended.
