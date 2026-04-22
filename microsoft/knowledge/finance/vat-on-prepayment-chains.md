---
bc-version: [1..99]
domain: finance
keywords: [vat-prepayment, prepayment-chain, credit-memo, rounding, proportional-adjustment]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# VAT on prepayment chains

## Description

When a Sales or Purchase document carries a prepayment percentage, Business Central splits VAT across the prepayment and the final invoice. The prepayment invoice posts VAT on the prepayment percentage of the order; the final invoice posts VAT on the remaining portion and contains a deduction line that reverses the prepayment's VAT share. If a credit memo reverses either leg, its VAT must proportion across whatever has already posted. This chain — prepayment invoice → final invoice → optional credit memo — must reconcile to the same VAT amount a one-shot invoice would have produced.

The chain is rounding-sensitive: each leg rounds independently per the VAT posting setup, and the sum of rounded legs can differ from rounding the total once. In multi-currency chains, each leg may use a different exchange rate (posting date differs), further complicating reconciliation. Symptom: the VAT account carries a 0.01 or 0.02 residual after all legs post; no single posting caused it, but the chain does not balance to the expected single-invoice equivalent.

## Best Practice

Let Business Central compute and post the VAT on every leg rather than overriding it. The proportional-adjustment logic inside codeunit 80/90 expects to own these amounts; manual overrides produce residuals that only surface at VAT return time.

## Anti Pattern

Correcting a prepayment-chain mismatch by modifying the VAT Entry on the final invoice. The entry is linked to the G/L Entry and the sales invoice line; editing it desynchronises the three and the VAT return aggregates the wrong number. Post a corrective document instead.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "VAT Calculation" and "VAT Edge Cases That Cause Triage Issues") on 2026-04-21.
