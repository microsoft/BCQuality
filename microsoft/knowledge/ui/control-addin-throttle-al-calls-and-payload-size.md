---
bc-version: [20..]
domain: ui
keywords: [control-add-in, invokeextensibilitymethod, success-callback, throttling, payload, reduced-functionality]
technologies: [javascript]
countries: [w1]
application-area: [all]
---

# Serialize control add-in AL calls and keep payloads small

## Description

`InvokeExtensibilityMethod` crosses from a control add-in into the Business Central service. Repeated calls that outpace AL execution fill the communication channel, trigger reduced-functionality warnings, and can be queued, throttled, or rejected; an oversized single payload can also be rejected immediately. The success and error callbacks exist so the add-in can bound this traffic.

## Best Practice

Send byte-bounded chunks and invoke the next AL event only from the previous call's completion callback. Handle the error callback and stop until the caller explicitly retries or discards the failed chunk. There is no universal safe threshold, so measure the serialized argument array, reserve transport headroom below the server's `ClientServicesMaxUploadSize`, and reject an individual item that exceeds the configured budget.

See sample: `control-addin-throttle-al-calls-and-payload-size.good.js`.

## Anti Pattern

Calling `InvokeExtensibilityMethod` on an interval without tracking completion, recursively creating intervals, or serializing an entire unbounded dataset into one call. These patterns can overwhelm the client-service channel or exceed the upload limit.

See sample: `control-addin-throttle-al-calls-and-payload-size.bad.js`.

## Source

[Control add-in performance best practices](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-control-addin-bestpractices), [InvokeExtensibilityMethod](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods/devenv-invokeextensibility-method), and [control add-in resiliency](https://learn.microsoft.com/dynamics365/business-central/across-controladdin-resiliency).
