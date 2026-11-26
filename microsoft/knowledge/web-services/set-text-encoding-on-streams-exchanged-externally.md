---
bc-version: [all]
domain: web-services
keywords: [textencoding, text-encoding, utf8, msdos, createoutstream, createinstream, blob, file-export, character-corruption]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set the text encoding when converting exchanged text to or from BLOB bytes

## Description

`Blob.CreateInStream` and `Blob.CreateOutStream` take an optional `TextEncoding`; when it is omitted, the stream uses `MSDos` (OEM) encoding, whose code page depends on the server's system locale. Encoding matters when an operation converts between AL text and bytes, such as `WriteText` or `ReadText`. Text written and read through streams with the same default can round-trip inside Business Central, but writing MSDos bytes for a UTF-8 consumer or reading externally encoded UTF-8 bytes as MSDos can corrupt accented and non-Latin characters (for example `à`, `ß`, `ø`, `ł`). In Business Central online the server locale cannot be controlled, so Microsoft recommends UTF-8 or UTF-16.

Creating a stream does not transcode the BLOB. `DownloadFromStream`, stream-based HTTP content, raw uploads, and `CopyStream` can transfer existing bytes without decoding or re-encoding text. A default-encoding InStream used only to download bytes written by a UTF-8 OutStream preserves those UTF-8 bytes.

## Best Practice

Pass `TextEncoding::UTF8` (or the encoding the counterpart requires, such as `UTF16` or `Windows`) on the stream that performs an encoding-sensitive text write or read. Match the writer to the external consumer's expected encoding and the reader to the actual encoding of the incoming bytes. If both sides convert text, configure compatible encodings on both. Treat `MSDos` as legacy, chosen only when the counterpart demands an OEM code page.

Do not flag the default encoding when the stream carries binary content (images, PDFs, ZIP archives), when text is written and read back only inside Business Central through streams with the same encoding, or when already encoded data is transferred byte-for-byte without text conversion. An omitted encoding on a stream used only for `DownloadFromStream`, stream-based HTTP transfer, raw upload, or `CopyStream` is not evidence of a defect. Trace the actual text conversion, not merely the transport API.

See sample: [`set-text-encoding-on-streams-exchanged-externally.good.al`](set-text-encoding-on-streams-exchanged-externally.good.al).

## Anti Pattern

An encoding-sensitive text write (such as `OutStr.WriteText`) or text read (such as `InStr.ReadText`) through a BLOB stream with a missing or incompatible encoding, where the external consumer expects a different encoding or the incoming bytes use a different encoding. For example, default MSDos `WriteText` output downloaded as a UTF-8 CSV, or UTF-8 uploaded bytes decoded with a default MSDos `ReadText`. Mere stream creation or byte-preserving transfer is not this anti-pattern. The defect can be invisible with ASCII-only test data.

See sample: [`set-text-encoding-on-streams-exchanged-externally.bad.al`](set-text-encoding-on-streams-exchanged-externally.bad.al).

## References

[Blob.CreateInStream method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/blob/blob-createinstream-method) (the default encoding is MSDos) and [File handling and text encoding](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-file-handling-and-text-encoding) (MS-DOS depends on the server's system locale; online, use UTF-8/UTF-16).
