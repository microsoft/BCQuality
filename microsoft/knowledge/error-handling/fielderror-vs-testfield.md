---
bc-version: [all]
domain: error-handling
keywords: [fielderror, testfield, field-validation, onvalidate, error-message, mandatory-field, record-context, onaction, enabled-property]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Choose `TestField` For Conditional Checks And `FieldError` For Already-Failed Validation

## Description
`TestField` and `FieldError` look interchangeable but behave differently, and choosing the wrong one produces either dead code or a check that never fires. `TestField` performs the comparison itself and throws only when the field is empty or does not match the supplied value; `FieldError` performs no comparison and always raises an error the moment it is reached. Both attach the field caption and the record's primary-key context to the message automatically, which is why neither should be replaced by a hand-built `Error` call that interpolates the field name as a literal.

## Best Practice
Use `TestField` when the condition is a simple presence-or-equality check on a single field — mandatory-field gates and prerequisite checks at the top of a procedure read clearly and self-document intent. Use `FieldError` inside an `OnValidate` trigger or a validation procedure where surrounding business logic has already determined the value is invalid and you want a specific, custom message. Rely on the built-in field-and-record context both methods add rather than re-stating the field name in the text.

A page action's `OnAction` trigger is a different case: a page action is only invocable through its own UI control, so when the action's `Enabled` property is already bound to the same condition the trigger would otherwise `TestField`, the control cannot be clicked while the field is blank and the field can never reach the trigger empty. Adding a `TestField` there is redundant defensive code, not a missing check — flag it only when the trigger can run through a path `Enabled` does not cover (a shared procedure, an API, or a condition broader than what gates the action).

See sample: `fielderror-vs-testfield.good.al`.

## Anti Pattern
Calling `FieldError` to "test" a field — placing it on a path that is reached unconditionally and expecting it to validate — terminates execution every time because `FieldError` never evaluates a condition. The inverse smell is reaching for `TestField` when the rule needs a tailored message, then bolting a vague generic string onto a check that cannot express the real business reason. A reviewer can spot the first by a `FieldError` that is not guarded by a preceding `if`, and the second by a `TestField` whose intent comment describes a condition more complex than presence or equality.

See sample: `fielderror-vs-testfield.bad.al`.
