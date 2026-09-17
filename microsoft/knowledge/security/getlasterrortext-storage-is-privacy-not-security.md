---
bc-version: [all]
domain: security
keywords: [getlasterrortext, error-text, classification, privacy, review-scope]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Storing GetLastErrorText() in table fields is a privacy finding, not a security finding

## Description

It is tempting to flag any code that calls `GetLastErrorText()` and writes the result into a table field (or displays it to end users) as a security issue, on the assumption that the error text might leak credentials or system internals. In Business Central, that pattern is treated as a **privacy** concern instead: AL `Error` text frequently contains customer content (record keys, field values, document numbers) rather than infrastructure details, and the appropriate review owner is the privacy/DataClassification reviewer. A security reviewer should not raise a finding for `GetLastErrorText()` storage on the grounds that it might expose secrets; that risk is covered elsewhere by the rules that prevent secrets from appearing in error messages in the first place (see `secrettext-for-credentials.md`).

## Best Practice

When auditing AL changes for security, ignore patterns where `GetLastErrorText()` is captured into a table or shown to users — leave those to the privacy review. Security findings on error text should be limited to the construction of the `Error()` call itself: secrets, paths, or technical internals being interpolated into the error before it is raised. See sample: [`getlasterrortext-storage-is-privacy-not-security.bad.al`](getlasterrortext-storage-is-privacy-not-security.bad.al) for the pattern that is *not* a security finding.

## Anti Pattern

Filing a security finding such as "GetLastErrorText() stored in field — potential information disclosure" against AL code that captures an error for later inspection. The finding is in the wrong domain and crowds out the actual security signal. The mirror anti-pattern is silencing genuine `Error('... %1 ...', SecretValue)` constructions on the grounds that "error text is privacy" — those *are* security findings because they create the leak, regardless of where the text ends up afterwards.
