---
bc-version: [27..]
domain: agents
keywords: [agent-metadata-provider, iagentfactory, iagentmetadata, iagenttaskexecution, enumextension, implementation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Wire all three agent interfaces on the metadata provider

## Description

An AL agent type is registered by extending `Agent Metadata Provider`. The platform locates factory, metadata, and task-execution behaviour only through the `Implementation` property on that enum value. Omitting `IAgentFactory`, `IAgentMetadata`, or `IAgentTaskExecution` leaves create, UI identity, or task runs unbound. Models often ship a single codeunit and skip the enum wiring.

## Best Practice

On the enum value, set `Implementation` for all three interfaces, each pointing at a dedicated codeunit. Keep factory (create, defaults, first-time setup), metadata (setup page, summary, annotations), and task execution (message analysis, intervention suggestions) in separate objects.

See sample: [`wire-all-three-agent-interfaces.good.al`](wire-all-three-agent-interfaces.good.al).

## Anti Pattern

An `Agent Metadata Provider` value with no `Implementation`, only one interface mapped, or all three interfaces pointing at one catch-all codeunit that cannot satisfy the contracts. Detection signal: enumextension of `Agent Metadata Provider` whose value does not list `IAgentFactory`, `IAgentMetadata`, and `IAgentTaskExecution`.

See sample: [`wire-all-three-agent-interfaces.bad.al`](wire-all-three-agent-interfaces.bad.al).

## See also

`register-copilot-capability-for-the-agent.md` covers the feature capability linked by the factory implementation.
