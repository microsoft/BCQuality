---
bc-version: [all]
domain: reporting
keywords: [report, run, saveas, downloadfromstream, web-client, loop, zip, data-compression]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Report output in a loop needs one client download

## Description

The Business Central Web client can deliver only one file per request. When AL generates or downloads a report file repeatedly in the same request, only the last file is delivered to the browser. Earlier report output is silently unavailable to the user even though every iteration ran.

## Best Practice

Generate each report into a stream, add the streams to one archive, and call `DownloadFromStream` once after the loop. A direct report run or download inside a loop is valid only when the execution context does not use the Web client or the loop is guaranteed to execute at most once.

See sample: [`report-output-in-a-loop-needs-one-client-download.good.al`](report-output-in-a-loop-needs-one-client-download.good.al).

## Anti Pattern

Call `Report.Run`, `Report.RunModal`, or `DownloadFromStream` repeatedly in a loop initiated by one Web client action and expect every generated file to reach the browser. The client receives only the last download.

See sample: [`report-output-in-a-loop-needs-one-client-download.bad.al`](report-output-in-a-loop-needs-one-client-download.bad.al).

## References

`File.DownloadFromStream` method — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/file/file-downloadfromstream-method

`Data Compression` codeunit — https://learn.microsoft.com/dynamics365/business-central/application/system-application/codeunit/system.io.data-compression