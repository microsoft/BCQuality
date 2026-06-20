# CURABIS MCP: Agents Must Not Write Business Process Status Fields

## Core Principle

MCP agents must only write developer-managed tracking fields — never fields that drive business process workflows such as invoicing, approval, or time registration. Writing a business status field from an agent can block downstream operations for users working in Business Central.

## The Distinction

| Field type | Examples | Agent may write |
|---|---|---|
| Developer tracking | `gitHubDevStatus`, `gitHubBranch` | Yes |
| Business process status | Task `Status` (Accepted, In progress, Done) | Never |

Developer tracking fields are independent of BC workflow. Business process status fields control what users can do — for example, a task marked as ready for invoicing cannot receive new time entries.

## Requirements

- API pages exposed to MCP agents must mark business status fields as `Editable = false`
- Agent instructions (`.agent.md` files) must explicitly list which fields the agent may write
- Any field that affects time registration, posting, approval, or invoicing is a business process field and must be read-only for agents
- Developer-managed fields (GitHub dev status, branch, comments) are the only writable surface

## Example Agent Instruction

```
Write only gitHubDevStatus and gitHubBranch on tasks.
Never write Status — it controls the invoicing workflow.
```

## Verification

For each API page with write access, verify that fields controlling BC workflow transitions carry `Editable = false`. Review the agent instruction file to confirm it names the allowed writable fields explicitly and prohibits status fields.
