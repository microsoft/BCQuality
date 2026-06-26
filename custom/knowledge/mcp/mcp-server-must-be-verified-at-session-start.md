---
rule: mcp-server-must-be-verified-at-session-start
title: MCP server availability must be verified at session start
category: mcp
severity: error
version: 1
---

# MCP server availability must be verified at session start

## Rule

When an MCP server is configured in `.mcp.json`, the agent must at session start verify
that the server's tools appear in the active deferred-tools list. If they are missing,
the agent must name the missing server and stop MCP-dependent work until the problem
is resolved or a workaround is chosen and declared.

## Why

MCP servers are started by the Claude Code harness when a session initializes. If a
server fails to start — due to a startup error, a configuration problem, or a timing
issue — its tools do not appear in the deferred-tools list. The harness does not report
this failure explicitly. An agent that proceeds as if the tools are available will
spend the session diagnosing what appears to be a tool-call error but is actually a
server-startup failure.

Early detection saves the entire session from misdirected debugging.

## How to verify

At session start, before using any MCP-dependent tool:

1. Note which servers are configured in `.mcp.json`.
2. Check whether each server's tools appear in the deferred-tools list
   (visible in the `system-reminder` block at session start).
3. If a server's tools are absent: report it immediately.

> "WARNING: MCP server '[name]' is configured in .mcp.json but its tools are not
> registered in this session. MCP-dependent work for this server is paused.
> Likely causes: startup error, missing config, or harness timeout. Diagnose before
> continuing."

4. Offer a diagnostic path: verify the server command runs without error,
   check configuration files, check for BOM or encoding issues in the server script.

## What NOT to do

- Do not proceed with MCP-dependent tasks assuming the tools will appear later.
- Do not silently skip MCP steps without reporting why.
- Do not attempt to call MCP tools whose server is not confirmed active.
- Do not diagnose the absence as a tool-call error — diagnose it as a startup failure.

## Applies to

All CURABIS projects that configure MCP servers in `.mcp.json`.