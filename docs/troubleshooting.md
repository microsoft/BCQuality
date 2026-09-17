# Troubleshooting and support

[Documentation](README.md) | [Quick start](../README.md#quick-start) | [Using BCQuality](using-bcquality.md)

## Setup and skill discovery

Run terminal commands outside the interactive Copilot prompt unless they
start with `/`.

| Symptom | What to do |
| --- | --- |
| `copilot` is not recognized | [Install Copilot CLI](https://docs.github.com/en/copilot/get-started/cli-quickstart), then open a new terminal. Installing Copilot Chat in an editor is not the same step. |
| The CLI has no `plugin` command | Update Copilot CLI using its installation method. Confirm `copilot plugin --help` works. |
| Sign-in, entitlement, or organization-policy error | Start `copilot`, use `/login`, and confirm your account is allowed to use Copilot CLI. Ask your administrator about organization restrictions; BCQuality cannot override them. |
| Plugin installation cannot reach the repository | Confirm access to `https://github.com/microsoft/BCQuality` and follow your organization's proxy/network guidance. Do not disable certificate checks. |
| The plugin installed, but the skill is missing | Run `copilot plugin list` in the terminal. Enable it with `copilot plugin enable bcquality` if disabled, then start a new session. In the session, use `/skills list` and look for `al-code-review`. |
| The agent performs a generic review | Name the **installed `al-code-review` skill** explicitly, as in the quick start. Ask which skill and BCQuality source it used. Another plugin or host may expose a similarly named operation. |
| Installation works in the terminal, but not in the editor | Plugin discovery is host-specific. Follow the editor's installation instructions; a CLI installation is not proof that another host loaded the plugin. |
| `pwsh` is missing, or index generation fails | The index is an accelerator, not required knowledge. The review can fall back to discovery from folders. For faster discovery, install [PowerShell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell), or resolve the reported filesystem error. |
| An update or local edit is not visible | Run `copilot plugin update bcquality` for a repository-installed plugin, then start a fresh session. For a directly installed local folder, reinstall that folder to refresh the cached copy; see [customizing](customizing-bcquality.md#use-your-fork). |

## Review results

| Symptom | What to do |
| --- | --- |
| `partial`, a timeout, or an unfinished review | Read `outcome-reason` and domain reports. Retry the incomplete scope in a fresh session, use smaller app folders or a focused review, or select a host/model with sufficient capacity. Keep the limited scope visible; do not relabel it a complete app review. |
| `failed` | Resolve the stated problem, such as inaccessible input, a failed invocation, or an unverifiable reference, before using that report. A failed domain's findings are not reliable. |
| `no-match` or `not-applicable` | Confirm you supplied AL source, the intended folder/file/diff, and an appropriate goal. Check [disabled skills and layers](customizing-bcquality.md#select-layers-or-disable-a-review). |
| `no-knowledge` | Check the target BC version, selected domain, enabled layers, and whether the relevant knowledge files are present. No applicable rules is different from no defects. |
| `completed` with no findings | This can be a valid clean result for the selected scope. Confirm the intended files and domain reports are included. If you have a concrete missed defect, report it with a minimal example. |
| JSON rather than a readable summary | JSON is the shared output format. Ask the host to summarize the existing reports, preserving outcomes, locations, severity, confidence, and references. |
| A surprising finding | Open its guidance and samples, inspect surrounding code, and confirm version/localization assumptions. Ask the agent to explain the evidence; do not apply a suggestion solely because it has high confidence. |
| The Agents domain is absent | Agents is a separate Community review, not a child of the Microsoft broad review. Explicitly request an Agent SDK review and confirm the Community layer is enabled. |
| A missing base branch or unavailable source definition | Supply the real baseline or dependency definition. Without it, do not accept claims that rely on invented history or assumed dependency behavior. |
| Slow or expensive review | A broad review makes separate passes over multiple domains. Verify index generation succeeded, use a focused task when appropriate, and inspect usage in your host. BCQuality does not choose models, promise runtimes, or meter charges. |

## Reporting a problem

For incorrect BC guidance, missed findings, documentation gaps, or skill
behavior, [search existing issues](https://github.com/microsoft/BCQuality/issues)
and [open a BCQuality issue](https://github.com/microsoft/BCQuality/issues/new/choose)
if needed. You do not have to author a knowledge file before asking for help.
Host installation, authentication, billing, or policy problems belong with the
host's support channel or your organization administrator.

Include:

- The host and version, selected model if known, and BCQuality source/version
  or commit. See [version identifiers](customizing-bcquality.md#updates-and-versions).
- The prompt, scope (folder/file/diff and comparison base), target BC version,
  and relevant layer/skill settings.
- Expected versus actual behavior, the outcome/reason, and the exact rule
  reference for a disputed finding.
- A **minimal, sanitized** AL example or report excerpt that reproduces the
  problem. Remove secrets, customer data, and proprietary content you cannot share.

For security vulnerabilities, follow [SECURITY.md](../SECURITY.md) instead of
opening a public issue. To contribute a correction yourself, follow the
[contribution guide](contributing.md).
