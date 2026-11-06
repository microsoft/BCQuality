---
bc-version: [all]
domain: web-services
keywords: [httpclient, transport-failure, boolean-return, httpresponsemessage, content, runtime-error]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Handle HttpClient platform failure before accessing the response

## Description

AL `HttpClient` methods can fail before a usable HTTP response exists because of an invalid request, DNS or network failure, certificate validation, timeout, a disabled extension setting, or the response-size limit. When code captures the optional Boolean return value, `false` reports this platform or transport failure. The accompanying `HttpResponseMessage` is not safe to consume; accessing its content after the failed call can raise another error and obscure the original failure.

## Best Practice

When capturing the Boolean return value from `Get`, `Post`, `Put`, `Delete`, or `Send`, stop the current response-processing path immediately when it is `false`. Report or propagate the transport failure without reading status, headers, or content. Omitting the optional Boolean is also valid when fail-fast behavior is intended: the runtime then raises an error if the operation cannot execute.

Both runtime propagation and explicit Boolean handling can be valid. Do not require capturing the Boolean solely to replace the platform exception with a custom error. Report missing transport-error translation only when a visible caller, documented error contract, or concrete user-facing requirement establishes why runtime propagation is insufficient.

See sample: [`handle-httpclient-platform-failure-before-response-access.good.al`](handle-httpclient-platform-failure-before-response-access.good.al).

## Anti Pattern

Capturing a failed call in a Boolean and then reading `Response.Content()`, parsing the body, or otherwise treating `Response` as usable. Do not report omission of the Boolean by itself; that form deliberately delegates failure propagation to the runtime.

A custom error or label used for completed non-2xx responses does not by itself establish a transport-error translation requirement; its presence or absence alone is not a defect. This allowance does not cover returning success after consuming `false` or interpreting a non-success HTTP response as a success payload.

See sample: [`handle-httpclient-platform-failure-before-response-access.bad.al`](handle-httpclient-platform-failure-before-response-access.bad.al).

## References

- [HttpClient.Send method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/httpclient/httpclient-send-method)
- [Call external services with HttpClient](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-httpclient)