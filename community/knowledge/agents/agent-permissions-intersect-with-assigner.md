---
bc-version: [27..]
domain: agents
keywords: [permissions, assigner, intersection, user-card, least-privilege]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Agent permissions intersect the assigner's; agents cannot configure users

## Description

An agent is a user, but it cannot configure users or other agents, and it cannot open sensitive pages such as user cards or permission-set assignment. Effective rights are the intersection of the assigning user's permissions and the agent's permission sets. Granting the agent a wide set does not bypass the assigner's limits, and a wide assigner still cannot give the agent user-admin powers the platform forbids.

## Best Practice

Document that intersection. Give the agent only the table and page rights its tasks need. Do not add user-setup or permission-assignment pages to the agent profile or permission sets; those operations will fail by design.

See sample: [`agent-permissions-intersect-with-assigner.good.al`](agent-permissions-intersect-with-assigner.good.al).

## Anti Pattern

Permission sets or profiles that include User card, Permission Set Assignment, or agent-admin pages, or comments that the agent runs as SUPER regardless of who assigned it. Detection signal: default access controls or profile including user-administration objects.

See sample: [`agent-permissions-intersect-with-assigner.bad.al`](agent-permissions-intersect-with-assigner.bad.al).

## See also

`get-default-access-controls-least-privilege.md` covers the permission sets assigned when an agent instance is created.
