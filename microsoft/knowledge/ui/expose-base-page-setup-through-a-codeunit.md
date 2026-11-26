---
bc-version: [18..]
domain: ui
keywords: [guided-experience, setup, base-page, page-extension, codeunit, extension-management, onboarding]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Expose setup that lives on a base page through a codeunit

## Description

Guided experience items carry the ID of the extension that registered them, which is how Business Central lists the setup an app brings and runs it from **Extension Management**. That breaks down when an app's setup is not a new page but extra fields on a standard page it extends, such as **Sales & Receivables Setup**. The standard page cannot be registered as the app's own item: it is already registered and owned by the base application. Adding it to a checklist uses the base application's title and description, and nothing tells the user that this page holds setup for the app.

The documented solution is a small codeunit in the extension that runs the standard page. The codeunit is an object the app owns, so it can be registered as a guided experience item with the app's own title and description.

## Best Practice

When the setup an app needs is on a base page, add a codeunit whose only job is to open that page, and register the codeunit as the guided experience item. Give it a title and description that say what the user sets up for this app.

Keep this for setup that really is on a base page. A setup page the app defines itself is registered directly.

## Anti Pattern

Registering the base application page directly as the app's setup item to surface the extension's fields, or registering nothing and relying on the user to find the added fields. In the first case the item belongs to the base application and keeps its texts; in the second the app has no setup entry at all.

Do not report the wrapper codeunit as needless indirection because it contains a single `Page.Run` call. The indirection is what makes the item belong to the app.

## References

[Onboard users to your app: Setup that doesn't belong to your app](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/administration/onboarding-onboard-users-to-your-app#setup-that-doesn't-belong-to-your-app).
