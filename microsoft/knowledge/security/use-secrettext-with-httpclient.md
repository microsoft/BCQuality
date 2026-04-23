---
bc-version: [all]
domain: security
keywords: [httpclient, secrettext, headers, uri]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use SecretText with HttpClient

## Description

HttpRequestMessage, HttpHeaders, and HttpContent expose SecretText overloads so credentials never have to be converted back to Text to be sent. Key APIs: HttpRequestMessage.SetSecretRequestUri (for URIs containing secrets), HttpHeaders.Add(name, SecretText) for authorization headers, HttpHeaders.ContainsSecret to probe secret-valued headers, HttpContent.WriteFrom(SecretText) for request bodies, and HttpContent.ReadAs(SecretText) to pull response bodies into a secret destination.

## Best Practice

Use HttpRequestMessage.SetSecretRequestUri when any URI component is sensitive (for example, a per-call API key in the path or query), and send the request with HttpClient.Send. Add Authorization headers as SecretText. Check for the presence of a secret header with ContainsSecret, not Contains.

See sample: `use-secrettext-with-httpclient.good.al`.

## Anti Pattern

Materializing a URI or header value as Text to 'just get it to compile' — for example, StrSubstNo into a Text and then HttpClient.Get(FullUrl, Response). The resulting Text is visible in debuggers, and the URL is typically captured by platform-level logging the extension does not control.

See sample: `use-secrettext-with-httpclient.bad.al`.

