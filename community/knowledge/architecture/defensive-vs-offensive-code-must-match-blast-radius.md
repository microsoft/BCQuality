---
bc-version: [all]
domain: architecture
keywords: [defensive-programming, offensive-programming, fail-fast, blast-radius, guarded-lookup, error-handling]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Defensive vs. offensive code must match the blast radius of being wrong

> Contributions welcome — open a PR to refine or extend this article.

## Description
Whether a piece of code should guard gracefully (defensive) or fail loudly (offensive/fail-fast) depends on what happens downstream if the guarded condition is silently defaulted or skipped — it isn't a matter of habit or a blanket house style. Treating every missing value the same way, defensively or offensively, is itself the anti-pattern: uniform defensiveness hides the failures that matter most, and uniform fail-fast turns ordinary, expected absence into unnecessary crashes. Two fields can look structurally identical — both read from a related record, both potentially missing — and still deserve opposite treatment: a VAT registration number used only on a printed document is something a reviewer will likely catch before the document ships, but a VAT posting group that determines the tax applied to a posted transaction is not — once posted, it's wrong money on a ledger entry, discoverable only by someone specifically auditing VAT postings.

## Best Practice
Trace what a silently-defaulted or skipped value actually reaches before choosing how to guard it. If it reaches a posted ledger amount, a tax calculation, a quantity or price actually used in a transaction, or a compliance-facing output, code offensively: let the lookup fail loud (`TestField`, an unguarded `Get()` expected to always succeed, or an explicit `Error`) so a human sees the problem before anything posts. If it's cosmetic, informational, or easily corrected after the fact, code defensively — guard the lookup, but choose the fallback deliberately rather than accepting whatever the datatype's zero-value default happens to be.

## Anti Pattern
Guarding two fields the same way "out of habit" when they carry different blast radii — for example, defaulting both a VAT registration number and a VAT posting group to blank on a failed lookup — treats a cosmetic field and a transaction-critical one as equally safe to silently default. A reviewer can spot this by a guarded `Get()` feeding a value that reaches a posted amount, a tax calculation, or a compliance output, with no corresponding `TestField` or explicit error on the missing-value path.
