---
bc-version: [all]
domain: error-handling
keywords: [testfield, setup-table, configuration, mandatory-field, silent-fallback, correctness]
technologies: [al]
countries: [w1]
application-area: [all]
extends: error-handling/fielderror-vs-testfield.md
---
# TestField a Setup-Table Value Before Using It in a Correctness-Critical Branch

> Contributions welcome — open a PR to refine or extend this article.

## Description
`fielderror-vs-testfield.md` covers choosing between `TestField` and `FieldError` once a check is already known to be needed. This rule covers the decision one step earlier: recognizing that a check is needed at all when a procedure reads a field from a *different* record — typically a setup/configuration table — inside a branch where the surrounding logic has already determined that value is required for correct behavior. A common anti-pattern silently treats "blank" the same as "feature not wanted": `if SetupRec."Some Field" <> '' then exit(UseIt); exit(SomeOtherDefault);`. `Get()` succeeding on the setup record proves the record exists, not that the specific field was ever configured — and the fallback path makes a missing configuration indistinguishable from a deliberate one.

## Best Practice
Once a business rule has decided that a setup-table field's value is required for this branch to behave correctly, call `TestField` on it before use — even though a plain read would "work" (return a blank string or zero without erroring). Do this specifically when the value drives a decision whose wrong outcome is silent and consequential — financial, tax, or compliance-relevant postings are the clearest case, because the failure mode is not a crash a tester would notice, but a quietly wrong result that only surfaces on audit. Write a test that blanks the setup field and asserts the resulting error, so the guard itself is verified rather than merely present.

## Anti Pattern
Reading a required setup-table field with a presence check that falls through to a default instead of erroring: `if Setup."Field" <> '' then exit(Setup."Field"); exit(Default);`. This looks defensive — it never crashes — but it converts "administrator forgot to configure this" into "system silently did something else," which is worse than a hard failure because nobody is told anything went wrong. A reviewer can spot this by finding a setup-table field read inside an already-decided business-rule branch with no `TestField`/`FieldError`/`Error` anywhere on the path.
