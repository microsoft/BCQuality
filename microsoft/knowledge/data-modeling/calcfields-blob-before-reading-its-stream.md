---
bc-version: [all]
domain: data-modeling
keywords: [blob, calcfields, setautocalcfields, createinstream, instream, empty-stream, blob-field]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Calculate a BLOB field before reading its stream

## Description

`Get`, `Find`, `FindSet`, and `Next` do not load the content of `Blob` fields. Until the field is calculated with `CalcFields` (or loaded through `SetAutoCalcFields` before the read), the in-memory BLOB is empty. `CreateInStream` on that field succeeds and returns an empty stream, so code that reads text, JSON, or an image from it gets an empty result and no error. The defect does not surface in tests that fill and read the BLOB in the same record variable.

`Media` and `MediaSet` fields are different types and are not loaded with `CalcFields`; this article covers `Blob` only.

## Best Practice

Call `CalcFields` on the BLOB field after retrieving the record and before `CreateInStream`, or call `SetAutoCalcFields` on the field before a `FindSet` loop that reads the BLOB for every row.

Do not flag code that reads a BLOB it has just written through `CreateOutStream` on the same record variable, a BLOB on a temporary record filled in the same session, or a read preceded by `SetAutoCalcFields` on that field. Writing a BLOB does not require a prior `CalcFields`.

See sample: [`calcfields-blob-before-reading-its-stream.good.al`](calcfields-blob-before-reading-its-stream.good.al).

## Anti Pattern

A record retrieved from the database followed by `<Record>.<BlobField>.CreateInStream(...)` with no `CalcFields` or `SetAutoCalcFields` on that field in between. The reader sees an empty stream and passes empty content on to the parser, export, or HTTP request that consumes it.

See sample: [`calcfields-blob-before-reading-its-stream.bad.al`](calcfields-blob-before-reading-its-stream.bad.al).

## References

[Record.CalcFields method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-calcfields-method) (CalcFields also retrieves BLOBs) and [BigText.Read method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/bigtext/bigtext-read-method) (a BLOB field must be calculated before it is used in AL).
