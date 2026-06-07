---
kind: action-skill
id: al-multitenancy-reviewer
version: 1
title: AL multi-tenancy review
description: Audits AL data paths for cross-tenant and cross-company leak risk in SaaS, and emits a findings report.
inputs: [pr-diff, file-path, repository]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL multi-tenancy review

Audits Business Central AL (and any companion API in the same repository) for code paths that resolve data without correctly scoping by tenant and company. The failure mode is silent: a query that returns another tenant's data, an endpoint that resolves a record by primary key without scoping the caller's company, or a Job Queue codeunit that processes rows from the wrong company. These defects do not surface in single-tenant dev sandboxes; they appear in SaaS as a cross-tenant data leak. This is a leaf action skill: it invokes no sub-skills.

An orchestrator invokes this skill with a `pr-diff`, a `file-path`, or a `repository`. It produces a single JSON document conforming to the DO output contract.

## Source

Read the BCQuality knowledge index once (the `knowledge-index.json` Entry's preparation step regenerates over the live, already-filtered clone). Take the index entries whose `domain` is `security` or `integration` as the citable candidate set across every enabled layer; multi-tenant scoping is a security-and-integration concern, so a finding that matches a curated rule (for example, permission scoping or data-classification guidance) cites that file. Do not open individual article files at this step; open an article's full body only once it enters the Worklist below. Where no curated rule covers a concrete tenant-scoping defect, this skill emits an agent finding within its own domain (see Action).

## Relevance

Apply the frontmatter matching rules defined in READ against the task context:

- `bc-version`: the target BC version from the branch `app.json`, or `unknown` if unavailable.
- `technologies`: `[al]`.
- `countries`: the consuming app's declared countries, or `unknown`.
- `application-area`: the application areas of the changed objects, or `unknown`.

Discard files that are not applicable. Retain conditionally applicable files (any dimension `unknown`) only when configuration permits; findings derived from them have `confidence` no higher than `medium`, and the finding `message` names the unknown dimensions.

## Worklist

Narrow to the code paths where tenant or company scope is established or relied upon:

- Codeunits runnable as a Job Queue entry (`TableNo = "Job Queue Entry"`) and any `[ServiceEnabled]` web-service codeunit.
- Procedures that call `CompanyName()`, `Company.Get`, set a `Company` filter, or resolve a record by `SystemId` across companies.
- Reads or writes to tables classified `CustomerContent` or `OrganizationIdentifiableInformation`, especially without a company filter.
- Outbound `HttpClient` calls to a companion API and any sibling API endpoints (`Endpoints/*.cs`, `routes/*.ts`) in the same repo.
- `Session.LogMessage` / Application Insights calls that omit a tenant custom dimension.

A curated knowledge file enters the worklist when its `keywords` intersect these tokens. Read its full `## Best Practice` / `## Anti Pattern` body only after it makes the worklist. Resolve layer-precedence conflicts per READ and record dropped files in `suppressed`.

## Action

For each worklisted code path, check that tenant and company scope is established before data is resolved, that production paths never fall back to a default tenant, that cross-company writeback verifies the caller's company on both sides, that a company filter is present on every `CustomerContent` query, that `SystemId` resolution is company-scoped for per-company tables, that outbound calls carry tenant context the receiver validates, that any `Session.Companies` traversal is intentional and commented, and that logs carry the tenant id.

When a defect matches a curated `security` or `integration` knowledge file, emit a knowledge-backed finding citing that file: `severity` up to `blocker` only when the file states a platform-level guarantee, otherwise `major`; `id` equal to the file path; `confidence` `high` for an unambiguous match. When no curated file covers a concrete, demonstrable tenant-scoping defect, emit an agent finding within this skill's domain: `references: []`, `id` slug prefixed `agent:`, `confidence` capped at `medium`, `severity` capped at `minor`, and a self-contained `message` describing the leak path and a concrete fix (for example, "filter the pull query by the caller's company id"). Hold every agent candidate to the precision bar in `skills/do.md`: steelman that the cross-company traversal is intentional before emitting, and omit when in doubt. Set `suggested-code` when the fix is mechanical (adding a missing `SetRange(Company, ...)` or a company-id query parameter); otherwise set `suggested-code-omission-reason`.

Outcome selection: `completed` when every worklist item was evaluated (including an empty `findings`); `no-knowledge` when no curated knowledge survived and no agent finding was raised; `not-applicable` when the task has no AL data path to audit; `partial` or `failed` per the DO contract with `outcome-reason`.

## Output

Output conforms to the DO output contract. Findings without a knowledge file are agent findings (`references: []`, `agent:` id, severity capped at `minor`); findings citing a `security` or `integration` file carry that file path as `id` and primary reference.
