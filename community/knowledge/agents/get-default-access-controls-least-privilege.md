---
bc-version: [27..]
domain: agents
keywords: [getdefaultaccesscontrols, access-control-buffer, permissionset, least-privilege, iagentfactory]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Default agent permission sets must exist in AL and stay least privilege

## Description

`IAgentFactory.GetDefaultAccessControls` fills a temporary `Access Control Buffer` used when an instance is created. Permission sets that exist only as user-created sets in a sandbox are missing in the next environment. Granting `D365 BUS FULL ACCESS` or SUPER gives the agent a user-sized blast radius. Effective rights are still the intersection with the assigning user's permissions.

## Best Practice

Insert only the permission sets the agent needs. For an AL `permissionset` object, use `Scope::System` and the ID of the app that defines it. Recreate permission sets that exist only as user-defined configuration in Business Central as AL objects first. Prefer a dedicated permission set over a full-user role.

See sample: [`get-default-access-controls-least-privilege.good.al`](get-default-access-controls-least-privilege.good.al).

## Anti Pattern

Empty `GetDefaultAccessControls`, or inserting `SUPER` / `D365 BUS FULL ACCESS` because it made the demo work. Detection signal: Role ID on the default buffer that is a full-user role, or a set that is not in the app.

See sample: [`get-default-access-controls-least-privilege.bad.al`](get-default-access-controls-least-privilege.bad.al).

## See also

`agent-permissions-intersect-with-assigner.md` explains the platform limits that still apply after default access controls are assigned.
