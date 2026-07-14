---
bc-version: [20..]
domain: privacy
keywords: [getlasterrortext, error, strsubstno, telemetry, customer-data, attachment]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Treat `GetLastErrorText()` as potential customer content

## Description

Parameterless `GetLastErrorText()` can contain customer content such as field values, record keys, and file names. The Boolean overload names its parameter `ExcludeCustomerContent`; passing `true` requests scrubbed text and is not the customer-content scenario covered here. When unsanitized error text is passed as a substitution value to an `Error` whose first argument is a `Label` or `TextConst`, the label supplies the Error method trace telemetry message.

## Best Practice

Use a generic label when the user does not need the underlying detail. If showing unsanitized detail is appropriate, put `%1` in a label and pass parameterless `GetLastErrorText()` as a separate argument. This preserves a useful static telemetry message while keeping the dynamic value out of the telemetry message field.

See sample: `getlasterrortext-customer-content-in-errors.good.al`.

## Anti Pattern

`Error(StrSubstNo(AttachmentFailedErr, GetLastErrorText()))` or `Error(AttachmentPrefixErr + GetLastErrorText())`. Both lose the static first argument and trigger AA0231; neither causes the composed text to be logged verbatim as the Error telemetry message.

See sample: `getlasterrortext-customer-content-in-errors.bad.al`.
