---
bc-version: [27..]
domain: agents
keywords: [profile, page-customization, hidden-actions, tooltip, role-center]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Give the agent a dedicated profile that hides unrelated UI

## Description

The agent only sees what its profile shows. Extra actions, views, and Role Center tiles become extra tools and extra tokens. Accuracy and cost both get worse as the UI widens. A human Order Processor profile is usually far too broad. Tooltips on the remaining actions are part of the tool description.

## Best Practice

Ship an agent-specific profile and page customizations: hide unrelated actions, keep descriptive tooltips, add Role Center links to the few pages the agent should open. Prefer fewer navigation hops.

See sample: [`agent-profile-narrows-visible-ui.good.al`](agent-profile-narrows-visible-ui.good.al).

## Anti Pattern

Assigning `BUSINESS MANAGER` or `ORDER PROCESSOR` as `GetDefaultProfile` so the agent can do anything. Detection signal: default profile equal to a full-user role with no agent page customizations.

See sample: [`agent-profile-narrows-visible-ui.bad.al`](agent-profile-narrows-visible-ui.bad.al).

## See also

`get-default-profile-lives-in-the-app.md` covers packaging and assigning the profile that this rule narrows.
