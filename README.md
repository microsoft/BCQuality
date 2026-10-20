# BCQuality — Don’t teach one agent. Teach the ecosystem. 🤝

Quality skills and knowledge that help AI tools make better Business Central
development decisions: catch BC-specific defects, avoid misleading advice,
and explain findings with references you can read.

BCQuality contains **knowledge and reusable skills**, not agents or a Business
Central extension. Your host supplies the agent. You can install the content
as a plugin, use it from another integration, or browse the knowledge directly.

## Three ways to use BCQuality

| Use | Status | Start here |
| --- | --- | --- |
| Review your AL code on demand with the Copilot CLI plugin | Available | [Quick start](#quick-start) |
| Review pull requests automatically in AL-Go for GitHub repositories | In progress in [AL-Go for GitHub](https://github.com/microsoft/AL-Go/pull/2402) | AL-Go documentation once released |
| Apply BCQuality guidance to a development plan before coding | Preview in the plugin | [Plan guidance](#preview-guidance-before-implementation) |

## Quick start

Install the plugin and run your first review. You need
[GitHub Copilot CLI, installed and signed in](https://docs.github.com/en/copilot/get-started/cli-quickstart),
with an account and organization policy that allow its use. You do not need to
clone BCQuality, build a runner, or deploy an app to Business Central.

Copilot CLI runs in any terminal, including the **integrated terminal in VS
Code**. A plugin installed in Copilot CLI is not automatically available in the
Copilot Chat panel.

1. Install the plugin:

   ```powershell
   copilot plugin install microsoft/BCQuality
   copilot plugin list
   ```

   The list should include `bcquality`. In a Copilot CLI session, `/skills
   list` shows its two skills: `al-code-review` and the preview
   `al-plan-guidance`.

2. Start a **new** Copilot CLI session in your app folder, replacing the
   example path:

   ```powershell
   cd "C:\Repos\MyBusinessCentralApp"
   copilot
   ```

3. Approve access only to a project you trust, then ask:

   > Use the installed al-code-review skill to review the complete Business
   > Central app in this folder without changing my source files. Return the
   > complete BCQuality findings report.

The folder should contain `app.json` and your AL source; it does **not** need
to be a Git repository. On macOS or Linux, use your app's local path instead.

### What you get

Each selected review returns findings with a source location, severity,
confidence, and the guidance behind them. For example, a performance finding
might read:

> **Major · high confidence** · `src\CustomerExport.Codeunit.al`, line 42
>
> The country filter is evaluated inside the customer loop, so rows that will
> be discarded are still read from the database. Apply the filter with
> `SetRange` before calling `FindSet`.
>
> Guidance: [Apply filters before iterating](microsoft/knowledge/performance/apply-filters-before-iterating.md)

This example is illustrative; your host may show the same information as text,
a table, or JSON. `completed` with no findings means nothing was flagged in
that review's scope; `partial` or `failed` is **not** a clean result. See
[reading your results](docs/using-bcquality.md#reading-your-results).

Next, try a focused request, such as reviewing performance only or reviewing
your uncommitted changes. See [common review requests](docs/using-bcquality.md#common-review-requests).

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

Today's curated content covers **technical AL code review** and focused
**Supply Chain Management (SCM)** and **Finance** functional domains. It augments
the agent's judgment; it is not an exhaustive BC manual or a substitute for
compilation, analyzers, tests, or human review. See
[coverage and limits](docs/using-bcquality.md#coverage-and-limits) for the
available domains and the difference between a folder review and a comparison.
Mechanical issues already enforced by the AL compiler or standard analyzers are
intentionally left to those deterministic tools rather than duplicated here.

The [SCM domain](microsoft/knowledge/scm/) covers selected inventory, costing,
reservation, tracking, and warehouse/posting workflows. The
[Finance domain](microsoft/knowledge/finance/) covers selected journal posting,
financial ledger, application, VAT, and posting-dimension workflows. Neither is
exhaustive functional validation. Broader functional coverage such as
Manufacturing, Jobs, and Service, and technologies such as PowerShell,
pipelines, and Power Platform, remain valid future scope, **not current
coverage claims**.

## Preview: guidance before implementation

BCQuality can also apply its knowledge **before code is written**. The
plugin's `al-plan-guidance` skill takes an existing AL development plan and
returns the BCQuality constraints and validation considerations that apply to
it. It is read-only: it does not create or rewrite the plan, change your code,
or implement the change.

Save your plan as a file, start a new Copilot CLI session in your app folder,
and ask:

> Use the installed al-plan-guidance skill to enrich the plan in
> `plans\my-change.md` with applicable BCQuality guidance, without changing the
> plan or my source files. Return the complete guidance report.

Give the plan and the report to your coding agent together. After
implementation, review the finished change with `al-code-review`.

This capability is a preview, and its contract may change based on pilot
feedback. Integrations can also call it without the plugin; see the
[plan guidance example](docs/agent-consumption.md#try-plan-guidance).

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

### How the pieces fit

You use BCQuality through **capabilities**: `al-code-review` reviews code,
and `al-plan-guidance` enriches a plan. Behind every capability, BCQuality's
**Entry** router prepares the knowledge index, applies your layer and skill
settings, and selects the skill that does the work. You never call Entry
yourself when using the plugin.

Integrations such as CI workflows can call Entry directly with a free-text
goal instead. Both paths use the same router, knowledge, and report contracts,
so a plugin review and an automated review apply the same rules. Review skills
return a `findings-report`; plan guidance returns a read-only
`development-guidance-report`. See
[how agents consume BCQuality](docs/agent-consumption.md).

## Versioning

Update the installed plugin from your terminal, then start a new session:

```powershell
copilot plugin update bcquality
```

`copilot plugin list` shows the installed version. Release `v1.8` carries
plugin version `1.8.0`. Installing from the repository without a tag uses the
current `main`, which can include changes after or before the matching release.
For reproducible runs and organization forks, see [updates and versions](docs/customizing-bcquality.md#updates-and-versions).

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
