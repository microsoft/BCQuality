---
bc-version: [all]
domain: appsource
keywords: [permission-set, super, appsource, setup, usage, tabledata, execute, submission]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AppSource permission sets must cover setup and usage without SUPER

## Description

An AppSource app must provide permission sets that let assigned users complete the app's setup and normal usage without `SUPER`. The requirement is about complete effective grants, not about naming the permission set after the app. A package can compile and install with missing tabledata or execute permissions, then fail only when Marketplace validation or a real non-SUPER user reaches the omitted path.

## Best Practice

Trace every setup page, normal page, report, codeunit, and tabledata operation exposed by the app and cover it through assignable role permission sets composed from focused non-assignable sets. Validate setup and representative workflows as a user assigned only those app roles. Grant the minimum required operations; completeness is not a reason to use wildcards.

See sample: `permission-sets-cover-setup-and-usage-without-super.good.al`.

## Anti Pattern

Shipping no permission set, omitting a tabledata or execute grant used by the app's own UI, or instructing users and validators to assign `SUPER` when setup fails. Do not flag a permission-set name that differs from the app name; no such naming requirement exists.

See sample: `permission-sets-cover-setup-and-usage-without-super.bad.al`.
