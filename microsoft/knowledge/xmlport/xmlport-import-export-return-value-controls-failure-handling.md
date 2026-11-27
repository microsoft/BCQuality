---
bc-version: [all]
domain: xmlport
keywords: [xmlport, xmlport-import, xmlport-export, return-value, runtime-error, error-handling, instream]
technologies: [al]
countries: [w1]
application-area: [all]
---

# The return value of `Xmlport.Import` and `Xmlport.Export` decides who handles a failure

## Description

`Xmlport.Import` and `Xmlport.Export` have an optional Boolean return value: `true` when the operation succeeded, otherwise `false`. The option changes the failure behavior. When the return value is omitted and the operation does not succeed, a run-time error occurs. When the return value is used, the failure is reported only through that Boolean, and the calling code is responsible for acting on it.

Both forms are correct, for different intentions. The mistakes are in between: reading the return value and then continuing as if the import had succeeded, or treating a call without the return value as unhandled.

## Best Practice

Omit the return value when a failed import or export must stop the process; the platform raises the error. Use the return value only when the caller has a real alternative path, such as recording the failed file and moving to the next one, and make every later step depend on it.

See sample: [`xmlport-import-export-return-value-controls-failure-handling.good.al`](xmlport-import-export-return-value-controls-failure-handling.good.al).

## Anti Pattern

Assigning or testing the return value and then ignoring it: `Imported := Xmlport.Import(...)` followed by code that marks the file as processed regardless, or `if Xmlport.Import(...) then;`. The run-time error is suppressed and nothing replaces it, so a file that was not imported is recorded as done. Reviewer signal: the Boolean result of `Xmlport.Import` or `Xmlport.Export` is captured but does not control the statements that follow.

Do not report a call that omits the return value as a missing error check. Omitting it is how the failure is turned into an error.

See sample: [`xmlport-import-export-return-value-controls-failure-handling.bad.al`](xmlport-import-export-return-value-controls-failure-handling.bad.al).

## References

[Xmlport.Import method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/xmlport/xmlport-import-method) and [Xmlport.Export method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/xmlport/xmlport-export-method).
