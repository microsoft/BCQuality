---
bc-version: [all]
domain: events
keywords: [workflow, workflow-event, workflow-response, workflow-library, workflow-registration, upgrade, subscriber, onaddworkfloweventstolibrary]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Register custom workflow library entries through their extension points

## Description

Business Central rebuilds the workflow event, response, and table relation libraries during an upgrade. Custom entries added only during installation can initially appear in the workflow editor but disappear when those libraries are recreated. The compiler cannot tell that the registration will be lost.

## Best Practice

Register each custom workflow event, response, or table relation through the corresponding workflow library extension point, so the framework can recreate it when the library is rebuilt. For example, subscribe to `OnAddWorkflowEventsToLibrary` in `Workflow Event Handling` and call `AddEventToLibrary` for the custom event. Register only the entries the extension adds; an existing standard response does not need a new custom response.

See sample: [`register-workflow-libraries-through-extension-points.good.al`](register-workflow-libraries-through-extension-points.good.al).

## Anti Pattern

Adding a custom workflow library entry once from an install trigger without registering that same entry through the appropriate library extension point. The entry may work until an upgrade recreates the library, after which it is missing. Check the extension's other codeunits for a registration subscriber before reporting a missing registration; the subscriber need not be in the same file as the install trigger or the workflow handler.

Do not flag a custom workflow event merely for being custom, or require a custom response when the extension uses an existing standard response.

See sample: [`register-workflow-libraries-through-extension-points.bad.al`](register-workflow-libraries-through-extension-points.bad.al).

## References

- [Walkthrough: Implementing New Workflow Events and Responses](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-walkthrough-workflow-events-responses)
