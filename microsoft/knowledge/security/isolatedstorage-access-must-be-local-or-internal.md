---
bc-version: [24..]
domain: security
keywords: [isolatedstorage, local, internal, public, getter, setter, encapsulation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep IsolatedStorage helpers behind the intended API boundary

## Description

`IsolatedStorage` partitions its data by extension, but the owning extension can expose stored values through its own API. An unrestricted, externally callable getter or setter for an extension-owned secret can defeat that isolation. A procedure referencing `IsolatedStorage` is not enough to establish exposure: consider what it does and the effective access of both the object and its member. A procedure without a member modifier on an `Access = Internal` codeunit is not thereby a public API for arbitrary dependent apps.

## Best Practice

Keep storage helpers local or internal through the appropriate object/member access. Provide consumers with a narrow, intent-specific API — for example, "send notification to configured webhook" rather than "give me the webhook secret." Access modifiers are compile-time encapsulation, not runtime authorization: public wrappers, explicitly permitted friend apps and runtime entry points still need the appropriate authorization. See sample: [`isolatedstorage-access-must-be-local-or-internal.good.al`](isolatedstorage-access-must-be-local-or-internal.good.al).

## Anti Pattern

An unrestricted external `GetApiKey()` returns the extension's stored credential, or a setter allows unauthorized callers to overwrite it. A `SecretText` value still requires recipient authorization. Identify the exposed data or operation and missing authorization; neither a storage call nor a missing member modifier alone establishes that defect. See sample: [`isolatedstorage-access-must-be-local-or-internal.bad.al`](isolatedstorage-access-must-be-local-or-internal.bad.al).

Reference: [Access property and its compile-time limits](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-access-property).
