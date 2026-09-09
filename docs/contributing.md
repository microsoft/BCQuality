# Contributing to BCQuality

[Documentation](README.md) | [Knowledge by domain](using-bcquality.md#knowledge-by-domain) | [Authoring reference](../skills/write.md)

Partners are welcome to contribute shared knowledge, examples, skills, and
documentation. To report an incorrect finding without preparing a change,
use the [support guide](troubleshooting.md#reporting-a-problem).

## What belongs here

BCQuality is a remedial knowledge base. A knowledge file exists because a
capable LLM **would get something wrong, or miss something, without it**, not
simply because the topic is important. Apply this admission test:

> If this file did not exist, would a modern LLM reviewing or generating BC
> code make a mistake this file would have prevented?

Good candidates encode a BC-specific mechanic that models get wrong, a
version-dependent behavior, or a misleading interpretation of an analyzer
rule. For example:

- [SetLoadFields and filters can be called in either order](../microsoft/knowledge/performance/use-setloadfields-for-partial-records.md): their relative order does not change the projection. This prevents an incorrect performance finding.
- [Boolean page record triggers default to true](../microsoft/knowledge/error-handling/page-boolean-triggers-default-to-true.md): omitting an explicit `exit(true)` is not itself a defect.
- [Page fields can inherit captions](../microsoft/knowledge/style/caption-required-on-page-fields.md): an omitted page-level property is not sufficient evidence that a caption is missing.

Generic advice such as "use HTTPS," "do not hardcode secrets," or "keep
transactions short" does not earn a separate knowledge file merely by being
sound advice. Negative clarifications that prevent false positives are as
valuable as rules that catch defects.

**Skills hold discovery and execution mechanics; knowledge files hold BC
facts.** Correct or extend a knowledge article when a BC fact is missing or
wrong. Do not hide that fact in a skill's instructions. A genuine routing,
input, or output-contract problem belongs in the skill instead.

## Choose the right destination

| Change | Destination |
| --- | --- |
| Knowledge in a Microsoft-owned review domain | `microsoft/knowledge/<domain>/` |
| Knowledge accompanying a Community-owned skill | `community/knowledge/<domain>/` |
| Company-specific policy or an override | `custom/` in your own fork; never an upstream contribution |
| Partner instructions or how-to guidance | `docs/`, linked from the documentation index |

Layer ownership follows the skill and domain, **not your employer**. For
example, a partner's performance clarification belongs beside the Microsoft
performance skill's corpus. Do not use Community as a staging area for an
already Microsoft-owned domain. A split may exist briefly during promotion,
but the skill and its canonical corpus should move together.

Upstream automatically closes PRs adding custom content. Follow
[Customizing BCQuality](customizing-bcquality.md) for organization-only rules.
Do not introduce a new shared domain without the action skill that consumes
it and the matching evaluation samples.

## Author a knowledge article

Read [READ](../skills/read.md) for the schema and
[WRITE](../skills/write.md) for the authoring rules. Use an existing article
in the same domain as a starting point, then remove unrelated guidance.

Every article has six required frontmatter fields: `bc-version`, `domain`,
`keywords`, `technologies`, `countries`, and `application-area`.
`domain` must match its containing directory. Keep one concern per file,
ideally under 50 lines and no more than 100.

`Description` is required. Put recommendations in `Best Practice` and mistakes
to catch in `Anti Pattern`; those are the normative sections. Explain
legitimate exceptions so a reviewer does not turn a useful rule into a false
positive. Code fences are not allowed in knowledge articles.

### Sources and examples

When adding or changing a platform claim, link the authoritative source that
supports it, preferably the specific Microsoft Learn API/property page or a
public source definition. State version constraints when they matter. Avoid
"upstream guidance says" without a link. If the source is unavailable or the
guidance is organization policy or empirical observation, say so explicitly
rather than presenting it as an official platform guarantee.

Place source links in a short `References` section or beside the relevant
claim. References do not replace the rule: keep all load-bearing guidance in
the normative sections. This adds traceability without adding frontmatter
fields or changing the schema.

Put demonstration code in sibling files:

```text
<slug>.md
<slug>.good.al
<slug>.bad.al
```

Reference each sample with a clickable link whose label retains the filename,
for example `` [`<slug>.good.al`](<slug>.good.al) `` with your actual slug.
One or both samples are optional for an individual article; every review
domain must have at least one complete good/bad pair for evaluation. Samples
are self-contained demonstrations, not copied Base Application source and
not a deployable or compiled application.

## Before opening a PR

From your BCQuality checkout, use the existing validators. The Python
validator needs Python and PyYAML; the fixture harness needs PowerShell 7.
If PyYAML is not installed in your development environment, install it with
`python -m pip install pyyaml`.

```powershell
python .github\scripts\validate_frontmatter.py --root .
pwsh .\tools\Test-ReviewFixtures.ps1 -Root .
```

The first command checks schema, sections, naming, sample references, and
skill registration. The second checks that every review leaf has a valid
positive/clean sample pair. Neither proves a model will find every defect.
See [evaluation](../evaluation/README.md) for optional model-based scoring.

In the PR description, explain the mistake being prevented, supporting
evidence, applicable BC versions, and why the chosen domain owns it. For a
false positive, include the valid pattern and the incorrect finding being
prevented. Check that links and samples open from the rendered article.

Schema and stable protocol changes require approval from both maintainers.
Avoid repeating schema or contract definitions in new guides: link the
canonical READ, DO, WRITE, or Entry section instead.

## Content releases

Maintainers cut content releases on demand, roughly monthly, using the
`Release version` workflow on `main`. It tags the selected commit as
`v{major}.{minor}`; it does not update the plugin manifest.

Use a minor bump for normal content updates and a major bump for breaking
changes. The minor is a monotonic counter: it increments across releases and
does **not** reset on a major bump. See
[updates and versions](customizing-bcquality.md#updates-and-versions) for the
separate plugin, content, and skill version identifiers.
