---
bc-version: [27..]
domain: agents
keywords: [getdefaultprofile, profile, page-customization, populatedefaultprofile, role-center]
technologies: [al]
countries: [w1]
application-area: [all]
---

# The default agent profile must be an AL profile in the app

## Description

`IAgentFactory.GetDefaultProfile` assigns the Role Center and page customizations the agent UI-navigates. A profile built only in the client, or page personalization that was never exported, is absent after deploy. `Agent.PopulateDefaultProfile` still needs a profile ID that exists in the current module.

## Best Practice

Ship a `profile` object (and page customizations) in the app. In `GetDefaultProfile`, call `Agent.PopulateDefaultProfile` with that profile ID and `NavApp.GetCurrentModuleInfo`. Include UI-exported customizations as AL.

See sample: [`get-default-profile-lives-in-the-app.good.al`](get-default-profile-lives-in-the-app.good.al).

## Anti Pattern

Setting `TempAllProfile."Profile ID"` to a client-only profile, or skipping `GetDefaultProfile`. Detection signal: factory default profile ID with no matching `profile` object in the app.

See sample: [`get-default-profile-lives-in-the-app.bad.al`](get-default-profile-lives-in-the-app.bad.al).

## See also

`agent-profile-narrows-visible-ui.md` explains which UI the app-owned profile should expose.
