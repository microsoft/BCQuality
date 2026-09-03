---
bc-version: [all]
domain: appsource
keywords: [datetime, time-zone, utc, currentdatetime, locale, regional-settings]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not hard-code time-zone offsets

## Description

AppSource extensions run for users and services in many time zones. Adding a fixed offset to a `DateTime` assumes one locale, ignores daylight-saving transitions, and changes an absolute timestamp into an incorrect value for other regions.

## Best Practice

Store and compare `DateTime` values without a manually applied regional offset. Business Central stores `DateTime` values in UTC and presents them according to the client time zone. Keep service contracts time-zone explicit and perform a conversion only when the business requirement identifies a particular zone.

See sample: `do-not-hard-code-time-zone-offsets.good.al`.

## Anti Pattern

Adding or subtracting a fixed duration solely to convert `CurrentDateTime` or another timestamp to an assumed local time. Detection signals include fixed hour-sized millisecond values near `DateTime` assignments and comments naming a specific time zone; confirm the duration is an offset rather than a legitimate deadline or schedule interval.

See sample: `do-not-hard-code-time-zone-offsets.bad.al`.