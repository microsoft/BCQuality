---
bc-version: [all]
domain: error-handling
keywords: [get, record-not-found, runtime-error, return-value, boolean-method, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# An unchecked Record.Get raises an error when the record is missing; it is not silently ignored

## Description

`Record.Get` returns a Boolean, but its behavior when no record is found depends on whether the return value is consumed. When the return value is used — inside `if Rec.Get(...) then`, or assigned to a variable — a missing record yields `false` and execution continues. When `Rec.Get(...)` is called as a bare statement and the return value is not used, the platform raises a runtime "record not found" error if the record does not exist. A bare `Rec.Get(Key)` therefore acts as an assertion that the record exists: it does not swallow or silently ignore a missing record. This mirrors other AL find methods, where an unconsumed return value lets the platform enforce the not-found error.

## Best Practice

Do not claim that a `Record.Get` whose return value is unused silently ignores a missing record or hides an error. Treat a bare `Rec.Get(...)` statement as an intentional existence assertion that already throws when the record is absent. Recommend an explicit existence check only when the surrounding logic must continue gracefully rather than error out.

## Anti Pattern

Flagging a bare `Rec.Get(Key)` statement as a defect because "the return value is ignored, so a missing record is swallowed", or recommending it be wrapped in `if Rec.Get(...) then ... else Error(...)` to "handle the not-found case" — the unchecked call already raises an error when the record is missing.

## See also

- `ignored-tryfunction-return-disables-try-semantics.md` — a different case where ignoring a Boolean return value changes behavior.
