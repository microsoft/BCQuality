---
bc-version: [all]
domain: privacy
keywords: [telemetry, session-logmessage, strsubstno, pii, customer-data, employee-code, filename]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not embed customer data in the telemetry message text

## Description

`Session.LogMessage`'s message argument is a plain `Text`. Unlike `Error()`, the platform does not inspect this string field-by-field — whatever is in the text is what telemetry receives. So a call that builds the message via `StrSubstNo` from customer-bearing fields ships those values to telemetry verbatim, regardless of the `DataClassification` argument on the same call. Flagged content includes customer names, email addresses, phone numbers, addresses, employee codes or IDs, attachment filenames, user-provided text that may carry PII, and dumps of `Record` content.

## Best Practice

Keep the telemetry message a static, non-personal string ("Customer record processed", "Error processing uploaded file"). When structured context is genuinely needed, attach it through custom dimensions, where individual values can be reviewed and classified at the dimension level rather than baked into a free-text message.

If a pseudonymous identifier (record `No.`, primary key value) genuinely belongs in the diagnostic, prefer attaching it through a custom dimension and set the call's `DataClassification` to match the data actually shipped — `EndUserPseudonymousIdentifiers` for pseudonymous IDs, `CustomerContent` for content-bearing telemetry. Changing the `DataClassification` alone does **not** make embedding a customer name into the message string acceptable; the data still ships in the message, and downstream consumers still see the literal string.

See sample: [`no-pii-in-telemetry-message-string.good.al`](no-pii-in-telemetry-message-string.good.al).

## Related

- `session-logmessage-requires-dataclassification.md` — every `Session.LogMessage` call must specify `DataClassification`; choose the value to match the actual data shipped, not the value that makes the entry retained the longest.
- `featuretelemetry-customdimensions-no-pii.md` — custom dimensions are the right surface for structured context, but they have their own PII rules.

## Anti Pattern

`Session.LogMessage('0000', StrSubstNo('Processed %1', Customer.Name), ...)` — the customer name is in telemetry the moment the line runs. Detection signal: a `StrSubstNo` whose result is the second argument of `Session.LogMessage`. The same shape with `FileName`, `EmployeeCode`, or any record field is the same problem.

See sample: [`no-pii-in-telemetry-message-string.bad.al`](no-pii-in-telemetry-message-string.bad.al).
