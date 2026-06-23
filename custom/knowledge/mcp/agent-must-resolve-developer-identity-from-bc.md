---
rule-id: CURABIS-MCP-007
title: Agent must resolve developer identity from BC
category: mcp
severity: warning
applies-to: [agent-files, bc-mcp]
bc-version: [all]
---

# Agent must resolve developer identity from BC

## Rule

Agent files must not contain static employee-to-code mappings.
Developer identity must always be resolved at runtime from the BC users tool (PAG6102903).

## Rationale

Employee data is owned by the company, not by any individual project. A static mapping
in a project-level agent file duplicates company data and will silently drift on every
personnel change -- a new hire is missing, a former employee remains listed.

The BC users page (PAG6102903) is the single source of truth for employeeCode + name
+ userId mapping. Resolving identity at runtime ensures attribution is always correct
without any maintenance overhead on the project side.

## What this prevents

- Incorrect task attribution after an employee leaves or changes role
- N agent files requiring manual update for a single personnel change
- Silent drift where an agent signs comments with the wrong name

## Correct pattern

In bc-mcp agent: always resolve at runtime.
git config user.email -> look up via users tool (PAG6102903) -> employeeCode + name

## Incorrect pattern

Static employee tables in agent files are forbidden:

  | MID | Michael Dieringer | Developer  |
  | LIT | Linh              | Consultant |

## Exceptions

None. If the users tool is temporarily unavailable, say so and stop -- do not fall back
to a hardcoded table.