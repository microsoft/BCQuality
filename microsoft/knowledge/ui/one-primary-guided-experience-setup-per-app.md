---
bc-version: [21..]
domain: ui
keywords: [guided-experience, primary-setup, extension-management, set-up-this-app, onboarding, upgrade]
technologies: [al]
countries: [w1]
application-area: [all]
---

# An app has at most one primary setup object in Guided Experience

## Description

An extension tells Business Central which setup objects it brings by adding them as guided experience items through codeunit `Guided Experience`. One of them can be marked as the app's primary setup. The **Extension Management** page then offers a **Set up this app** action that opens that object, which is how a user finds the setup after installing the app. An app can register as many setup objects as it needs, but only one may be primary.

The platform does not enforce that limit. Keeping a single primary setup is the publisher's responsibility, including across versions: if a later version makes a different object the primary one, upgrade code has to remove the designation from the old object before adding it to the new one.

Setup that lives on a standard page the app extends is a separate concern; see [`expose-base-page-setup-through-a-codeunit.md`](expose-base-page-setup-through-a-codeunit.md).

## Best Practice

Register every setup object the app brings, and mark exactly one as primary. When a release changes which object is primary, pair the registration change with upgrade code that clears the previous primary designation. Register nothing when the app needs no setup before use.

## Anti Pattern

Marking two setup objects as primary, or switching the primary object in a new version with no upgrade step, so that upgraded tenants hold two. Nothing prevents it, and the registration code compiles in both cases; the documentation makes the publisher responsible for avoiding it.
## References

[Onboard users to your app](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/administration/onboarding-onboard-users-to-your-app). The primary-setup parameter is available from Business Central 2022 release wave 2.
