---
bc-version: [all]
domain: privacy
keywords: [isolatedstorage, encryption, tokens, refactor, regression]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not move PII or secrets from IsolatedStorage to plain table fields

## Description

IsolatedStorage with SetEncrypted keeps sensitive values — tokens, URLs carrying identifiers, delta cursors with embedded user context — encrypted at rest and scoped to the extension. Moving the same value to a normal table field is a refactor that looks structural but is a privacy and security regression: the value is now plaintext in SQL, visible to every reader of that table, backed up and replicated as ordinary business data. Reviews of existing integrations frequently see this change justified as "easier to query" — the concern is the storage model, not the ergonomics.

## Best Practice

Keep tokens, secrets, personal-context URLs, and similar sensitive values in IsolatedStorage (SetEncrypted) or Azure Key Vault. When a refactor moves the value, require an explicit justification and a mitigating control (restricted-read permission set, value-level encryption, redaction in the access path). Otherwise leave it where it was.

See sample: `do-not-move-pii-from-isolated-storage-to-plain-fields.good.al`.

## Anti Pattern

A diff that deletes an `IsolatedStorage.SetEncrypted` call and writes the same value into a new `Text` column on a business table. The value is now unencrypted, unscoped, and indistinguishable from non-sensitive content to any caller reading the table.

See sample: `do-not-move-pii-from-isolated-storage-to-plain-fields.bad.al`.
