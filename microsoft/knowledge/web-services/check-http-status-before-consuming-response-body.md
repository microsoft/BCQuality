---
bc-version: [all]
domain: web-services
keywords: [httpclient, httpresponsemessage, issuccessstatuscode, httpstatuscode, response-body, json]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Check HTTP status before consuming the response body

## Description

A successful AL `HttpClient` call only confirms that the platform completed the HTTP exchange. The server can still return `4xx` or `5xx`, often with an error document whose shape differs from the expected success payload. Parsing that body as business data can produce misleading parse errors, incomplete records, or decisions based on an error response.

## Best Practice

After handling any platform or transport failure, check `HttpResponseMessage.IsSuccessStatusCode()` or the expected `HttpStatusCode()` before interpreting the response body as a success payload. Handle non-success status explicitly and include safe diagnostic context when appropriate. A bounded error body may be read for diagnostics, but it must not enter the success parsing path.

See sample: [`check-http-status-before-consuming-response-body.good.al`](check-http-status-before-consuming-response-body.good.al).

## Anti Pattern

Checking only the Boolean result of `Get`, `Post`, `Put`, `Delete`, or `Send` and then parsing `Response.Content()` as the expected payload. The Boolean can be `true` for any HTTP status, including authentication failures, throttling, validation errors, and server failures.

See sample: [`check-http-status-before-consuming-response-body.bad.al`](check-http-status-before-consuming-response-body.bad.al).

## References

- [HttpResponseMessage.IsSuccessStatusCode method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/httpresponsemessage/httpresponsemessage-issuccessstatuscode-method)
- [HttpClient data type](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/httpclient/httpclient-data-type)