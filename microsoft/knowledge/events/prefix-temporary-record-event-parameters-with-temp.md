---
bc-version: [all]
domain: events
keywords: [temporary-record, naming, event-parameters, buffer, temp-prefix, integration-event, conventions]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefix temporary record event parameters with Temp

## Description

When a record passed to an event is a temporary record — an in-memory buffer not persisted to the database — its parameter name must start with `Temp`. The prefix is the only reliable signal a subscriber has that writes to the record will not reach the database and that the data is scoped to the current call. Without it, subscribers may treat buffer data as persisted: calling `Modify` or `Insert` expecting durability, or reading it as the authoritative table, which leads to silent data loss and confusing behaviour. The `temporary` keyword sits on the variable declaration and is not visible at the subscriber, so the name has to carry the meaning.

## Best Practice

Name temporary record parameters with a `Temp` prefix, for example `var TempSalesLineBuffer: Record "Sales Line" temporary`, so every subscriber sees immediately that the record is an in-memory buffer and treats writes accordingly.

See sample: `prefix-temporary-record-event-parameters-with-temp.good.al`.

## Anti Pattern

A temporary record parameter named without the `Temp` prefix (`var SalesLineBuffer: Record "Sales Line" temporary`), so subscribers cannot tell the record is non-persistent and may rely on writes that are silently discarded. Detection: an event parameter declared `temporary` whose name does not start with `Temp`.

See sample: `prefix-temporary-record-event-parameters-with-temp.bad.al`.
