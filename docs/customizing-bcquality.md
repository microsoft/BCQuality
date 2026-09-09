# Customizing BCQuality

[Documentation](README.md) | [Using BCQuality](using-bcquality.md) | [Contributing](contributing.md)

**No customization is required to get started.** Use the upstream plugin
unless you need a different review selection or organization-specific rules.
Model choice, concurrency, retries, and billing belong to your host, not
BCQuality. A [standalone runner](standalone-runner.md) is an advanced option.

## Select layers or disable a review

The standalone adapter reads these environment variables from the process
that starts your host:

| Variable | Default | Meaning |
| --- | --- | --- |
| `BCQUALITY_ENABLED_LAYERS` | `microsoft,community,custom` | Comma-separated layer names to discover. |
| `BCQUALITY_DISABLED_SKILLS` | None | Comma-separated **BCQuality repo-relative skill paths** to exclude, not display names or knowledge-article paths. |

For example, in PowerShell, enable only Microsoft knowledge and omit the
dedicated style review:

```powershell
$env:BCQUALITY_ENABLED_LAYERS = "microsoft"
$env:BCQUALITY_DISABLED_SKILLS = "microsoft/skills/review/al-style-review.md"
copilot
```

Set the variables **before** starting a new session. They apply to that
terminal and its child processes; use your host's environment configuration
if it starts elsewhere. Review selection is not a guarantee that another
domain or the agent will never mention a related concern.

To return to defaults, remove those variables from the environment before
starting the host again (or use a fresh terminal if you only set them there).
Do not use an empty comma-separated value as a substitute for the default.

All layers are enabled by default. Where relevant articles have overlapping
applicability and **contradictory guidance**, precedence is:

**Custom > Community > Microsoft.**

Otherwise the layers are additive. A matching filename alone does not suppress
an article; the [READ contract](../skills/read.md#layer-precedence) governs
knowledge conflicts. Review reports record displaced knowledge in `suppressed`.

Layer selection is **not an access-control boundary**. A plugin installation
still contains excluded layers on disk. An integration requiring genuine
exclusion must remove denied files from its own content copy before the agent
reads it; the [adapter](../skills/al-code-review/SKILL.md#layer-selection-is-not-a-deny-mechanism)
explains this distinction.

## Add an organization-specific rule

Keep custom content in a fork or organization-controlled copy of BCQuality,
not in your AL app's `custom` folder and not in the installed plugin cache.
Editing the cache is not durable across updates.

1. Fork BCQuality into a repository your organization controls, or create an
   organization-controlled copy if a public fork is unsuitable for your policy.
2. Clone that repository and run `git remote get-url origin`. Confirm it is
   your repository, **not** `microsoft/BCQuality`.
3. Add the article under `custom/knowledge/<existing-domain>/`, using the
   [knowledge format](../skills/read.md). Keep your company's content out of
   upstream pull requests.

For example, suppose your company deliberately names one page "ACME Inventory
Workbench" while showing stockkeeping units, and already makes the row type
clear in its UI. You want a narrow exception to the shared page-naming rule.
Create `custom/knowledge/style/page-name-must-match-source-table.md` in your
copy with this content:

```markdown
---
bc-version: [all]
domain: style
keywords: [page-name, source-table, inventory, workbench]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Allow the ACME Inventory Workbench task name

## Description

Our approved page "ACME Inventory Workbench" shows stockkeeping units. Its UI
identifies the row type explicitly; its task-oriented name is company policy.

## Best Practice

Do not report that page solely because its name differs from its source-table
entity. Keep the shared naming guidance for other pages.

## Anti Pattern

Renaming the approved page solely to repeat the source-table entity, or
applying this exception to an unrelated page.
```

This is an **illustrative company policy**, not a new Microsoft recommendation.
Choose your actual domain, applicability, and policy; do not broaden an
exception merely to silence a valid defect. The shared rule is
[page-name-must-match-source-table.md](../microsoft/knowledge/style/page-name-must-match-source-table.md).
Guidance in `Best Practice` and `Anti Pattern` drives conflict resolution, so
do not put the exception only in a non-normative notes section.

Follow the [contribution checks](contributing.md#before-opening-a-pr) locally,
then commit your change in your repository. A new knowledge domain also needs
an action skill that discovers it; adding an arbitrary folder does not create
a review.

## Use your fork

Adding custom content does not change the upstream plugin you already
installed. Point the host at your copy.

For a pushed fork, replace `YOUR-ORG` with its owner. These commands replace
the upstream installation, since both manifests use the name `bcquality`:

```powershell
copilot plugin uninstall bcquality
copilot plugin install YOUR-ORG/BCQuality
copilot plugin list
```

For local development, install your copy's absolute path instead:

```powershell
copilot plugin install "C:\Repos\CompanyBCQuality"
```

Direct local installs are cached by the CLI; reinstall that path after edits,
then start a new session. See the host's
[local-plugin instructions](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-creating).
Do not assume the currently running session has reloaded the content.

Confirm the plugin list points at the intended source and that the Custom
layer is enabled. Review a small example relevant to your rule. Ask the host
which custom article it read and inspect `suppressed` for an actual conflict.
The negative-rule example should produce no naming finding for the approved
page; do not add an information-only finding just to prove the article was
loaded. The absence of a finding alone does not prove your fork was used.

An external runner should likewise read from your fork or local copy rather
than the upstream URL. It must still start at [Entry](../skills/entry.md).

## Updates and versions

| Identifier | What it identifies |
| --- | --- |
| Plugin `version` in `plugin.json` | The host-facing package version. It is separate from content-release tags. `copilot plugin list` shows the installed plugin; inspect the resolved source when reproducing a run. |
| Content tag such as `v1.6` | A release of the repository's knowledge and skills. Available tags are listed on [GitHub](https://github.com/microsoft/BCQuality/tags). |
| Skill `version` in frontmatter | That skill's contract version, carried in reports. It does not identify the complete knowledge snapshot. |
| Git commit SHA | The exact repository snapshot. Record this for reproducibility when using a checkout. |

For the upstream plugin, run `copilot plugin update bcquality`, then start a
new session. The unpinned installation command does not promise a particular
content-release tag. For a fork, updating the plugin reads your fork; it does
not merge upstream changes into it.

To maintain a fork, commit your custom work first, add an `upstream` remote
pointing to `https://github.com/microsoft/BCQuality.git` once, fetch upstream,
and merge the desired upstream branch or content tag. Resolve conflicts and
review the resulting policy before publishing or reinstalling your fork.
Do not overwrite the fork wholesale with an upstream download.

For repeatable CI or runner use, select a tag or commit in a dedicated clean
checkout and record `git rev-parse HEAD`. Upgrade deliberately, compare the
old and new content, and rerun representative reviews. To roll back, select
the previously recorded snapshot in that checkout and reinstall it if your
host caches local plugins. Retain organization-specific rules in the chosen
snapshot rather than reverting to an upstream-only tag.
