---
bc-version: [all]
domain: architecture
keywords: [file-datatype, saas, onprem, uploadintostream, downloadfromstream, instream, outstream, streaming]
technologies: [al]
countries: [w1]
application-area: [all]
---

# The File data type's direct I/O methods are OnPrem-only

## Description

The classic `File` variable type — `OPEN`/`CREATE`/`READ`/`WRITE`/`CLOSE`
against a path on the local/server filesystem — only works on-premises.
None of these methods are supported in SaaS/cloud Business Central,
because there is no accessible filesystem in the cloud sandbox. Any
extension intended to run in Business Central Online (which today means
essentially every new AppSource or CURABIS extension) must not rely on
`File.Open`, `File.Create`, `File.Read`, or `File.Write` for its core
functionality — code built this way compiles but fails, or is silently
skipped, in the cloud.

The cloud-compatible equivalent is stream-based: import via
`UploadIntoStream` (reads user-selected file content into an `InStream`),
export via `DownloadFromStream` (writes an `OutStream`'s content to a
file the user saves), with the actual parsing/formatting done against
`InStream`/`OutStream` rather than a `File` variable. `TempBlob` is the
usual staging container between the stream and the rest of the code.

## Best Practice

```al
var
    TempBlob: Codeunit "Temp Blob";
    InStream: InStream;
    FileName: Text;
begin
    if UploadIntoStream('Import file', '', 'All Files (*.*)|*.*', FileName, InStream) then
        // parse InStream
end;
```

## Anti Pattern

```al
var
    ImportFile: File;
    InStream: InStream;
begin
    ImportFile.WriteMode(false);
    ImportFile.TextMode(true);
    ImportFile.Open('C:\Import\data.txt'); // fails in SaaS — no local filesystem
    ImportFile.CreateInStream(InStream);
end;
```

A hardcoded or user-supplied filesystem path passed to `File.Open`/`Create`
is a strong signal the code was written for on-premises only, or copied
from older material that predates the cloud-first streaming APIs.

## Source

CURABIS Academy course "The Developers Guide through AL" (rev. July 2022),
Chapter 9: Interfaces, "File-Handling", "The File Data Type", "Reading or
Writing Data in External Files" (p. 291–294) — the course material itself
already flags `READ`/`WRITE` as "only supported on-premises," confirmed
still accurate against current Business Central Online behavior as of
2026-08-13.
