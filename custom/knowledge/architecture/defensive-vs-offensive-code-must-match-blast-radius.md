---
bc-version: [all]
domain: architecture
keywords: [defensive-programming, offensive-programming, fail-fast, blast-radius, guarded-lookup, error-handling]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Defensive vs. offensive code must match the blast radius of being wrong

## Description

Whether a piece of code should guard gracefully (defensive) or fail loudly
(offensive/fail-fast) is not a matter of habit or a blanket house style —
it's a decision that depends on what happens downstream if the guarded
condition is silently defaulted or skipped. Treating every missing value
the same way, defensively or offensively, is itself the anti-pattern:
uniform defensiveness hides the failures that matter most; uniform
fail-fast makes ordinary, expected absence into unnecessary crashes.

Two fields can look structurally identical — both read from a related
record, both potentially missing — and still deserve opposite treatment.
A VAT registration number used only on a printed document is something a
reviewer will likely catch before the document is sent. A VAT Prod.
Posting Group that determines the VAT % applied to a posted transaction
is not: once posted, it's wrong money on a ledger entry, discoverable only
by someone specifically auditing VAT postings, and expensive to correct.
Same shape of code, opposite correct behavior.

## The Decision

Trace what a silently-defaulted or skipped value actually reaches before
deciding how to guard it:

1. **Does it reach a posted ledger amount, a VAT/tax calculation, a
   quantity or price actually used in a transaction, or a legally/
   compliance-facing output (e.g. numbers submitted in a VAT
   declaration)?** → Code offensively. Let the lookup fail loud
   (`TestField`, an unguarded `Get()` that's expected to always succeed,
   or an explicit `Error`) so a human sees the problem *before* anything
   posts — a blocked task is always cheaper than a wrong ledger entry.
2. **Is it cosmetic, informational, or easily corrected after the fact
   (a display field, an optional UI enhancement, a report that hasn't
   run yet)?** → Code defensively — guard the lookup, but the fallback
   must be an explicit, deliberately-chosen, named business value, never
   a blank string or zero that happens to be the datatype default with
   no thought behind it (see [[ambiguous-record-failure-handling-must-be-clarified]]
   for the general Get/Insert/Modify/Delete version of this same choice).
3. **Genuinely unsure which category a field falls into?** That's a
   [[clarify-before-building]] moment, not a coin flip — ask the
   developer, don't default to whichever style is more familiar to write.

## Anti Pattern

```al
// Both fields guarded the same way, out of habit rather than analysis.
if Header.Get(DocumentNo) then
    VATRegNo := Header."VAT Registration No.";   // low blast radius — fine to default
// but the same pattern, unexamined, was also applied here:
if Header.Get(DocumentNo) then
    VATProdPostingGroup := Header."VAT Prod. Posting Group"
else
    VATProdPostingGroup := '';   // high blast radius — silently wrong VAT on posting
```

## Best Practice

```al
// Low blast radius: guard, with an explicit chosen fallback.
if Header.Get(DocumentNo) then
    VATRegNo := Header."VAT Registration No.";
// (blank is an acceptable, deliberately-considered default here — the
// field is informational and a reviewer sees it before the document ships)

// High blast radius: let it fail loud, because this feeds posted VAT.
Header.Get(DocumentNo); // expected to always succeed for a line's own header
Header.TestField("VAT Prod. Posting Group");
VATProdPostingGroup := Header."VAT Prod. Posting Group";
```

## Source

Michael Dieringer, 2026-08-13, refining [[ambiguous-record-failure-handling-must-be-clarified]]'s
VAT-critical sharpening after noting that not all VAT-adjacent fields carry
the same risk — a VAT registration number and a VAT posting group are not
equally dangerous to get wrong, and a single blanket rule for "VAT fields"
would either over- or under-guard depending on which one it's applied to.
