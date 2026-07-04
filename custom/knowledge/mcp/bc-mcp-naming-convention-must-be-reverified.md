---
bc-version: [all]
domain: mcp
keywords: [mcp, tools, naming, bc-actions-search, verification, bc]
technologies: [al]
countries: [w1]
application-area: [all]
---
﻿---
rule: bc-mcp-naming-convention-must-be-reverified
title: BC MCP action-naming conventions must be reverified, not assumed
category: mcp
severity: required
---

# BC MCP action-naming conventions must be reverified, not assumed

## Description

Documentation describing the `businesscentral` MCP server's action-naming pattern
(`List_<Entity>_PAG<id>`, `Modify_<Entity>_PAG<id>`, `Create_<Entity>_PAG<id>`) must
state it as an **expectation to reverify per call with `bc_actions_search`**, never
as a guaranteed fact. The verb prefix is not uniform across every entity.

## Why

The `bc-mcp.agent.md` template asserted the modify-action name as `ListUpdate<entity>
_PAG<id>` as fact. The real action returned by `bc_actions_search` for updating
`projectRepositories` was `Modify_ProjectRepository_PAG6102904` - singular entity
name, `Modify_` prefix, not `ListUpdate`. An agent that trusts the documented pattern
without verifying hunts for a tool that does not exist, wasting a round trip exactly
like the one this rule replaces.

Meanwhile `Create_NewTask_PAG6102905` (used elsewhere in the same template) DOES
match the documented `Create_<entity>_PAG<id>` shape - so the pattern is a reasonable
starting guess, just not one to assert as fact without confirming it that call.

## What counts as a violation

- A BC MCP agent template states an action name or naming pattern as guaranteed,
  without an instruction to confirm it via `bc_actions_search` before relying on it.
- An agent session assumes an action name from documentation and calls
  `bc_actions_invoke` with it directly, without first getting the exact name from
  `bc_actions_search` or `bc_actions_describe`.

## Correct pattern

    1. bc_actions_search(SearchText: "<entity keywords>", SearchMode: keyword,
       ActionType: [List|Modify|Create])
    2. Use the exact name returned - do not construct it from a remembered pattern.
    3. bc_actions_describe on that exact name before invoking it.

Documentation may state the *expected* shape as a memory aid, but must mark it
explicitly as unverified per-entity, e.g.: "expect `Modify_<Entity>_PAG<id>` -
reverify, do not assume."

## Scope

Applies to every BC MCP agent template and every session that calls
`bc_actions_search` / `bc_actions_describe` / `bc_actions_invoke` in any CURABIS
project.
