---
bc-version: [all]
domain: error-handling
keywords: [fielderror, testfield, field-validation, onvalidate, error-message, mandatory-field, record-context]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Choose `TestField` For Conditional Checks And `FieldError` For Already-Failed Validation

## Description
`TestField` and `FieldError` look interchangeable but behave differently, and choosing the wrong one produces either dead code or a check that never fires. `TestField` performs the comparison itself and throws only when the field is empty or does not match the supplied value; `FieldError` performs no comparison and always raises an error the moment it is reached. Both attach the field caption and the record's primary-key context to the message automatically, which is why neither should be replaced by a hand-built `Error` call that interpolates the field name as a literal.

## Best Practice
Use `TestField` when the condition is a simple presence-or-equality check on a single field — mandatory-field gates and prerequisite checks at the top of a procedure read clearly and self-document intent. Use `FieldError` inside an `OnValidate` trigger or a validation procedure where surrounding business logic has already determined the value is invalid and you want a specific, custom message. Rely on the built-in field-and-record context both methods add rather than re-stating the field name in the text.

## Anti Pattern
Calling `FieldError` to "test" a field — placing it on a path that is reached unconditionally and expecting it to validate — terminates execution every time because `FieldError` never evaluates a condition. The inverse smell is reaching for `TestField` when the rule needs a tailored message, then bolting a vague generic string onto a check that cannot express the real business reason. A reviewer can spot the first by a `FieldError` that is not guarded by a preceding `if`, and the second by a `TestField` whose intent comment describes a condition more complex than presence or equality.
