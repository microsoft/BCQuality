---
bc-version: [all]
domain: error-handling
keywords: [insert, modify, delete, get, rename, boolean-return, clarify-before-building, ambiguous]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Ambiguous record-failure handling must be clarified, not guessed

## Description

`Insert`, `Modify`, `Delete`, `Get`, and `Rename` all return a Boolean
indicating success. There are two legitimate ways to use that: let AL
raise its own runtime error when the return value is ignored and the call
fails, or check the return value explicitly and decide what happens on
failure (`if not Rec.Insert() then ...`). Both are correct in the right
context — an ignored `Get()` failing is often exactly the right behavior
when the record is expected to exist and its absence is a genuine bug;
an ignored `Insert()` failing on a duplicate key might instead be a normal,
recoverable case the caller should handle gracefully.

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
`Get()` whose failure path silently returns a blank/zero value that then
flows into VAT, posting, or amount calculations. A crash is visible; a
silently wrong VAT posting group or a blank VAT registration number used
in compliance reporting is not, and it can post real, wrong financial data
before anyone notices.

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

The rule this sharpens to: if the field being read feeds a VAT, posting,
or amount calculation, resolving the ambiguity in [[clarify-before-building]]'s
favor is not optional — either the lookup shouldn't be guarded at all (the
parent record is expected to always exist, so let `Get()`/`TestField` fail
loud), or the fallback must be an explicit, named, deliberately-chosen
business default, never a blank or zero value that quietly passes through.
