---
bc-version: [24..]
domain: security
keywords: [isolatedstorage, setencrypted, encryption, secret, storage]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer IsolatedStorage.SetEncrypted over Set for sensitive values

## Description

`IsolatedStorage` exposes two write entry points: `Set` stores the value as-is, and `SetEncrypted` stores it encrypted at rest. Both are scoped per extension, but only `SetEncrypted` adds the additional protection that the value is not readable from the underlying storage by anything that bypasses the AL `IsolatedStorage` API. The choice between them is by intent: configuration that is not sensitive (a user preference, a default flag) can use `Set`; anything that would harm the tenant if leaked — API keys, tokens, connection strings, OAuth client secrets — uses `SetEncrypted`.

## Best Practice

Use the `SecretText` overloads of `IsolatedStorage.SetEncrypted` and `IsolatedStorage.Get` for values that meet the definition of a secret. Check the optional Boolean result when storage failure needs a controlled error; encrypted values are subject to the documented storage-size limit. See sample: `isolatedstorage-setencrypted-for-sensitive-values.good.al`.

## Anti Pattern

`IsolatedStorage.Set('ApiKey', ApiKeyValue, DataScope::Module)` — the key is now sitting in storage unencrypted, and any future incident that exposes the underlying storage exposes the key. Reviewers should flag any `IsolatedStorage.Set` whose key name or surrounding context suggests a secret (`ApiKey`, `Token`, `Password`, `Secret`, `ClientSecret`). See sample: `isolatedstorage-setencrypted-for-sensitive-values.bad.al`.
