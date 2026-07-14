---
bc-version: [23..]
domain: security
keywords: [secrettext, httpclient, setsecretrequesturi, containssecret, headers, http]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set secret request URIs on HttpRequestMessage

## Description

The secret URI API belongs to `HttpRequestMessage`, not `HttpClient`. `HttpRequestMessage.SetSecretRequestUri(SecretText)` keeps a credential-bearing URI protected, and the prepared request is sent with `HttpClient.Send`. Companion APIs also accept `SecretText`, including `HttpHeaders.Add` for authorization headers and `HttpContent.WriteFrom` for secret request bodies.

## Best Practice

Compose a secret URI with `SecretStrSubstNo`, call `Request.SetSecretRequestUri(SecretUri)`, set the request method, and send the request with `HttpClient.Send(Request, Response)`. For authorization, get the request headers, add a `SecretText` value, and use `ContainsSecret` when checking for that header. See sample: `secrettext-with-httpclient.good.al`.

## Anti Pattern

Holding a credential in `Text`, interpolating it with `StrSubstNo` or concatenation, and passing that plain text to `HttpClient.Get` or `HttpHeaders.Add`. The secret-aware request and header APIs remove the need to materialize the value as `Text`. See sample: `secrettext-with-httpclient.bad.al`.
