---
bc-version: [27..]
domain: agents
keywords: [permissions, assigner, intersection, task-scheduler, user-intervention, company-scope, user-card, least-privilege]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Agent task permissions intersect the scheduling user's permissions

## Description

An agent task runs with the intersection of the agent's permissions and those of the user who schedules the task, not automatically those of the agent's creator or the administrator who assigned its permission sets. An operation must be permitted on both sides; permissions are not combined as a union. After a user responds to an intervention request, the task continues using that responding user's permission context, which can differ from the original task creator's. For a task in a particular company, the intersection considers permissions assigned for that company or for all companies.

## Best Practice

Give the agent only the table and page rights its tasks need, and verify that the scheduling user has the required rights in the task's company. If the agent can modify sales headers but the user can only read them, the task cannot modify them; if the user can modify customers but the agent can only read them, the task cannot modify customers either. Test both directions with restricted users, including continuation after an intervention answered by a different user; do not validate only with SUPER.

When diagnosing an access failure, check both permission contexts and company scope rather than widening only the agent's permission set. A permission set designed for a shared agent need not be a subset of every potential scheduling user's permissions: the platform applies the intersection per task. A profile controls the visible UI, not a grant of missing permissions. Do not add user-setup or permission-assignment pages to the agent profile or permission sets; agents cannot configure users or other agents, and platform restrictions still apply even when both permission sets are broad.

See sample: [`agent-permissions-intersect-with-assigner.good.al`](agent-permissions-intersect-with-assigner.good.al).

## Anti Pattern

Assuming the agent inherits its creator's or administrator's rights, treating user and agent grants as a union, or adding SUPER to the agent to bypass a scheduling user's missing rights. Also avoid assuming that the original task creator remains the permission context after another user answers an intervention, or that a grant in one company applies in another.

Detection signals include comments promising operations that only one side permits, or default access controls and profiles exposing User Card, Permission Set Assignment, or agent-administration pages. The absence of a hand-written intersection check in AL is not itself a defect; enforcement is provided by the platform.

See sample: [`agent-permissions-intersect-with-assigner.bad.al`](agent-permissions-intersect-with-assigner.bad.al).

## See also

- [Default agent access controls](get-default-access-controls-least-privilege.md) covers the permission sets assigned when an agent instance is created.
- [Agent-specific profiles](agent-profile-narrows-visible-ui.md) covers reducing visible UI independently of permission grants.

## References

- [Microsoft Learn: Agent permissions - effective permissions and per-company access controls](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/ai/ai-development-toolkit-permissions#access-controls---effective-permissions-of-an-agent)
- [Microsoft Learn: Set up agent permissions and profiles](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/ai/ai-development-toolkit-permissions-profiles#effective-permissions)
