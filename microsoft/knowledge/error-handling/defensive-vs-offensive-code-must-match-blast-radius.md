---
bc-version: [all]
domain: error-handling
keywords: [defensive-programming, offensive-programming, fail-fast, blast-radius, guarded-lookup]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Match defensive vs. offensive error handling to the blast radius of being wrong

## Description

Whether code should guard gracefully (defensive) or fail loudly (offensive/fail-fast) is not a matter of habit or a blanket house style — it depends on what happens downstream if the guarded condition is silently defaulted or skipped. Treating every missing value the same way, defensively or offensively, is itself the anti-pattern: uniform defensiveness hides the failures that matter most, while uniform fail-fast turns ordinary, expected absence into unnecessary crashes. Two fields can look structurally identical — both read from a related record, both potentially missing — and still deserve opposite treatment depending on what they feed.

## Best Practice

Trace what a silently-defaulted or skipped value actually reaches before deciding how to guard it. If it reaches a posted ledger amount, a tax/VAT calculation, a quantity or price actually used in a transaction, or a legally/compliance-facing output, code offensively: let the lookup fail loud (`TestField`, an unguarded `Get()` expected to always succeed, or an explicit `Error`) so a human sees the problem before anything posts. If it is cosmetic, informational, or easily corrected after the fact (a display field, an optional UI enhancement, a report not yet run), code defensively — but the fallback must be an explicit, deliberately-chosen, named business value, never a blank or zero that is merely the datatype default. When genuinely unsure which category a field falls into, that is a question to resolve explicitly with whoever owns the requirement, not a coin flip.

See sample: `defensive-vs-offensive-code-must-match-blast-radius.good.al`.

## Anti Pattern

Guarding two fields the same way purely out of habit, without analyzing what each one feeds. A low-blast-radius field, such as a VAT registration number shown only on a printed document, and a high-blast-radius field, such as the VAT posting group that determines VAT actually applied to a posted transaction, are both wrapped in the same `if Header.Get(...) then ... else` pattern with a blank/zero fallback — leaving the posting-critical field free to post with a silently wrong value.

See sample: `defensive-vs-offensive-code-must-match-blast-radius.bad.al`.
