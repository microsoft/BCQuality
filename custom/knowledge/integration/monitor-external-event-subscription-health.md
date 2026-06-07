---
bc-version: [all]
domain: integration
keywords: [subscription-health, monitor, external-business-event, silent-drop, alert, job-queue, telemetry]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Monitor external event subscription health

## Description

Business Central removes an external business event subscription when the subscriber's notification endpoint returns anything other than 408, 429, or a 5xx response. A 404 because the consumer redeployed to a new URL, a 401 because a token expired, a 400 because a proxy mangled the request: any of these tells the platform the endpoint is permanently unable to accept the notification, so it stops trying and drops the subscription. This is reasonable platform behaviour, but there is no built-in alert when it happens. The subscription simply disappears and notifications stop flowing.

The reason this is dangerous is that a dropped subscription is indistinguishable from a quiet feed. If nothing has happened to raise the event lately, no notifications would arrive anyway, so the absence of traffic looks normal. The gap is typically discovered only when someone downstream asks why they stopped receiving events, by which point the integration has been silently broken for hours or days and there may be a backlog of business activity that was never communicated. Because the platform will not tell you, the only way to catch a drop is to check for it actively and on a schedule.

## Best Practice

Run a monitor job on a schedule (a Job Queue entry, for example hourly) that lists the current external event subscriptions from the `externaleventsubscriptions` endpoint and compares them against the set the integration expects to exist. Keep the expected set in a small configuration table so that registering an integration also registers its monitoring expectation, and the two never drift apart. The mechanism is the diff: for every expected subscription that is absent from the live list, raise an operational alert and emit telemetry carrying the event name and notification URL, so operations can re-register it before the gap grows and can see, from the telemetry timeline, roughly when delivery stopped. Treat a missing subscription as an incident, not a warning to be filtered out. See `monitor-external-event-subscription-health.good.al`.

The trade-off is one scheduled read of the subscription list per interval plus a small table of expectations, which is a negligible cost against the alternative of a multi-day silent outage discovered by a downstream complaint.

## See also

- `prefer-business-events-over-handwritten-retry-loops.md`
- `version-business-events-and-keep-payloads-stable.md`
- `propagate-a-correlation-id-across-every-hop.md`
