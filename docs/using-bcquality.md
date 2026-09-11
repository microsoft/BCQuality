# Using BCQuality

[Documentation](README.md) | [Quick start](../README.md#quick-start) | [Troubleshooting](troubleshooting.md)

BCQuality is knowledge you can read and reuse, plus skills that tell an agent
how to apply it. You do not need an AI tool to read the articles. When using
an agent, your host supplies authentication, model access, tools, permissions,
and rendering; BCQuality does not install a BC extension or an agent.

## Choose how to use BCQuality

| Path | What to do |
| --- | --- |
| Read the knowledge yourself | Browse [knowledge by domain](#knowledge-by-domain), or search the repository for an AL concept. Read the article and its samples. No installation required. |
| Use a supplied skill | Follow the [plugin quick start](../README.md#quick-start). The currently exposed skill, `al-code-review`, performs reviews and returns findings. |
| Use your own agent or workflow | Supply selected articles as context, as described below, or use the [integration bootstrap](agent-consumption.md#try-a-minimal-integration) to execute BCQuality action skills without the plugin. |

### Read and reuse an article

Start with a concern, such as `SetLoadFields`, and search within
`microsoft/BCQuality` on GitHub or open its domain folder. For example,
[partial-record guidance](../microsoft/knowledge/performance/use-setloadfields-for-partial-records.md)
explains the concern and links good/bad samples.

Before applying an article, read its frontmatter, the small metadata block at
the top:

| Field | How to read it |
| --- | --- |
| `bc-version` | `[24..]` means BC 24 and later; `[26..28]` means BC 26 through 28; `[all]` means every version. Use your target BC major version, not your extension's version. |
| `technologies` | `[al]` means the guidance applies to AL; multiple values identify the technologies the article covers. |
| `countries` | `[w1]` means worldwide; a code such as `[dk]` limits the guidance to that localization. |
| `application-area` | `[all]` means any application area; a named area narrows applicability. |
| `domain` and `keywords` | Help you find the topic; they are not instructions or additional requirements. |

Read `Description` for context, then `Best Practice` and `Anti Pattern` for the
rule and its exceptions. Follow any sample and source links. Do not turn a
sample into a production implementation without considering your own context.
The [READ reference](../skills/read.md) defines the precise matching rules.

To use an article with your own agent, give it access to the full article and
relevant samples, not just a title or index row. For example, replace the
bracketed values in this prompt:

> Read [article URL or local path] and its linked samples. Apply the relevant
> guidance while implementing [task] for BC [major version]. Explain which
> guidance you used, cite the article, and identify any missing context.

A URL only works if the host can retrieve it; otherwise provide the files
directly. This is ordinary reuse of knowledge for explanation or code writing,
**not a packaged code-generation skill or a complete BCQuality review**.
For the structured review process, invoke a supplied skill or follow the
integration protocol. The remaining sections describe the review workflow.

## Hosts and prerequisites

The [quick start](../README.md#quick-start) documents GitHub Copilot CLI. Use a
current CLI release with plugin support and sign in to an account allowed to
use it. In an interactive CLI session, `/skills list` should include
`al-code-review`; in the terminal, `copilot plugin list` should include
`bcquality`.

Do not assume a CLI installation also installs the plugin into VS Code,
another editor, or another agent host. Follow that host's plugin instructions
and confirm it discovers `skills/al-code-review/SKILL.md`. Hosts without
compatible plugin discovery need an [integration](agent-consumption.md).

Source review needs access to your files, not a running BC environment.
Include `app.json` and any relevant surrounding source. Dependency symbols or
a historical baseline may be needed to substantiate particular findings; a
review must not invent missing definitions or an earlier version of your app.
PowerShell 7 (`pwsh`) accelerates discovery by generating the knowledge index.
Without it, folder-based discovery is available and may take longer.

## Common review requests

Start a new host session after installing or updating the plugin. Use the
skill name explicitly and say what is in scope. Replace example paths and
branch names with ones in your project.

| Task | Example prompt |
| --- | --- |
| Complete app | Use the installed al-code-review skill to review the complete Business Central app in this folder without changing my source files. Return the complete BCQuality findings report. |
| One file | Use the installed al-code-review skill to review `src\CustomerMgt.Codeunit.al` without changing it. Return the complete BCQuality findings report. |
| Uncommitted changes | Use the installed al-code-review skill to review my staged and unstaged tracked changes against HEAD, without changing files. Identify any untracked AL files not included in that diff. |
| Branch changes | Use the installed al-code-review skill to review changes on this branch since its merge base with `origin/main`. Exclude uncommitted changes and do not edit files. |
| Focused review | Use the installed al-code-review skill to review performance in the app in this folder, without changing files. Return the complete performance findings report. |
| Agent SDK code | Use the installed al-code-review skill to review Agent SDK implementation and usage in this app folder, without changing files. Return the complete Agents findings report. |

For Git comparisons, the named base ref must exist locally. If it is missing,
fetch the intended branch first. A PR review also requires the host to have
the PR's changes and repository access; installing the plugin does not
automatically connect it to your PR workflow.

A complete-folder review considers relevant files recursively, not just
modified files. Start in a single app's root for the clearest scope. For a
repository containing several apps, name each app folder and review them
separately when their target versions or dependencies differ.

If known, add the target BC major version and localization to the request.
Do not use your extension's own `version` as the BC version. Missing
applicability context can reduce a finding's confidence or leave a rule out.

## Reading your results

The skill returns structured reports. A host may render them as text, a table,
or annotations, or show the JSON directly. You can ask the host to explain the
returned report without rerunning the review or changing files.

For example, a performance report could contain this finding:

| Field | Illustrative value |
| --- | --- |
| Outcome | `completed` |
| Location | `src\CustomerExport.Codeunit.al`, line 42 |
| Severity / confidence | `major` / `high` |
| Finding | A country filter is evaluated inside the customer loop, so rows that will be discarded are still read. Apply the filter before iterating. |
| Guidance | [Apply filters before iterating](../microsoft/knowledge/performance/apply-filters-before-iterating.md), with linked good/bad samples. |

This illustrates a report, not a guaranteed finding or host screen. Read the
referenced article and the surrounding source before accepting a fix.

### Outcomes

| Outcome | Meaning and action |
| --- | --- |
| `completed` | The selected review finished. An empty `findings` list means it found nothing to flag in that scope, not that the app is certified defect-free. |
| `not-applicable` | The review did not apply to the supplied input. It is not a clean-review result. |
| `no-knowledge` | No applicable knowledge was available. Check scope, target context, and enabled layers. |
| `partial` | Some work did not finish. Read `outcome-reason` and the individual reports; do not treat the result as a full pass. |
| `failed` | No reliable result from that review. Resolve the reported error before relying on it. |
| `no-match` | Routing found no suitable skill. Check the request, input type, and disabled skills. |

A broad review includes individual domain reports in `sub-results`. Separately
dispatched skills return separate reports, so do not mistake the first report
for the whole run. Coverage counts describe selected knowledge items evaluated,
not a percentage of all possible defects or every rule in the repository.

For example, this completed **domain** report evaluated one selected knowledge
item and found nothing to flag:

```json
{
  "skill": { "id": "al-performance-review", "version": 1 },
  "outcome": "completed",
  "summary": {
    "counts": { "blocker": 0, "major": 0, "minor": 0, "info": 0 },
    "coverage": { "worklist-size": 1, "items-evaluated": 1 }
  },
  "findings": [],
  "suppressed": []
}
```

This is not evidence that other domains ran; their reports must also be present
when requested.

### Severity, confidence, and references

| Severity | Meaning |
| --- | --- |
| `blocker` | A platform-level guarantee is violated; the work cannot proceed as-is. |
| `major` | A significant defect that should be addressed before merge. |
| `minor` | A quality concern; advisory rather than a gate. |
| `info` | Concrete context or an observation, not an instruction to change code. |

Confidence (`high`, `medium`, or `low`) describes the strength of the evidence,
not the impact. Missing version or localization context must be disclosed in
the finding when conditionally applicable knowledge is used.

Knowledge-backed findings link to the articles that informed them. Findings
from the agent's own reasoning have no knowledge reference (`references: []`);
these are advisory, with severity capped at `minor` and confidence at `medium`.
The display domain `Agents` means Agent SDK guidance; it is different from
`Agent`, the label for the broad coordinator's own cross-cutting observations.
Any `suppressed` entries explain knowledge overridden by configuration or
layer precedence.

A report can include a code suggestion. **A suggestion is not an applied
change.** Review the explanation first, then request any edits explicitly,
for example: "Apply only the filter fix at line 42 from this report." Continue
using your normal compilation, analyzer, test, and human-review workflow.

## Coverage and limits

The Microsoft broad review composes the 16 Microsoft domains listed below.
The Community Agents review is a separate skill selected by the request, not
a nested part of that coordinator. All current review leaves accept app
folders, files, and diffs; request an Agent SDK review explicitly when that
coverage matters and look for its separate report.

Available knowledge is **not** a promise that every rule will run. Selection
depends on the task, target context, enabled layers, and source evidence.
A whole-folder review is a current-state snapshot: detecting a published API
removal or another comparison-only regression requires an actual baseline.
The corpus is technical AL guidance, not exhaustive functional validation or
AppSource certification.

### Knowledge by domain

Each article describes one concern. Where samples exist, use its linked
`.good.al` and `.bad.al` files. Samples are demonstrations, not a deployable app.

| Domain | Browse knowledge |
| --- | --- |
| Agent SDK | [Agents (Community)](../community/knowledge/agents/) |
| AppSource | [AppSource](../microsoft/knowledge/appsource/) |
| Compatibility | [Breaking changes](../microsoft/knowledge/breaking-changes/) |
| Data modeling | [Data modeling](../microsoft/knowledge/data-modeling/) |
| Error handling | [Error handling](../microsoft/knowledge/error-handling/) |
| Events | [Events](../microsoft/knowledge/events/) |
| Interfaces | [Interfaces](../microsoft/knowledge/interfaces/) |
| Performance | [Performance](../microsoft/knowledge/performance/) |
| Privacy | [Privacy](../microsoft/knowledge/privacy/) |
| Query objects | [Query](../microsoft/knowledge/query/) |
| Security | [Security](../microsoft/knowledge/security/) |
| Style | [Style](../microsoft/knowledge/style/) |
| Telemetry | [Telemetry](../microsoft/knowledge/telemetry/) |
| Testing | [Testing](../microsoft/knowledge/testing/) |
| User interface | [UI](../microsoft/knowledge/ui/) |
| Upgrades | [Upgrade](../microsoft/knowledge/upgrade/) |
| APIs and web services | [Web services](../microsoft/knowledge/web-services/) |

## Permissions and data

The review instructions produce findings, not source edits or deployment.
The host still controls tool permissions: keep approval prompts enabled and
do not grant blanket write or deployment access just to run a review.
BCQuality may write its generated `knowledge-index.json` into its own installed
directory; that is separate from your app's source.

BCQuality is content, not an AI service. Your chosen host and model determine
where source code is processed, what usage is billed, and which data policies
apply. Review those policies before supplying proprietary or customer code.
Installing the plugin does not make an online host run locally or offline.
