---
bc-version: [24..]
domain: security
keywords: [isolatedstorage, local, internal, public, getter, setter, encapsulation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Procedures that read or write IsolatedStorage must not be public

## Description

`IsolatedStorage` partitions its data by extension: values written by one extension are unreadable to another. That guarantee assumes the owning extension does not voluntarily expose its storage through a public API. A `public` procedure on a codeunit that calls `IsolatedStorage.Get`, `IsolatedStorage.Set`, `IsolatedStorage.SetEncrypted`, `IsolatedStorage.Contains`, or `IsolatedStorage.Delete` defeats the isolation: any other extension on the same tenant can call that procedure and obtain (or overwrite) the secret. The platform's per-extension boundary becomes a per-procedure boundary, and there is no per-procedure boundary.

## Best Practice

Mark every procedure that touches `IsolatedStorage` as `local` (visible only inside its containing object) or `internal` (visible only inside the owning extension). Provide consumers with a narrow, intent-specific API — for example, "send notification to configured webhook" rather than "give me the webhook secret." See sample: `isolatedstorage-access-must-be-local-or-internal.good.al`.

## Anti Pattern

A public `GetApiKey()` returning the stored value, or a public `SetApiKey(NewKey: Text)` that calls `IsolatedStorage.SetEncrypted`. Both turn the extension into a confused deputy that hands out (or accepts overwrites of) its own secrets on behalf of any caller on the tenant. Reviewers should flag any procedure whose body references `IsolatedStorage` and whose declaration omits `local` or `internal`. See sample: `isolatedstorage-access-must-be-local-or-internal.bad.al`.
