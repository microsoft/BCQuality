---
kind: meta-skill
id: write
version: 1
title: New Knowledge — how to author a knowledge file
---

# WRITE

Anyone — human or agent — adding a knowledge file to BCQuality follows this guide. READ is the format specification; WRITE is the authoring guide. This file does not restate the schema; consult READ for field-by-field semantics.

## Before you start

Read `skills/read.md` first. A file that does not conform to READ will be rejected. WRITE assumes READ is already understood.

## The atomicity rule

One knowledge file covers **one concern**. If two ideas would share a file, split them into two files and cross-reference from the Description. A good test: could an action skill reasonably want to cite one without the other? If yes, they are two concerns.

Symptoms that a file is trying to be two:

- Two Best Practice sections.
- A Description that uses "and" to join two topics.
- `keywords` that span two unrelated vocabularies.

## Size

Target under 100 lines. Ideal under 50. Long files almost always mean two concerns; the fix is to split, not to compress.

## Sections

**Description** is the only required section and the one that matters most. It states the concern and why it matters in two to five sentences. It is the primary retrieval target — write it as if a skill is deciding whether to load this file based on this text alone.

**Best Practice** is optional but recommended when the concern has a clear preferred approach. State the approach and the reasoning. Keep it to the *what* and *why*; the *how* (code) belongs in a sample file.

**Anti Pattern** is optional but recommended when the concern has a common wrong approach. State the pattern, the consequence, and the signal a reviewer or agent can use to detect it. Anti Pattern sections are highly actionable for review skills; write them with detection in mind.

Custom `##` sections are permitted when they serve the concern (for example, `## Applies to` for scope caveats or `## See also` for related files). Consumers are not required to understand them, so do not put load-bearing content there.

## No fenced code blocks

Knowledge files do not contain code. Samples live in separate files under `/samples/` (or the layer's sample folder) and are referenced by path. This keeps knowledge files retrieval-friendly and prevents code from drifting out of sync with BC platform changes buried inside prose.

## Choosing frontmatter values

**`bc-version`.** Claim only the versions you have evidence for. If the guidance is known to apply from BC 24 onward and you have tested against 26–28, write `[26..28]`, not `[24..28]`. Under-claim; a future contributor can widen the range.

**`domain`.** Pick one. If two fit, the file is probably two concerns. If no existing domain fits, introduce a new one — domains are open. Prefer existing domains when they are a reasonable fit, to keep retrieval predictable.

**`keywords`.** Three to ten, lowercase, kebab-case. Write them as the search terms an engineer or agent would use to find this concern. Include synonyms when a concept has multiple common names (for example, `find-set` and `findset`). Do not duplicate the domain or title as a keyword.

**`technologies`.** List every technology the guidance touches, explicitly. Do not use a sentinel; there is no `[all]` for technologies. If the guidance is truly technology-agnostic, the file probably belongs in a different repository.

**`countries`.** Default to `[w1]` (worldwide). Use ISO country codes only when the guidance is specific to a localization — tax regulations, electronic invoicing formats, country-specific VAT rules. `[w1]` is mutually exclusive with country codes.

**`application-area`.** Default to `[all]`. Restrict only when the guidance is specific to a BC application area — posting routines in Finance, lot tracking in Warehouse Management. `[all]` is mutually exclusive with specific areas.

## File naming

`kebab-case.md`. The name should echo the concern: `filter-before-find.md`, `avoid-implicit-commit.md`, `telemetry-for-failed-posts.md`. Avoid generic names (`performance.md`) and version numbers in the name.

## Choosing a layer

- **`/microsoft/knowledge/<domain>/`** — platform-endorsed guidance. Authored or approved by the BC platform team. Use this layer only when the guidance reflects a platform guarantee or official recommendation.
- **`/community/knowledge/<domain>/`** — shared community patterns. The default layer for contributions from outside the platform team. Content here can be promoted to `/microsoft/` once it proves itself.
- **`/custom/knowledge/<domain>/`** — partner or customer overrides. Generally does not appear in the BCQuality repository itself; `/custom/` lives in consumer repositories.

## Pre-PR checklist

Before opening a pull request:

- Frontmatter has all six required fields with valid values (see READ).
- The file has a `## Description` section.
- No fenced code blocks.
- File is under 100 lines.
- File covers one concern.
- File is in the correct layer and domain folder.
- Name is kebab-case and descriptive.

Agents scaffolding new files SHOULD run this checklist programmatically before emitting the file.
