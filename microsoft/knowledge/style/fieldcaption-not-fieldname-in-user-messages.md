---
bc-version: [all]
domain: style
keywords: [fieldcaption, fieldname, tablecaption, tablename, translation, message, error]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use FieldCaption/TableCaption (not FieldName/TableName) in user-facing text

## Description

`FieldName` and `TableName` return the developer-facing identifier of a field or table — a fixed English string used in metadata and in code. `FieldCaption` and `TableCaption` return the translated, user-facing label declared by the field's or table's `Caption` property. When the value is embedded in a `Message`, `Error`, `Confirm`, or any other string shown to a user, the caption is the correct source. Otherwise the user sees the English internal name regardless of locale, and any caption change must be re-applied at every call site instead of being picked up from the single point of definition.

## Best Practice

Reach for `FieldCaption("Location Code")` and `TableCaption()` whenever the value flows into a UI primitive. The same rule applies to format parameters: `Error(SomeErr, FieldCaption("Status"), TableCaption(), "Status")` rather than `Error(SomeErr, FieldName("Status"), TableName(), "Status")`. The captions follow the user's language; the names do not.

See sample: [`fieldcaption-not-fieldname-in-user-messages.good.al`](fieldcaption-not-fieldname-in-user-messages.good.al).

## Anti Pattern

`Message('Updated %1', TableName())` or `Confirm(UpdateLocationQst, true, FieldName("Location Code"))`. The user sees the English internal name in every locale, and any future rename of the caption fails to reach the message.

See sample: [`fieldcaption-not-fieldname-in-user-messages.bad.al`](fieldcaption-not-fieldname-in-user-messages.bad.al).
