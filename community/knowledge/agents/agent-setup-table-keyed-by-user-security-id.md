---
bc-version: [27..]
domain: agents
keywords: [user-security-id, setup-table, primary-key, agent-instance, guid]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Agent setup tables are keyed by User Security ID

## Description

Each agent instance is a user. Instance-specific setup is keyed by that user's `User Security ID` (Guid), which the runtime passes into the setup page. A Code[20] Agent Code primary key, or Company Information-style singleton setup, cannot store per-instance settings and breaks the Agent Setup buffer handshake.

## Best Practice

Give the setup table a Guid field `User Security ID` as the clustered primary key. Other settings are attributes of that key. When the page opens, `Get` or insert by the Guid the Agent Setup part already holds.

See sample: [`agent-setup-table-keyed-by-user-security-id.good.al`](agent-setup-table-keyed-by-user-security-id.good.al).

## Anti Pattern

A setup table keyed by Code, Integer, or with no Guid user key, then mapping one row to every instance. Detection signal: source table of the agent setup page whose primary key is not `User Security ID`.

See sample: [`agent-setup-table-keyed-by-user-security-id.bad.al`](agent-setup-table-keyed-by-user-security-id.bad.al).
