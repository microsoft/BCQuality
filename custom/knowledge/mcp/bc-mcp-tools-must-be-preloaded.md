---
rule: bc-mcp-tools-must-be-preloaded
title: BC MCP tool schemas must be pre-loaded at session start
category: mcp
severity: required
---

# BC MCP tool schemas must be pre-loaded at session start

## Rule

When the `bc-mcp.agent.md` agent is invoked, the very first action must be to load
the BC MCP tool schemas via `ToolSearch` — before producing any user-visible output.

```
ToolSearch query: select:mcp__businesscentral__bc_actions_search,mcp__businesscentral__bc_actions_invoke,mcp__businesscentral__bc_actions_describe
```

This call must complete before the agent responds to the user.

## Why

Claude Code loads MCP tool schemas lazily ("deferred"). If the first `ToolSearch` call
happens mid-task — after the user has already received a response — the user experiences
unexpected latency at the moment they expect an action, not setup.

Pre-loading at invocation time moves the cost to a predictable point (agent startup)
and eliminates mid-task delays entirely.

## What counts as a violation

- The agent issues any user-visible text or takes any BC action before calling `ToolSearch`
  to load the three `mcp__businesscentral__bc_actions_*` schemas.
- The agent assumes the schemas are already loaded from a previous session without verifying.

## Correct pattern

```
# bc-mcp.agent.md session start

1. ToolSearch: select:mcp__businesscentral__bc_actions_search,
               mcp__businesscentral__bc_actions_invoke,
               mcp__businesscentral__bc_actions_describe
2. [proceed with user request]
```

## Scope

Applies to every invocation of `bc-mcp.agent.md` in every CURABIS project that uses
the Business Central MCP bridge (`bc-mcp-bridge.js`).