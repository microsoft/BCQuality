---
bc-version: [all]
domain: api
keywords: [api-page, external-agent, mcp, copilot-studio, entity, api-version, top-level-page]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Expose BC entities as API pages for external agents

## Description

An external agent (Copilot Studio, Claude, ChatGPT, or a custom agent) can only reach Business Central data and operations that are modelled as API pages. The agent never sees the table directly: it sees the API pages the tenant chooses to expose, each becoming a tool with a name derived from its entity and operations. Deciding which entities and which operations are reachable is therefore a design step, not an afterthought, because the published surface is simultaneously the agent's capability list and its blast radius. Stable entity names and explicit API versions matter because they are the contract the agent's tools are built on, and a rename or version bump silently breaks every tool the agent already discovered against the old names.

The mechanism is the page's metadata. A top-level page with `PageType = API` and a fixed `APIPublisher`, `APIGroup`, and `APIVersion` is addressable at a stable route, and its `EntityName` and `EntitySetName` become the singular and plural tool names the agent binds to. Those five properties are the contract. The fields in the repeater are the schema the agent reasons over, so they should be named for the agent's domain vocabulary, not for the underlying table's field captions.

## Best Practice

For each entity an external agent must reach, define a top-level API page with a deliberate `EntityName`, `EntitySetName`, `APIPublisher`, `APIGroup`, and `APIVersion`, and treat those names and the version as a frozen contract: add a new `APIVersion` for breaking changes instead of mutating the existing one, so old tools keep resolving. Model only the operations the agent's workflow needs, setting `Editable = false` and `InsertAllowed`, `ModifyAllowed`, and `DeleteAllowed` to false when the agent only reads, so a read tool can never mutate. Keep the field set narrow and named in the agent's vocabulary so tool discovery is predictable. Choose entities and operations to match one specific agent audience rather than publishing a single broad surface for every possible client. See `expose-bc-entities-as-api-pages-for-external-agents.good.al` for a stable read-shaped API page and `expose-bc-entities-as-api-pages-for-external-agents.bad.al` for the unstable, over-broad form.

## Anti Pattern

Pointing an external agent at a `ListPart` or `CardPart` page, or at a non-API page, and expecting it to surface as a tool: only top-level API pages are picked up, so the entity is silently unreachable. The fix is a top-level API page wrapping the same source table. Other smells: renaming an exposed entity or bumping its `APIVersion` in place, which breaks the agent's existing tools; or exposing a sprawling set of entities and write operations the agent does not use. The detection signal: an external-agent integration that depends on a part-subtype API page, an API page whose `EntityName` or `APIVersion` is parameterised or computed rather than a fixed literal, or a read-only agent pointed at a page that leaves `ModifyAllowed` and `DeleteAllowed` at their permissive defaults.

## See also

- `scope-mcp-server-tools-to-least-privilege.md`
