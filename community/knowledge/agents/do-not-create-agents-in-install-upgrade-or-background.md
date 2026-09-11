---
bc-version: [27..]
domain: agents
keywords: [agent-create, install, upgrade, job-queue, interactive-session, background]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not create agent instances from install, upgrade, or background sessions

## Description

`Agent.Create` requires an interactive user session. The platform blocks creation from install codeunits, upgrade codeunits, and background sessions (job queue, scheduled tasks). Packaging an agent in an app does not mean spinning up instances at install. Models still call `Create` from `OnInstallAppPerCompany` to activate the agent.

## Best Practice

Create instances from a setup page, a wizard, or another UI-driven path after the user is in a client session. Apply instructions and `Activate` there. For existing companies after an upgrade, document that an admin must open setup; do not create from the upgrade codeunit.

See sample: [`do-not-create-agents-in-install-upgrade-or-background.good.al`](do-not-create-agents-in-install-upgrade-or-background.good.al).

## Anti Pattern

`Agent.Create` inside `OnInstallAppPerCompany`, `OnUpgradePerCompany`, or a job-queue codeunit. The call fails at runtime even if it compiles. Detection signal: `Agent.Create` in `Subtype = Install`, `Subtype = Upgrade`, or a non-UI session.

See sample: [`do-not-create-agents-in-install-upgrade-or-background.bad.al`](do-not-create-agents-in-install-upgrade-or-background.bad.al).
