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

The classic `File` variable type — `Open`/`Create`/`Read`/`Write`/`Close` against a path on the local or server filesystem — only works on-premises, because there is no accessible filesystem in the SaaS/cloud sandbox. Any extension meant to run in Business Central Online must not rely on `File.Open`, `File.Create`, `File.Read`, or `File.Write` for its core functionality: code built this way compiles but fails, or is silently skipped, in the cloud.

## Best Practice

Use the stream-based equivalents: `UploadIntoStream` to read user-selected file content into an `InStream`, and `DownloadFromStream` to write an `OutStream`'s content to a file the user saves. Stage the content in a `TempBlob` between the stream and the rest of the parsing/formatting code.

See sample: `file-datatype-saas.good.al`.

## Anti Pattern

Opening a hardcoded or user-supplied filesystem path with the `File` variable type. This is a strong signal the code was written for on-premises only, or copied from material that predates the cloud-first streaming APIs.

See sample: `file-datatype-saas.bad.al`.
