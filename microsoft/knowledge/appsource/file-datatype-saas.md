---
bc-version: [all]
domain: appsource
keywords: [file-datatype, saas, onprem, uploadintostream, downloadfromstream, instream, outstream, streaming]
technologies: [al]
countries: [w1]
application-area: [all]
---

# The File data type's direct I/O methods are OnPrem-only

> Contributions welcome — open a PR to refine or extend this article.

## Description

The classic `File` variable type — `Open`/`Create`/`Read`/`Write`/`Close` against a path on the local or server filesystem — is scoped OnPrem-only. Code targeting Business Central Online that calls `File.Open`, `File.Create`, `File.Read`, or `File.Write` fails to compile against a Cloud-scoped project; it does not compile successfully and fail or get silently skipped at runtime. Separately, and regardless of the compile-time scoping, no server/local filesystem path is available to an extension actually running in Business Central Online.

## Best Practice

Use the stream-based equivalents: `UploadIntoStream` to read user-selected file content into an `InStream`, and `DownloadFromStream` to write an `OutStream`'s content to a file the user saves. Stage the content in a `TempBlob` between the stream and the rest of the parsing/formatting code.

See sample: `file-datatype-saas.good.al`.

## Anti Pattern

Opening a hardcoded or user-supplied filesystem path with the `File` variable type. This is a strong signal the code was written for on-premises only, or copied from material that predates the cloud-first streaming APIs.

See sample: `file-datatype-saas.bad.al`.
