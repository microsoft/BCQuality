---
bc-version: [18..]
domain: ui
keywords: [assisted-setup, guided-experience, onregisterassistedsetup, insertassistedsetup, wizard, onboarding, registration]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Register an assisted setup guide on every `OnRegisterAssistedSetup` event

## Description

The **Assisted Setup** page lists the guides that are registered as guided experience items. An extension registers its guide by subscribing to the `OnRegisterAssistedSetup` event of codeunit `Guided Experience` and calling `InsertAssistedSetup` from the subscriber. The registered items live in an internal System Application table, so the codeunit is the only supported way to add one.

The call is meant to run every time the event is raised, not once. Calling `InsertAssistedSetup` on each registration event lets the framework refresh the registration and its translations. A registration that happens only once keeps whatever title and description were stored at that moment, including the language they were stored in.

## Best Practice

Put the `InsertAssistedSetup` call in an `OnRegisterAssistedSetup` subscriber and let it run unconditionally. Pass the title, short title, and description as labels so they are translatable, and pass the wizard page as the object to run.

See sample: [`register-assisted-setup-on-every-registration-event.good.al`](register-assisted-setup-on-every-registration-event.good.al).

## Anti Pattern

Registering the guide once from install code, or wrapping the call in a check that skips it when the item already exists. Both treat registration as one-time data seeding. The entry appears, so the defect passes a quick test, but later changes to the title or description, and translations added afterwards, do not reach the stored item.

Do not report the unconditional call in the event subscriber as a redundant or repeated insert; repeating it is the documented pattern.

See sample: [`register-assisted-setup-on-every-registration-event.bad.al`](register-assisted-setup-on-every-registration-event.bad.al).

## References

[Designing assisted setup guides: Add to the Assisted Setup page](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-designing-navigate-pages#add-to-the-assisted-setup-page) and [Onboard users to your app](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/administration/onboarding-onboard-users-to-your-app).
