---
bc-version: [all]
domain: appsource
keywords: [onbeforecompanyopen, onaftercompanyopen, company-open, event-subscriber, login]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not subscribe to company-open events

## Description

AppSource extensions must not subscribe to `OnBeforeCompanyOpen` or `OnAfterCompanyOpen`. These events run on the sign-in path, where an error can prevent access and even small amounts of work affect every company open. Move initialization to installation, upgrade, new-company initialization, or the first use of the feature instead.

## Best Practice

Initialize app data from install or upgrade code when its lifecycle belongs there. For work that can wait, perform an idempotent check when the feature is first used or schedule background work. Use `OnCompanyInitialize` only for data that must be created for a new company.

See sample: `do-not-subscribe-to-company-open-events.good.al`.

## Anti Pattern

An event subscriber bound to `OnBeforeCompanyOpen` or `OnAfterCompanyOpen`, even when its current body appears lightweight. Detection signal: either company-open event name in an `EventSubscriber` attribute.

See sample: `do-not-subscribe-to-company-open-events.bad.al`.

## See also

`community/knowledge/performance/oncompanyopen-subscribers-must-not-do-io.md` covers I/O and other expensive work on adjacent session-open events.