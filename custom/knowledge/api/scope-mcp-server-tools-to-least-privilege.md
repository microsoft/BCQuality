---
bc-version: [all]
domain: api
keywords: [mcp, mcp-server, least-privilege, allow-create, unblock-edit-tools, read-only, configuration]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Scope MCP server tools to least privilege

## Description

Business Central's product MCP server exposes selected API pages as tools to outside AI clients. Each configuration controls which API pages an agent sees and what it may do with them: read, create, modify, delete, and bound actions. Because every operation runs as the signed-in user's identity and lands in the audit trail under that name, the tool surface is a privilege surface, and the agent inherits exactly the permission set of whoever signed it in. An agent can never do less than its configuration allows but never more than the user can do; the configuration is the ceiling and the user's permissions are the floor.

The mechanism has two gates. A newly added page is read-only by default, and turning on any write requires both the configuration-level `Unblock Edit Tools` master switch and the specific per-page create, modify, or delete permission. Least privilege means leaving both gates shut except on the exact pages and operations the agent's workflow actually exercises, so the published tool surface is the smallest set that still lets the workflow succeed.

## Best Practice

Create one configuration per intended audience (for example a sales configuration and a warehouse configuration) rather than a single broad configuration shared by every client, so each audience's surface can be reasoned about and revoked on its own. Leave every API page read-only by default and enable create, modify, or delete one entity at a time, only when the agent's workflow requires it, setting both `Unblock Edit Tools` and the per-page permission deliberately rather than as a blanket flip. Document each configuration's audience and intended use, and review quarterly who has access and what is enabled, pruning any write that the workflow no longer exercises. Turn on Dynamic Tool Mode for any configuration that grows large so the surface stays within client tool caps without widening permissions.

## Anti Pattern

Building one mega-configuration that exposes many entities with write enabled "just in case", or flipping `Unblock Edit Tools` on at the configuration level with broad per-page create, modify, and delete permissions the agent never uses. Because the agent acts as the signed-in user, an over-broad surface lets a prompt-injected or mistaken agent modify or delete data it had no business touching, all under that user's identity in the audit log. The signal to look for: an MCP configuration with write operations enabled on pages the documented agent workflow does not require, or a single configuration serving multiple unrelated audiences.

## See also

- `expose-bc-entities-as-api-pages-for-external-agents.md`
