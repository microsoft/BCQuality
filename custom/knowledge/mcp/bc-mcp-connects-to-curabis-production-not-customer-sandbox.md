---
bc-version: [all]
domain: mcp
keywords: [businesscentral, mcp, production, sandbox, bc-mcp-bridge, psa, invoicing]
technologies: [al, mcp]
countries: [w1]
application-area: [all]
---

# BC MCP Connects to CURABIS Production, Never Confuse It With a Customer Sandbox

## Description

The `businesscentral` MCP server (`bc-mcp-bridge.js`) connects to CURABIS's
own Project Management 365 Business Central environment — the system
CURABIS runs its actual time registration, invoicing, and project tracking
through. It is production data, full stop, on every project, for every
developer.

This is a categorically different system from the **customer's** BC
sandbox/test environments that AL development and automated domain tests
run against. Both may be open in the same session, both may be casually
called "BC," but they are not the same system and must never be treated as
interchangeable in stakes or disposability.

## Rule

An agent must never describe, treat, or retry a `businesscentral` MCP call
as if it were hitting disposable test data. Reads remain safe to perform
unprompted (see `bc-mcp-scope-tasks-to-repository` and sibling rules) — this
rule is about STAKES, not permission: don't casually re-fire a slow or
failed BC MCP call without first naming that it targets production, and
never suggest "let's just try it again" the way one might for a sandbox
call.

## Why

CURABIS runs its own invoicing and time registration through this system.
An agent that treats it as "just another read-only API, safe to poll" has
collapsed two different properties into one: "safe to read" (true) and
"low-stakes / disposable" (false). Conflating them leads to careless
behavior — repeated polling, casual retries, treating slowness as a
shrug-worthy glitch — against a system real invoices depend on.

## Anti-Pattern

    Developer: "That BC MCP call is slow."
    Agent: "Want me to just retry it?"

No acknowledgment that "BC" here means CURABIS's own production PM365
tenant, not the customer sandbox the rest of the session's AL work is
otherwise happening against.

## Compliant

    Developer: "That BC MCP call is slow."
    Agent: "That's CURABIS's own production PM365 environment — I won't
    just retry it casually. Want me to try once more, or hold off until we
    know why it was slow?"

## Scope

Applies to every CURABIS project with the `businesscentral` MCP server
configured. The target environment is identical across all of them
(CURABIS's own PM365 tenant), regardless of which customer's codebase the
session is otherwise working in.
