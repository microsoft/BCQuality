---
bc-version: [20..]
domain: privacy
keywords: [error, message, confirm, notification, telemetry, logging, ui-dialog]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Error dialogs emit Error method trace telemetry

## Description

When `Error` displays a dialog, Business Central emits the RT0030 Error method trace telemetry signal. `Message`, `Confirm`, and `Notification` do not emit that Error method trace signal. For RT0030, the actual AL error string is included only when the first `Error` argument is a `Label` or `TextConst`; other first-argument types produce generic guidance instead of the dynamic string.

## Best Practice

Use a `Label` or `TextConst` as the direct first argument to `Error` so telemetry contains a stable, classified message. Review user-facing substitution values for UI appropriateness. Do not treat `Message`, `Confirm`, or `Notification` content as though it were automatically copied into RT0030.

## Anti Pattern

Claiming that every rendered `Error` string is written verbatim to telemetry, or that `Message`, `Confirm`, and `Notification` automatically feed the Error method trace. Both overstate the platform behavior.
