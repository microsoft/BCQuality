---
bc-version: [all]
domain: error-handling
keywords: [insert, modify, delete, get, rename, evaluate, tryfunction, boolean-return, clarify-before-building, ambiguous]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Ambiguous record-failure handling must be clarified, not guessed

## Description

`Insert`, `Modify`, `Delete`, `Get`, and `Rename` all return a Boolean
indicating success — and so does `Evaluate()` when parsing text into a
Decimal/Date/etc., and any `[TryFunction]` call. The same ambiguity applies
to all of them, not just the five record methods: there are two legitimate
ways to use a failed call, and the choice between them cannot be guessed.
Let AL raise its own runtime error when the return value is ignored and the
call fails, or check the return value explicitly and decide what happens on
failure (`if not Rec.Insert() then ...` / `if not Evaluate(Qty, Text) then
...`). Both are correct in the right context — an ignored `Get()` failing is
often exactly the right behavior when the record is expected to exist and
its absence is a genuine bug; an ignored `Insert()` failing on a duplicate
key might instead be a normal, recoverable case the caller should handle
gracefully; an ignored `Evaluate()` on user-supplied text defaulting to 0
is fine for a display estimate but not for a value that becomes a posted
quantity.

Because both are legitimate, this is not a pattern an AI assistant should
resolve by guessing. When it is unclear from the surrounding code, the
task description, or the object's existing conventions whether a given
failure should surface as AL's implicit runtime error or be handled
explicitly, ask the developer which behavior is intended before writing
the call — the same way [[clarify-before-building]] applies to any other
underspecified requirement. Silently picking one approach risks either
swallowing a failure the developer needed to see, or crashing a flow the
developer expected to degrade gracefully.

## Best Practice

```al
// Failure is expected and recoverable — handle it explicitly.
if not Customer.Insert() then
    Error('Customer %1 already exists.', Customer."No.");

// Failure would indicate a genuine bug — let it surface as AL's own error.
Customer.Get(CustomerNo);
```

When genuinely unsure which case applies, ask: "Should a failed
Insert/Modify/Delete/Get here be handled as an expected, recoverable
outcome, or is it a bug we want to surface immediately?"

## Anti Pattern

Silently choosing to ignore the return value (or silently choosing to wrap
every call in an `if not ... then` with a generic error message) without
first checking whether the surrounding code, task, or object convention
already signals which behavior is intended.

## The High-Stakes Case: Financially or Legally Significant Fields

The most damaging version of guessing wrong isn't a crash — it's a guarded
lookup (`Get()`, `Evaluate()`, a `TryFunction`) whose failure path silently
returns a blank/zero value that then flows into VAT, posting, or amount
calculations. A crash is visible; a silently wrong VAT posting group, a
blank VAT registration number used in compliance reporting, or a
mis-parsed weight that silently becomes a zero-quantity posted line is
not — and it can post real, wrong financial data before anyone notices.

```al
// ANTI-PATTERN: a guarded lookup defaults a VAT-relevant field to blank
// on failure, and that blank value flows straight into VAT classification.
local procedure GetRelatedVATRegistrationNo(DocumentNo: Code[20]): Text[20]
var
    Header: Record "Some Document Header";
begin
    if Header.Get(DocumentNo) then
        exit(Header."VAT Registration No.");
    exit(''); // silently wrong — this Get() should not be expected to fail
end;

// ANTI-PATTERN: the same shape via Evaluate() instead of Get() — a parse
// failure silently becomes 0, and 0 flows unchecked into a posted quantity.
local procedure ParseWeight(RawValue: Text): Decimal
var
    Weight: Decimal;
begin
    if Evaluate(Weight, RawValue) then
        exit(Weight);
    exit(0); // silently wrong if this feeds a posted line's Quantity
end;
```

Verified against Microsoft's own current Base Application source
(microsoft/BCApps, 2026-08-13): wherever a VAT-relevant field like `VAT
Registration No.` is read for a document check or compliance report, the
pattern is `TestField("VAT Registration No.")` — fail loud with the exact
field named — not a silent default (seen consistently across
`OIOUBLCheckSalesHeader`, `OIOUBLCheckReminder`, `VATVIESDeclarationDisk`,
and others). Where Microsoft *does* guard a Setup `Get()` for a VAT-related
field (e.g. `VATSetup.Get() ? VATSetup."Alt. Cust. VAT Reg. Consistent" :
"...Consist."::Default`), the fallback is always an explicit, named,
business-meaningful default value — never a blank string or a bare zero.

### Trace before flagging — a matching shape is not automatically a violation

A guarded lookup that superficially matches the anti-pattern above is only
a real violation if tracing forward confirms both:

1. **The guard is actually reachable.** If the record's own creation and
   deletion invariants guarantee the parent always exists by the time this
   code runs (e.g. the parent is always inserted before the child can be
   validated, and deleting the parent is blocked or cascades to the
   child), the `else` branch is dead code in practice, not a live risk —
   even though `TableRelation` alone never *enforces* that guarantee, so
   guarding defensively is still reasonable engineering, just not evidence
   of a bug.
2. **The defaulted value isn't caught by a downstream fail-loud check.**
   If the blank/zero value only ever reaches a boolean gate or classifier
   that itself calls `TestField`/`Error` before anything posts, the guard
   two hops upstream isn't where the real safety property lives — the
   downstream check is, and it's already doing its job.

Evaluated case that looked like the anti-pattern but wasn't: a guarded
`Header.Get(DocumentNo)` feeding a VAT-registration-style field, where (1)
every real creation path inserted the header before the line could be
validated and the header's `OnDelete` blocked orphaning, and (2) the blank
fallback only ever reached a boolean classification gate whose own
consuming branch called `TestField` before touching anything postable.
Flagging that case would have been a false positive — the shape matched,
the risk didn't, because both tracing steps came back negative.

The rule this sharpens to: if the field being read feeds a VAT, posting,
or amount calculation, resolving the ambiguity in [[clarify-before-building]]'s
favor is not optional *unless tracing clears it* — either the lookup
shouldn't be guarded at all (the parent record is expected to always exist,
so let `Get()`/`TestField` fail loud), or the fallback must be an explicit,
named, deliberately-chosen business default, never a blank or zero value
that quietly passes through — or the trace shows the guard is unreachable
and/or downstream-protected, in which case it's a false alarm, not a fix.
See [[defensive-vs-offensive-code-must-match-blast-radius]] for the general
decision framework this case is an instance of.
