---
kind: meta-skill
id: read
version: 1
title: Schema + Use — how to read a knowledge file
---

# READ

Every consumer of BCQuality — an agent, an action skill, a human reviewer — reads this file first. It defines what a knowledge file is, what fields it contains, what they mean, and how to reconcile multiple files.

This contract is stable. Changes require a PR approved by both maintainers.

## What a knowledge file is

A knowledge file is a single markdown file that covers **one concern** in Business Central development. It has:

- A YAML frontmatter block with the fields below. All fields are required.
- A `## Description` section. Required.
- Optional sections — typically `## Best Practice` and `## Anti Pattern`, but any `##` section is permitted.
- No fenced code blocks. Sample code lives in separate sample files referenced by path.

A file that violates any of these rules is invalid and MUST be skipped by consumers. Do not attempt to partially parse invalid files.

## Frontmatter schema (v1)

```yaml
---
bc-version: [26, 27, 28]               # or the range shorthand [26..28]
domain: performance
keywords: [query, filtering, partial]
technologies: [al]
countries: [w1]
application-area: [all]
---
```

All six fields are required. Missing or empty fields invalidate the file.

### Fields

**`bc-version`** — Array. The Business Central major versions this file applies to. Two forms are accepted:

- Explicit list: `[26, 27, 28]`.
- Range shorthand: `[26..28]` means every integer from 26 through 28 inclusive.

Consumers MUST expand ranges to the full set before comparison.

**`domain`** — String. A single domain tag that places the file within a broader area of concern. Standard values include `performance`, `security`, `ux`, `telemetry`, `testing`, `api`, `pipelines`, `finance`, `supply-chain`, `manufacturing`, `jobs`. New domains may be introduced by contributors; no closed enumeration is enforced at the schema level. Consumers MUST treat unknown domains as valid.

**`keywords`** — Array of strings. Free-text tags used for retrieval. Between 3 and 10 tags is typical. Tags are lowercase, kebab-case, and describe the concern in the vocabulary an engineer or agent would search for.

**`technologies`** — Array of strings. The technologies the file applies to. Examples: `al`, `javascript`, `powershell`, `kql`, `azure-devops`, `github-actions`. A file that applies across technologies lists all of them explicitly. The sentinel `all` is not permitted for this field.

**`countries`** — Array of strings. ISO 3166-1 alpha-2 country codes (lowercase: `us`, `de`, `dk`) for localization-specific guidance. Use the sentinel `[w1]` for guidance that applies worldwide. `[w1]` is mutually exclusive with country codes; do not combine.

**`application-area`** — Array of strings. The BC application areas the file applies to. Examples: `finance`, `manufacturing`, `jobs`, `warehousing`, `service`. Use the sentinel `[all]` for guidance that applies regardless of application area. `[all]` is mutually exclusive with specific areas.

## Sections

**`## Description`** is required. It states the concern: what the topic is and why it matters. It is the primary retrieval target when a consumer decides whether a file is relevant.

Two further sections are recognized as **normative** — consumers MAY rely on their content for conflict detection and guidance extraction:

- **`## Best Practice`** — the recommended approach.
- **`## Anti Pattern`** — what to avoid and the reasoning.

Any other `##` section is permitted and is **non-normative**: consumers MUST NOT treat its contents as binding guidance. Non-normative sections (for example `## See also` or `## Applies to`) are for human context; they are ignored by conflict detection and by the filtering rules below. Consumers MUST NOT fail on unknown sections.

## Layer precedence

A knowledge file lives in one of three layers, determined by its path:

- `/microsoft/knowledge/**` — platform-endorsed.
- `/community/knowledge/**` — community-curated.
- `/custom/knowledge/**` — partner or customer overrides (typically in a consumer repo, not in BCQuality).

The default consumption model is **additive**: an action skill sees files from every enabled layer and may surface findings from all of them. A consumer MAY be configured to disable a layer; in that case, files in the disabled layer are invisible to the consumer.

When two files give **directly contradictory normative guidance**, the conflict is resolved by layer precedence:

1. `/custom/` wins over `/microsoft/` and `/community/`.
2. `/microsoft/` wins over `/community/`.

A conflict exists when both of the following are true:

- **Applicability overlaps.** The files' frontmatter filters (`bc-version`, `technologies`, `countries`, `application-area`) have a non-empty intersection under the matching rules below. `domain` is a retrieval aid; it is not part of the applicability test.
- **Normative guidance contradicts.** Content in the `## Best Practice` or `## Anti Pattern` sections is logically incompatible (one recommends what the other forbids, or vice versa). Non-normative sections are not considered.

Conflict detection is the consumer's responsibility; BCQuality does not enforce conflict-free content. When a consumer suppresses a losing file due to precedence or configuration, it **MUST** record the suppression in its output (see DO) so reviewers can see what was overridden.

## Frontmatter matching semantics

When a consumer filters or matches files against a task context, these rules apply:

- **`bc-version`** — the target BC version MUST be an element of the file's expanded `bc-version` set. Range shorthand (`[26..28]`) MUST be expanded before comparison.
- **`technologies`** — non-empty intersection between the task's technologies and the file's technologies. There is no sentinel for this field.
- **`countries`** — the file matches if its set contains `w1`, or if there is a non-empty intersection with the task's countries.
- **`application-area`** — the file matches if its set contains `all`, or if there is a non-empty intersection with the task's application areas.

A file is **applicable** to a task when all four rules match. Applicability is also the basis for conflict detection above.

### When the task context is partial

A task context may omit one or more dimensions (for example, a skill invoked against a raw file path with no known target BC version). For any omitted dimension:

- If the file's value for that dimension is a universal sentinel (`w1` for countries, `all` for application-area), the rule matches.
- Otherwise the rule is treated as **unknown**, not as a match and not as a failure.

A file with any `unknown` rule is **conditionally applicable**. A consumer MAY include conditionally applicable files in the worklist; if it does, every finding derived from such a file MUST have `confidence` no higher than `medium` and MUST record the unknown dimensions in the finding's `message`. A consumer MAY be configured to exclude conditionally applicable files entirely.

Consumers MUST NOT silently treat missing context as a match.

## Citing a knowledge file

A consumer that produces output referencing a knowledge file MUST cite it by its repo-relative path (for example, `microsoft/knowledge/performance/filter-before-find.md`). Line numbers are not stable references; use the file path only. If a commit SHA is available to the consumer, it SHOULD be included alongside the path.

## Retrieval workflow

The standard workflow for finding applicable files:

1. Collect candidates by path (typically by `domain` subfolder, across enabled layers).
2. Filter by frontmatter using the matching rules above. Files that are not applicable are discarded.
3. Rank or narrow by `keywords` relevance to the task.
4. Resolve conflicts via layer precedence.

Steps 1–3 are deterministic; step 4 is applied only when conflicts are detected.
