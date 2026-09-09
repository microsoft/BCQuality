---
bc-version: [27..]
domain: agents
keywords: [agent-session, isagentsession, bindsubscription, system-initialization, singleinstance]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Bind extra agent subscribers only inside an agent session

## Description

Page-filter tweaks, extra validation, and prompt dialogs for the agent should not run for every user. `Agent Session.IsAgentSession` distinguishes agent UI sessions. Binding those subscribers on `System Initialization` only when the session is an agent session avoids global subscriber cost. Models register `SingleInstance` table subscribers unconditionally.

## Best Practice

On `OnAfterInitialization`, exit unless `Agent Session.IsAgentSession`. Then `BindSubscription` a single-instance codeunit that holds the current task id. Keep those subscribers internal.

See sample: [`bind-agent-subscribers-only-in-agent-session.good.al`](bind-agent-subscribers-only-in-agent-session.good.al).

## Anti Pattern

Event subscribers on `Sales Header` OnAfterInsert that always `Message` the agent, with no `IsAgentSession` guard. Detection signal: agent-only behaviour in a static subscriber that is not bind-gated.

See sample: [`bind-agent-subscribers-only-in-agent-session.bad.al`](bind-agent-subscribers-only-in-agent-session.bad.al).
