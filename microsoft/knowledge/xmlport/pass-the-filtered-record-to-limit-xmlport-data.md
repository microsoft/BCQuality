---
bc-version: [all]
domain: xmlport
keywords: [xmlport, xmlport-export, xmlport-run, record-parameter, filter, setrange, export-scope]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pass the filtered record to the XMLport call to limit its data

## Description

`Xmlport.Export`, `Xmlport.Import`, and `Xmlport.Run` accept an optional record argument, and the XMLport uses any filters attached to that record. When the argument is omitted, the XMLport is not limited by the caller: for the stream methods, all records in the table are processed. Filters set on a record variable in the calling code have no effect on the XMLport unless that variable is passed in the call.

The failure is silent and the output is plausible. An export meant for one customer group, date range, or document returns every record, which is also a data-exposure problem when the file goes to an external party.

## Best Practice

Set the filters on a record variable and pass that same variable as the record argument of the call. When the scope is fixed by the business purpose of the XMLport rather than by the caller, declare it on the XMLport itself instead, so no call site can forget it.

See sample: [`pass-the-filtered-record-to-limit-xmlport-data.good.al`](pass-the-filtered-record-to-limit-xmlport-data.good.al).

## Anti Pattern

`Customer.SetRange("Salesperson Code", SalespersonCode);` followed by `Xmlport.Export(Xmlport::"Customer Export", OutStr);`. The filter is applied to a variable the XMLport never sees, and the file contains all customers. Reviewer signal: filters set on a record immediately before an XMLport call whose argument list does not include that record.

Do not report an XMLport call without a record argument when no caller-side filter is intended, or when the XMLport restricts its own data.

See sample: [`pass-the-filtered-record-to-limit-xmlport-data.bad.al`](pass-the-filtered-record-to-limit-xmlport-data.bad.al).

## References

[Xmlport.Export method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/xmlport/xmlport-export-method), [Xmlport.Import method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/xmlport/xmlport-import-method), and [Xmlport.Run method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/xmlport/xmlport-run-method).
