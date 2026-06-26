---
rule: mcp-tool-invocation-must-be-documented
title: MCP tool documentation must include the invocation model
category: mcp
severity: warning
version: 1
---

# MCP tool documentation must include the invocation model

## Rule

An MCP agent's documentation must describe the actual invocation model — including
whether a tool call is direct or wrapped via a generic action tool with a parameter value.

## Why

MCP servers may expose a small set of generic tools (e.g. `bc_actions_invoke`) that
accept an action name as a parameter, rather than exposing each action as a named tool.

When documentation lists action names (e.g. `List_Projects_PAG6102901`) without
specifying that they are parameter values — not direct tool names — agents attempt to
call them directly, fail with `InputValidationError`, and spend time diagnosing a
documentation gap rather than a code error.

## What to document

For each MCP capability, the documentation must state:

- The actual tool name to call (e.g. `bc_actions_invoke`)
- How to discover available actions (e.g. `bc_actions_search`)
- How to inspect an action's schema before invoking (e.g. `bc_actions_describe`)
- The parameter that carries the action name (e.g. `ActionName`)

## Example — correct

> Tools are called via `bc_actions_invoke` with `ActionName` as the parameter.
> Use `bc_actions_search` to discover available actions.
> Use `bc_actions_describe` to inspect a specific action's schema before calling.

## Example — incorrect

> Call `List_Projects_PAG6102901` to list active projects.

This implies a direct tool call. If `List_Projects_PAG6102901` is an `ActionName`
value passed to `bc_actions_invoke`, this documentation will cause agents to fail.

## Applies to

Any CURABIS agent documentation that describes how to use an MCP tool.