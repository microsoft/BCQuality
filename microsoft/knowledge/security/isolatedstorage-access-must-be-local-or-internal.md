---
bc-version: [24..]
domain: security
keywords: [isolatedstorage, local, internal, public, getter, setter, encapsulation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not expose extension-owned IsolatedStorage through an unrestricted public API

## Description

`IsolatedStorage` partitions its data by extension, but an owning extension can expose its values through its own API. An unrestricted, externally callable getter or setter for an extension-owned secret can defeat that isolation even when the value remains `SecretText`. Determine effective reachability from both the codeunit and the procedure: an unmodified procedure declaration on an `Access = Internal` codeunit is not an external public getter merely because it omits `local` or `internal`.

## Best Practice

Keep storage helpers behind the appropriate object/member access and provide consumers with a narrow, intent-specific API, such as sending a notification rather than returning its configured credential. Procedures on an internal codeunit may remain callable by other objects in the app without redundant member modifiers. This is API encapsulation, not authorization: trace public wrappers, friend access and runtime entry points, and enforce permissions or operation-specific authorization where required. Do not infer either a leak or safety from the modifier alone; see [internal access is not a security boundary](internal-access-is-not-a-security-boundary.md). See sample: [`isolatedstorage-access-must-be-local-or-internal.good.al`](isolatedstorage-access-must-be-local-or-internal.good.al).

## Anti Pattern

An externally reachable `GetApiKey()` returns an extension-owned stored credential, or an unrestricted `SetApiKey` lets arbitrary consumers overwrite it. Establish the actual exposure and missing authorization rather than flagging every body that references `IsolatedStorage`; even `Contains` does not itself return the stored secret. See sample: [`isolatedstorage-access-must-be-local-or-internal.bad.al`](isolatedstorage-access-must-be-local-or-internal.bad.al).

## References

[Isolated storage](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-isolated-storage) and [Access property](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-access-property).
