# BCQuality

Quality skills and knowledge that help AI tools make better Business Central
development decisions: catch BC-specific defects, avoid misleading advice,
and explain findings with references you can read.

BCQuality contains **knowledge and reusable skills**, not agents or a Business
Central extension. Your host supplies the agent. You can install the content
as a plugin, use it from another integration, or browse the knowledge directly.

## Quick start

The walkthrough below uses **GitHub Copilot CLI in a terminal**, not the
Copilot Chat panel in VS Code. First
[install Copilot CLI and sign in](https://docs.github.com/en/copilot/get-started/cli-quickstart).
Your account and organization policy must allow its use. You do not need to
clone BCQuality, build a runner, or deploy an app to Business Central for this
source-review example.

### Standalone plugin installation

Run these commands in your terminal:

```powershell
copilot plugin install microsoft/BCQuality
copilot plugin list
```

The list should include `bcquality`. The plugin currently exposes the
[`al-code-review`](skills/al-code-review/SKILL.md) skill. Installation and skill
discovery are the general pattern; reviewing an app is one example of using it.

### Example: Review a complete app folder

Start a **new** CLI session in your own app folder, replacing the example path:

```powershell
cd "C:\Repos\MyBusinessCentralApp"
copilot
```

Approve access only to a project you trust, then ask:

> Use the installed al-code-review skill to review the complete Business Central
> app in this folder without changing my source files. Return the complete
> BCQuality findings report.

The folder should contain `app.json` and your AL source; it does **not** need
to be a Git repository. On macOS or Linux, use your app's local path instead.

Expect a report for each selected review, with findings, source locations,
severity, confidence, and references to the relevant guidance. Some hosts show
the structured JSON directly. `completed` with no findings means nothing was
flagged in that review's scope; `partial` or `failed` is **not** a clean result.
See [reading your results](docs/using-bcquality.md#reading-your-results).

[PowerShell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
(`pwsh`) is recommended for fast knowledge discovery. If it is unavailable,
the review can still discover knowledge by reading the folders.

## Documentation

| I want to... | Start here |
| --- | --- |
| Choose direct reading, a supplied skill, or my own agent | [Ways to use BCQuality](docs/using-bcquality.md#choose-how-to-use-bcquality) |
| Review a file, changes, a branch, or a particular concern | [Using BCQuality](docs/using-bcquality.md) |
| Resolve setup problems, incomplete reviews, or incorrect findings | [Troubleshooting and support](docs/troubleshooting.md) |
| Browse the available guidance | [Knowledge by domain](docs/using-bcquality.md#knowledge-by-domain) |
| Configure the plugin or use my organization's rules | [Customizing BCQuality](docs/customizing-bcquality.md) |
| Contribute knowledge or improve a rule | [Your first contribution](docs/contributing.md#your-first-contribution) |
| Connect a host, agent, or CI integration | [Minimal integration example](docs/agent-consumption.md#try-a-minimal-integration) |

[All documentation and technical references](docs/README.md).

## Scope

Today's curated content focuses on **technical AL code review**. It augments
the agent's judgment; it is not an exhaustive BC manual or a substitute for
compilation, analyzers, tests, or human review. See
[coverage and limits](docs/using-bcquality.md#coverage-and-limits) for the
available domains and the difference between a folder review and a comparison.

Functional areas such as Finance, Supply Chain Management, Manufacturing, Jobs,
Warehousing, and Service, and technologies such as PowerShell, pipelines, and
Power Platform, remain valid future scope, **not current coverage claims**.

## What's in this repo

Knowledge articles cover one concern each. Skills tell an agent how to find
and apply the relevant knowledge. Both live in three layers:

| Layer | Purpose |
| --- | --- |
| [Microsoft](microsoft/) | Microsoft-endorsed skills and their knowledge. |
| [Community](community/) | Community-owned skills and their knowledge. |
| [Custom](custom/) | Organization-specific additions and overrides in your own fork. |

All three are enabled by default; Custom is empty upstream. You do not need
to configure layers to get started.

## Versioning

Update the installed plugin from your terminal, then start a new session:

```powershell
copilot plugin update bcquality
```

Plugin versions and content-release tags are different. For reproducible runs
and organization forks, see [updates and versions](docs/customizing-bcquality.md#updates-and-versions).

## What belongs here

Knowledge belongs here when it prevents a BC-specific mistake an otherwise
capable agent would make, including false-positive findings. BC facts belong
in knowledge articles, not skill instructions. See the
[admission test and examples](docs/contributing.md#what-belongs-here).

## Contributing

Partners are welcome to contribute to the layer that owns the domain,
regardless of affiliation. Start with the [contribution guide](docs/contributing.md).
To report a problem without authoring a rule, see [support](docs/troubleshooting.md#reporting-a-problem).

## License

[MIT](LICENSE)
