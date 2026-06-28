---
bc-version: [all]
domain: events
keywords: [recordref, xrec, type-safety, event-parameters, strong-typing, integration-event, clarity]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Avoid loosely typed event parameters

## Description

Passing `RecordRef` or `xRec` as event parameters weakens the contract. A `RecordRef` parameter erases the table type, so subscribers must inspect at run time which table they received and can be handed an unexpected one, losing compile-time checking and direct field access. `xRec` — the previous version of a record — is context-dependent: it is meaningful inside a specific table or page trigger, but ambiguous once passed around as a parameter, and is often stale or empty outside the context that produced it. Prefer a concrete, strongly-typed record plus the specific values a subscriber actually needs, so the contract is explicit and the compiler enforces it.

## Best Practice

Give events concrete record types and explicit values, such as `(SalesLine: Record "Sales Line"; PreviousQuantity: Decimal)`, instead of a `RecordRef` or an `xRec` parameter. Subscribers then get type safety, field access, and an unambiguous contract.

See sample: `avoid-loosely-typed-event-parameters.good.al`.

## Anti Pattern

Event parameters typed as `RecordRef` (no table type) or an `xRec`-style "previous record" (ambiguous, possibly stale) without strong justification. Detection: an event signature containing a `RecordRef` parameter, or a passed-through `xRec` record, where a concrete typed record and explicit values would serve.

See sample: `avoid-loosely-typed-event-parameters.bad.al`.
