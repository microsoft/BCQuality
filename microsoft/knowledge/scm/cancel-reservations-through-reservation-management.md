---
bc-version: [all]
domain: scm
keywords: [reservation-entry, cancelreservation, reservation-engine-mgt, reservation-status, order-tracking, disallow-cancellation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Cancel reservations through reservation management

## Description

Persistent `"Reservation Entry"` rows are not disposable allocation markers. Reservation and Tracking links use an entry-number pair with opposite `Positive` values, while Surplus and Prospect entries can legitimately be unpaired. Cancelling a binding reservation must handle its counterpart and any remaining item tracking or order tracking, not just remove a row.

## Best Practice

Explicit cancellation of an existing binding reservation uses `"Reservation Engine Mgt.".CancelReservation`. It checks the reservation status and `"Disallow Cancellation"`, handles the counterpart, and preserves or retracks the remaining source quantities as appropriate. Source-line quantity changes have their own source-specific reservation management path.

Not every Reservation Entry has a partner or identical lot/serial values on both sides: Surplus/Prospect entries and supported late-binding scenarios have different relationships. Temporary buffers, engine-owned updates, and supported publisher metadata are not independent cancellation. Cancelling a reservation is also different from intentionally removing an item-tracking assignment.

The samples retrieve the negative side of a persistent sales-line reservation and cancel only the binding. They do not delete the sales line or remove its tracking specifications.

See sample: [`cancel-reservations-through-reservation-management.good.al`](cancel-reservations-through-reservation-management.good.al).

## Anti Pattern

`Delete(true)`, `DeleteAll`, or a status/source rewrite on persistent `"Reservation Entry"` records does not perform binding-reservation cancellation. Even deleting both sides can discard tracking that should survive and omit retracking.

Normal processing of temporary Prospect/Surplus buffers is outside that cancellation workflow, and an unpaired row is not intrinsically an orphan.

See sample: [`cancel-reservations-through-reservation-management.bad.al`](cancel-reservations-through-reservation-management.bad.al).

## References

- [Reservation, order tracking, and action messaging](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-reservation-order-tracking-and-action-messaging)
- [Item tracking and reservations](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-item-tracking-and-reservations)
- [BaseApp reservation cancellation](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Tracking/ReservationEngineMgt.Codeunit.al#L51-L90)
