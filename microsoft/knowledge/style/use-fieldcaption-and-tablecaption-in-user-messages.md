---
bc-version: [all]
domain: style
keywords: [fieldcaption, tablecaption, fieldname, tablename, localization, user-message]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use FieldCaption and TableCaption in user messages, not FieldName and TableName

## Description

`FieldName` and `TableName` return the object's internal identifier in English — the name the developer typed into the declaration. `FieldCaption` and `TableCaption` return the translated caption for the current user's language. In user-facing messages, errors, confirmations, and notifications, the two pairs diverge the moment the user is running a non-English locale: `FieldName("Location Code")` reads `Location Code` in every language, while `FieldCaption("Location Code")` reads the translated equivalent. Using the wrong one leaks the English identifier into a localized UI and defeats the product's translation work.

## Best Practice

In any string the user will read, use `FieldCaption(<field>)` and `TableCaption`. Reserve `FieldName` and `TableName` for diagnostic and telemetry contexts where the stable English identifier is preferable. The same rule applies to `XmlPort`, `Query`, and other objects with a caption/name pair.

See sample: `use-fieldcaption-and-tablecaption-in-user-messages.good.al`.

## Anti Pattern

`Confirm(UpdateLocationQst, true, FieldName("Location Code"))`, `Message('Updated %1', TableName())` — both surface English identifiers to a user whose entire UI is in a different language.

See sample: `use-fieldcaption-and-tablecaption-in-user-messages.bad.al`.
