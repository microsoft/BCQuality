---
bc-version: [24..]
domain: security
keywords: [isolatedstorage, datascope, module, company, user, scope]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pick the right IsolatedStorage DataScope for the secret's lifetime

## Description

`IsolatedStorage` read and write methods take a `DataScope` parameter that decides which slice of storage the value belongs to. The choice is not a stylistic one — it changes which callers, in which company and under which user, can read the value back. Two scopes cover the common cases for app-level secrets: `DataScope::Module` stores the value once for the whole extension, isolated to that extension on the tenant — the right scope for app-specific secrets such as a global API key or service account. `DataScope::Company` stores the value per company, so each company on the tenant has its own slot — the right scope for company-specific secrets such as a per-company webhook URL or a per-company integration token. A per-user scope also exists for values that belong to an individual user.

## Best Practice

Choose `Module` when the secret is the same for every company and every user under the extension (a single tenant-wide API key). Choose `Company` when each company has its own integration credentials. Choose the user scope only when the secret is genuinely per-user. Use the same `DataScope` value on `Set`/`SetEncrypted`, `Get`, `Contains`, and `Delete` for the same key — mixing scopes for the same logical secret produces silent "not found" results. See sample: `isolatedstorage-datascope-module-vs-company.good.al`.

## Anti Pattern

Defaulting every call to `DataScope::Module` regardless of intent — storing a per-company webhook URL under `Module` means every company on the tenant shares the same URL. Or the inverse: storing a tenant-wide API key under `Company` means each company-switch effectively loses the key. Reviewers should look for cross-method inconsistency (`Set` under `Module`, `Get` under `Company`) and for scope choices that contradict the value's documented lifetime. See sample: `isolatedstorage-datascope-module-vs-company.bad.al`.
