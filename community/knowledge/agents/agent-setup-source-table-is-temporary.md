---
bc-version: [27..]
domain: agents
keywords: [sourcetabletemporary, configurationdialog, savechanges, cancel, draft]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep the agent setup page source temporary until Update

## Description

ConfigurationDialog setup is a draft: the user can Cancel without writing. That only works if `SourceTableTemporary = true` and custom fields stay in memory until Update. Writing the real table in OnValidate or OnOpenPage commits a partial agent when the dialog errors or is cancelled.

## Best Practice

Mark the page `SourceTableTemporary = true`. Copy into the temp record on open. Persist the Agent Setup buffer and custom fields only from the close path when the action is not Cancel, using `Agent Setup.GetChangesMade` / `SaveChanges`.

See sample: [`agent-setup-source-table-is-temporary.good.al`](agent-setup-source-table-is-temporary.good.al).

## Anti Pattern

A non-temporary source table, or `Insert`/`Modify` on the persisted setup row from field OnValidate. Detection signal: agent `ConfigurationDialog` without `SourceTableTemporary = true`, or database writes before Update.

See sample: [`agent-setup-source-table-is-temporary.bad.al`](agent-setup-source-table-is-temporary.bad.al).

## See also

`agent-setup-page-is-configuration-dialog.md` defines the setup page shape that uses this draft lifecycle.
