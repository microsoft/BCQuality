---
bc-version: [all]
domain: upgrade
keywords: [error-handling, telemetry, session-logmessage, blocking, graceful]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Log telemetry; do not raise errors that block the upgrade

## Description

When upgrade code encounters unexpected data — a record it expected to find, a relationship it assumed to be intact — the response is to log telemetry and continue, not to raise an error. A runtime error inside an upgrade codeunit aborts the upgrade for the company or database, leaving the customer stuck on the old version. Customers should not be blocked from upgrading because of a data inconsistency that an upgrade routine could not have anticipated.

## Best Practice

When an upgrade procedure detects something missing, call `Session.LogMessage` with a stable event ID, classify the message verbosity (typically `Warning`), and `exit` the procedure so the rest of the upgrade can proceed. The platform telemetry then surfaces the situation to the partner without breaking the customer.

See sample: [`do-not-block-upgrade-on-data-errors.good.al`](do-not-block-upgrade-on-data-errors.good.al).

## Anti Pattern

Calling `Record.Get(Key)` (or any other erroring API) and letting the error propagate out of the upgrade trigger. The first tenant with imperfect data fails to upgrade, and the failure surfaces as a hard upgrade error rather than as a telemetry signal.

See sample: [`do-not-block-upgrade-on-data-errors.bad.al`](do-not-block-upgrade-on-data-errors.bad.al).
