---
bc-version: [all]
domain: ui
keywords: [control-add-in, packaged-resource, ajax, withcredentials, xhrfields, jquery]
technologies: [javascript]
countries: [w1]
application-area: [all]
---

# Load packaged control add-in resources with credentialed AJAX

## Description

JavaScript in a Business Central control add-in can load a static resource from its extension package with AJAX, but the request needs the Business Central context and cookies. Set `xhrFields.withCredentials = true`; shorthand calls such as `$.get` omit that setting and can work during development yet fail in production.

## Best Practice

Use an AJAX form that explicitly enables `withCredentials` whenever a control add-in requests a packaged static resource. Keep this rule scoped to resources served from the add-in package; it is not generic advice to attach credentials to arbitrary external requests.

See sample: `control-addin-package-resource-ajax-needs-withcredentials.good.js`.

## Anti Pattern

Using `$.get(url)` or an `XMLHttpRequest` without `withCredentials = true` to retrieve package content. The request can lack the context and cookies required by the Business Central service.

See sample: `control-addin-package-resource-ajax-needs-withcredentials.bad.js`.

## Source

[Control add-in object: Loading static resources using AJAX requests](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-control-addin-object#loading-static-resources-using-ajax-requests).
