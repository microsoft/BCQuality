---
bc-version: [28..]
domain: agents
keywords: [showcancreateagent, agent-discovery, agent-create, administrator, agent-configuration-rights]
technologies: [al]
countries: [w1]
application-area: [all]
---

# ShowCanCreateAgent only hides UI create, not programmatic create

## Description

`IAgentFactory.ShowCanCreateAgent` controls whether the type appears in the in-client create UI. Returning false does not stop `Agent.Create` from AL. From 28.1, non-admins can discover extension agents unless this method (and agent configuration rights) restrict them. Models treat a false return as a hard create lock.

## Best Practice

Use `ShowCanCreateAgent` to decide discovery. If only agent administrators should see the type, return `Agent System Permissions.CurrentUserHasCanManageAllAgentsPermission`. Enforce extra policy inside your own create API. Never assume UI hiding blocks code.

See sample: [`show-can-create-agent-does-not-block-code-create.good.al`](show-can-create-agent-does-not-block-code-create.good.al).

## Anti Pattern

Returning `exit(false)` from `ShowCanCreateAgent` and then documenting that instances cannot be created, while page actions or other apps still call `Agent.Create`. Detection signal: `ShowCanCreateAgent` always false with no matching guard on programmatic create.

See sample: [`show-can-create-agent-does-not-block-code-create.bad.al`](show-can-create-agent-does-not-block-code-create.bad.al).
