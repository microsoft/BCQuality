---
bc-version: [23..]
domain: copilot
keywords: [azure-openai, aoai, httpclient, setcopilotcapability, ai-module, system-ai, chat-completion, openai-endpoint]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Call Azure OpenAI through the System.AI module, not a hand-built HttpClient request

## Description

The System Application's AI module (`Azure OpenAI`, `AOAI Chat Messages`, `AOAI Chat Completion Params`, `AOAI Operation Response`) is the supported way to call Azure OpenAI from AL. A call made through it is tied to a registered Copilot capability by `SetCopilotCapability`. The capability appears on the **Copilot & agent capabilities** page, where administrators can deactivate it and control user access. The call is also subject to the environment's data-movement and billing rules, and it emits Copilot telemetry.

An AL `HttpClient` request posted straight to an `openai.azure.com` (or other LLM) endpoint gets none of this. Administrators cannot see or switch off the feature, the call runs even when the customer has opted out of data movement, and Business Central AI resources and their billing cannot be used. Agents asked to "add AI" to an extension often produce this raw HTTP pattern, because it is how other platforms call OpenAI.

## Best Practice

Build the request with the AI module: authorize with `SetAuthorization` (own resource, key as `SecretText`) or `SetManagedResourceAuthorization` (Business Central AI resources), call `SetCopilotCapability` with your registered capability, add messages through `AOAI Chat Messages`, and generate with `GenerateChatCompletion`. Check `IsEnabled` for the capability before offering or running the feature.

Authorization signatures depend on the target version. The sample uses the BC23+ own-resource setup: `SetAuthorization(ModelType, Endpoint, Deployment, ApiKey)`, with the endpoint, deployment, and `SecretText` key supplied by the caller from secure extension configuration. It does not require `AOAI Deployments` or a particular managed model. For Business Central AI resources, select an overload available in the target symbols: BC24 has no `SetManagedResourceAuthorization`; BC27 provides four/five-argument overloads requiring own-resource details; the two-argument `SetManagedResourceAuthorization(ModelType, ManagedResourceDeployment)` is available from BC28. Do not use that modern shorthand in an extension targeting older versions.

The good companion declares its own `Draft Item Description` capability enum value so it can be prepared independently. Before running it, register that value using the [install/upgrade registration pattern](register-copilot-capability-on-install-and-upgrade.md) and activate the capability. The registration article's companion is a separate example: adapt its registration code to this sample's enumextension rather than adding a second declaration of the same value.

See sample: [`call-azure-openai-through-the-ai-module.good.al`](call-azure-openai-through-the-ai-module.good.al).

## Anti Pattern

AL code that sends an `HttpClient` request to an Azure OpenAI or other LLM completion endpoint (`/chat/completions`, `/completions`, `api-key` header, `messages` JSON array) to implement a user-facing Copilot feature. Also a call through the AI module that omits `SetCopilotCapability`.

This rule is about generative AI calls made from a Business Central extension. Do not flag HTTP calls to non-LLM services, or code inside the System Application's own AI module.

See sample: [`call-azure-openai-through-the-ai-module.bad.al`](call-azure-openai-through-the-ai-module.bad.al).

## References

[Build the Copilot capability in AL](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/ai-build-capability-in-al) (the AI module provides discoverability, transparency, control, data governance, guard rails, and telemetry) and [Business Central AI resources](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/ai-dev-tools-resources) (`SetManagedResourceAuthorization`). That a raw HTTP call bypasses capability deactivation and data-movement controls follows from those controls being implemented in the module; Microsoft does not state it as a separate rule.
