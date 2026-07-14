---
bc-version: [all]
domain: error-handling
keywords: [fielderror, testfield, error-message, field-caption, lowercase-convention, record-context, validation]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Rely On FieldError's Auto-Generated Context And Pass Only A Lowercase Predicate

## Description
`Rec.FieldError(FieldNo)` does not just print the text you give it. Business Central automatically prepends the field caption, appends the current field value (when non-blank), and suffixes the table name and primary-key values for record identification. The optional second argument is only the middle predicate of that sentence — e.g. `"must be unique"`, not a whole self-contained message. Misunderstanding this leads to messages that duplicate the caption and value or read as broken grammar, because the framework's surrounding text is built to join a lowercase fragment.

## Best Practice
For a plain required-field check, prefer `TestField`, which tests the condition and raises the error in one call. When the condition is non-trivial and has already been evaluated, call `FieldError(FieldNo)` with no message to get the localized default (`must have a value`, `is not valid`, etc.), or pass a short lowercase predicate such as `FieldError(FieldNo, 'must be a positive number')`. Start the custom text with a lowercase letter so it reads as one sentence with the auto-inserted caption, and use a field-number reference (or the field token) rather than a hard-coded field name so captions and translations stay correct. Let the framework supply the caption, value, table, and key context for you.

## Anti Pattern
Re-testing a condition you already evaluated, or passing a fully formed sentence like `'The Amount field must be positive.'` to `FieldError`. The result reads as `Amount The Amount field must be positive. in Gen. Journal Line ...` — capital letter mid-sentence, caption and value repeated, and a stray trailing clause. Reviewer signals: a `FieldError` argument that names the field, restates the current value, starts with a capital letter, or ends with a period. Each is a sign the author treated `FieldError` like `Error` instead of as a predicate slotted into framework-generated context.