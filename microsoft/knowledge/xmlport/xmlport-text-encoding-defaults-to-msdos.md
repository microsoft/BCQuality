---
bc-version: [all]
domain: xmlport
keywords: [xmlport, textencoding, msdos, utf8, variabletext, fixedtext, csv, encoding]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A text XMLport uses MS-DOS encoding unless `TextEncoding` is set

## Description

An XMLport whose `Format` is `VariableText` or `FixedText` reads and writes text in the encoding given by its `TextEncoding` property, and the default value is `MSDOS`. Business Central holds text as Unicode internally, so the default converts every exported value to the MS-DOS code page and interprets every imported byte as MS-DOS. A delimited file that contains only ASCII looks correct in testing; the first name with an accented letter or a currency symbol is corrupted for a consumer that expects UTF-8 or Windows encoding, and an incoming UTF-8 file is imported with wrong characters. No diagnostic is raised in either direction.

The property is available only for the two text formats. It does not apply when `Format` is `Xml`.

## Best Practice

Set `TextEncoding` explicitly on every `VariableText` or `FixedText` XMLport to the encoding the other system uses: `UTF8` (written with a byte order mark), `UTF16`, `WINDOWS`, or `MSDOS` when the counterpart really requires it. When one XMLport serves partners with different encodings, set it at run time with `currXMLport.TextEncoding(...)` before the data is processed.

See sample: [`xmlport-text-encoding-defaults-to-msdos.good.al`](xmlport-text-encoding-defaults-to-msdos.good.al).

## Anti Pattern

A CSV or fixed-width XMLport that declares `Format` and separators but no `TextEncoding`, used to exchange names, addresses, or descriptions. Reviewer signal: `Format = VariableText` or `Format = FixedText` with no `TextEncoding` property and no run-time `TextEncoding` call.

Do not report a missing `TextEncoding` on an XMLport with `Format = Xml`, and do not report an explicit `TextEncoding = MSDOS`, which is a stated choice.

See sample: [`xmlport-text-encoding-defaults-to-msdos.bad.al`](xmlport-text-encoding-defaults-to-msdos.bad.al).

## References

[TextEncoding property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-textencoding-property) and [File handling and text encoding](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-file-handling-and-text-encoding).
