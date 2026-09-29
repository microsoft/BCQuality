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

See sample: [`handle-httpclient-platform-failure-before-response-access.good.al`](handle-httpclient-platform-failure-before-response-access.good.al).

## Anti Pattern

Capturing a failed call in a Boolean and then reading `Response.Content()`, parsing the body, or otherwise treating `Response` as usable. Do not report omission of the Boolean by itself; that form deliberately delegates failure propagation to the runtime.

See sample: [`handle-httpclient-platform-failure-before-response-access.bad.al`](handle-httpclient-platform-failure-before-response-access.bad.al).

## References

- [HttpClient.Send method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/httpclient/httpclient-send-method)
- [Call external services with HttpClient](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-httpclient)