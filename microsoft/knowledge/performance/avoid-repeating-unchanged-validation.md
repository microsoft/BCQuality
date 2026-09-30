---
bc-version: [all]
domain: performance
keywords: [validate, onvalidate, repeated-write, sales-line, subscriber, unchanged-value]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Avoid repeating validation when its inputs have not changed

## Description

`Validate` runs field validation logic, which can invoke subscribers and additional reads or writes even if the assigned value is unchanged. When a document-building path validates the same field twice without changing any input its validation depends on, the second cascade may do the same work again. A field-value comparison alone does not prove that the dependent context or required event behavior is unchanged.

## Best Practice

Trace the table's `OnValidate`, subscribers, and dependent fields before removing a duplicate invocation. Keep the required validation and write, but skip a second `Validate` only when all its inputs, its order-dependent effects, and the business contract are demonstrably unchanged. Measure validations and writes per business unit and test pricing, reservations, error behavior, and subscriber effects on real document paths. The sample's custom field validation depends only on Quantity and Unit Price; a note assigned between calls does not affect either. See sample: [`avoid-repeating-unchanged-validation.good.al`](avoid-repeating-unchanged-validation.good.al).

## Anti Pattern

Validating Quantity, changing only an unrelated local or record note, validating the same Quantity again, then modifying the row, without any required second event. Do not replace `Validate` with direct assignment, use `Insert(false)` indiscriminately, or reorder validations on a Sales Line solely to reduce call counts: its standard logic can depend on other fields and event subscribers. See sample: [`avoid-repeating-unchanged-validation.bad.al`](avoid-repeating-unchanged-validation.bad.al).

## References

- [Record.Validate and field validation behavior](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-validate-method).
- [Equivalent bulk assignments versus per-row validation](prefer-modifyall-over-per-row-modify.md).
- [Subscriber guards](guard-event-subscribers-before-db-call.md).
