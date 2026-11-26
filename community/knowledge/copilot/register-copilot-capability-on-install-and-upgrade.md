---
bc-version: [23..]
domain: copilot
keywords: [copilot-capability, registercapability, iscapabilityregistered, install-codeunit, upgrade-codeunit, onupgradeperdatabase, enumextension]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Register a Copilot capability on install and on upgrade

## Description

Every extension that calls the AI module must register its `Copilot Capability` enum value with codeunit `Copilot Capability`; using a capability that the calling extension has not registered raises an error. The usual sample registers it in `OnInstallAppPerDatabase`, but install code does not run when an already-installed extension is upgraded to a version that introduces the capability. On those tenants the Copilot action fails, and the capability is missing from the **Copilot & agent capabilities** page, so administrators cannot see or control it.

This applies to Copilot features built on the AI module, such as PromptDialog experiences and AOAI calls. Agent SDK registration is covered by the Agents domain.

## Best Practice

Put the registration in one procedure, guarded by `IsCapabilityRegistered`, and call it from both `OnInstallAppPerDatabase` and `OnUpgradePerDatabase`, optionally behind an upgrade tag. Pass the availability (`Preview` or `Generally Available`), a learn-more URL, and on BC27 and later the billing type that matches the Azure OpenAI resource the code uses. Follow Microsoft's sample and register only when `EnvironmentInformation.IsSaaSInfrastructure()` is true if the feature is online-only.

See sample: [`register-copilot-capability-on-install-and-upgrade.good.al`](register-copilot-capability-on-install-and-upgrade.good.al).

## Anti Pattern

An extension that adds a `Copilot Capability` enum extension value and calls `SetCopilotCapability` with it, but registers the capability only from an install codeunit, or never registers it. Detection signal: a `RegisterCapability` call reachable from `OnInstallAppPerDatabase` with no equivalent path from an upgrade codeunit.

Do not flag registration that is shared through a helper called from both triggers, or an extension version whose first release already contains the capability, if the review has evidence that no earlier version was ever published.

See sample: [`register-copilot-capability-on-install-and-upgrade.bad.al`](register-copilot-capability-on-install-and-upgrade.bad.al).

## References

[Build the Copilot capability in AL, Registering an AI capability](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/ai-build-capability-in-al#registering-an-ai-capability): unregistered capabilities throw an error; the registering codeunit can be of type Install or Upgrade; billing type applies from 2025 release wave 2. Install code not running on upgrade is covered in `microsoft/knowledge/upgrade/install-code-does-not-run-on-version-upgrade.md`.
