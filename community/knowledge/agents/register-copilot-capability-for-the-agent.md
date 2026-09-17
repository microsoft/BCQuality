---
bc-version: [27..]
domain: agents
keywords: [copilot-capability, registercapability, install, feature-switch, enumextension]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Register a Copilot capability for the agent on install

## Description

Each agent type needs a `Copilot Capability` enum value that the factory links as the feature switch and billing surface. The capability is invisible on Copilot and agent capabilities until an install codeunit calls `RegisterCapability` when it is not already registered. Unique ordinals matter across installed apps. Models often extend `Agent Metadata Provider` and never register the capability.

## Best Practice

Extend `Copilot Capability` with a unique value. In `OnInstallAppPerDatabase`, call `Copilot Capability.IsCapabilityRegistered` and, if false, `RegisterCapability` with availability, billing type, and a learn-more URL. Point `IAgentFactory` at that capability.

See sample: [`register-copilot-capability-for-the-agent.good.al`](register-copilot-capability-for-the-agent.good.al).

## Anti Pattern

Shipping the agent enum without a `Copilot Capability` value, or adding the enum but never calling `RegisterCapability`. Duplicate ordinals across extensions also collide. Detection signal: agent metadata provider with no matching capability registration in an install codeunit.

See sample: [`register-copilot-capability-for-the-agent.bad.al`](register-copilot-capability-for-the-agent.bad.al).

## See also

`wire-all-three-agent-interfaces.md` covers registration of the provider implementation that references this capability.
