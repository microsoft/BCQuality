---
bc-version: [all]
domain: security
keywords: [ssrf, uri, url-validation, areurishavesamehost, isvaliduripattern, httpclient]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Validate URLs that come from table fields before calling them

## Description

A URL stored in a table field is user-configurable: anyone with write access to the row can change it. If that URL is then used as the target of an `HttpClient.Get`/`Post`, the extension becomes a server-side request forgery (SSRF) primitive — an attacker can redirect the call to an internal endpoint, to a metadata service, or to a malicious host that mirrors the legitimate API. The `Uri` codeunit from System Modules provides two validators built for this situation: `AreURIsHaveSameHost()` checks that two URLs share the same host (use when the hostname should not change — for example, the extension always talks to `api.contoso.com`). `IsValidURIPattern()` checks that a URL matches a wildcard pattern (use when the host varies but follows a predictable shape — for example `https://{store}.myshopify.com/...`).

## Best Practice

Before any `HttpClient` call whose URL came from a table field, call `Uri.AreURIsHaveSameHost(StoredUrl, ExpectedBaseUrl)` against a hard-coded expected base, or `Uri.IsValidURIPattern(StoredUrl, 'https://*.myshopify.com/*')` against a fixed pattern. Fail the call with an `Error` when the validator returns false. For webhook scenarios where the host is registered out-of-band, compare against the registered host stored alongside the URL. See sample: [`validate-user-configurable-urls.good.al`](validate-user-configurable-urls.good.al).

## Anti Pattern

`HttpClient.Get(Setup."Service URL", Response)` or `HttpClient.Post(WebhookSetup."Callback URL", Content, Response)` with no validation step in between. The extension will dutifully send the request — and any sensitive payload — to whatever host the attacker put in the field. Reviewers should flag any `HttpClient` call whose first argument is a record field, an `OnValidate`-mutable field, or a value sourced from a table read, unless a `Uri.AreURIsHaveSameHost` or `Uri.IsValidURIPattern` check precedes it. See sample: [`validate-user-configurable-urls.bad.al`](validate-user-configurable-urls.bad.al).
