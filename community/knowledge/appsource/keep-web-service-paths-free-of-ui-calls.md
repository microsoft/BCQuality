---
bc-version: [all]
domain: appsource
keywords: [web-service, serviceenabled, guiallowed, message, confirm, strmenu]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep web-service paths free of UI calls

## Description

Pages and codeunits exposed as web services run without an interactive client. Calls that require a UI callback, including `Message`, `Confirm`, `StrMenu`, and modal pages, can terminate the service request instead of completing the operation.

## Best Practice

Keep service entry points and every procedure they call free of interactive UI. Return data through the service contract and report validation failures with service-safe error handling. When a procedure is shared with an interactive client, guard UI-only behavior with `GuiAllowed` while preserving the underlying operation.

See sample: `keep-web-service-paths-free-of-ui-calls.good.al`.

## Anti Pattern

A web-service-exposed page or codeunit calls an interactive UI method directly or indirectly. Detection signals include `Message`, `Confirm`, `StrMenu`, `Page.RunModal`, and confirmation-dialog pages on a service call path. Do not flag a controlled `Error` solely because it returns a service fault.

See sample: `keep-web-service-paths-free-of-ui-calls.bad.al`.