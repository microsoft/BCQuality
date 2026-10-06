# Build a lightweight standalone review runner

[Documentation](README.md) | [Architecture](agent-consumption.md)

BCQuality provides review knowledge, routing, execution instructions, and
structured output contracts. It intentionally does not choose models, schedule
agents, retry failures, or collect usage telemetry. A standalone runner can add
those host-specific capabilities without copying Business Central rules out of
BCQuality.

Use the built-in standalone plugin when the host's default execution is
sufficient. Build a runner when you need explicit control over cost, latency,
concurrency, or integration with another review surface.

Start with the [minimal integration example](agent-consumption.md#try-a-minimal-integration)
to connect your agent to the content before adding runner-specific behavior.

## Keep BCQuality current

For plugin installation, use the [quick start](../README.md#quick-start).
For version identifiers, forks, and reproducible snapshots, see
[updates and versions](customizing-bcquality.md#updates-and-versions).

A runner that reads BCQuality from a checkout should pin a commit or release
and upgrade it deliberately. Do not copy knowledge files or action-skill prose
into the runner; doing so creates a second, drifting quality policy.

## Review a complete app folder

For a committed app, generated fixture, or source tree that has no meaningful
diff, supply the app's root directory as `folder-path`. The review scope is
every relevant file below that directory, including `app.json` and AL source.
The folder does not need to be a Git repository.

The [app-review example](../README.md#example-review-a-complete-app-folder)
uses this input through the standalone adapter. Because a folder is a
current-state snapshot, the review must not invent a previous app version
when evaluating comparison-only rules. Entry can return more than one
top-level skill; preserve all reports, including separately dispatched
Community reviews, rather than assuming the Microsoft coordinator is the
only result.

## Minimal runner flow

1. Give the agent the review input and a task context containing the user's
   actual goal, available input types, and any known BC applicability
   dimensions.
2. Invoke `skills/entry.md`. Entry prepares the knowledge index and returns the
   action skills to run. Do not reproduce its routing logic.
3. Execute every dispatched action skill with the exact input subset in its
   dispatch record. Read `skills/read.md` and `skills/do.md` on demand.
4. When an action skill declares `sub-skills`, resolve its ordered leaf slots
  with `tools/Resolve-SkillWorklist.ps1`, passing the enabled layers and
  disabled skill paths from the task context. Execute every resolved leaf as
  a discrete invocation. Leaves are independent and may be scheduled serially
  or concurrently. Before dispatch, preserve the final ordered selection and
  legitimate configuration/input-compatibility exclusions as a private expected
  composition artifact; see [composition acceptance](#composition-acceptance).
5. Capture the exact Task return as the immutable raw audit payload and primary
   transport. Preserve it unchanged in private artifacts or host logs. Before
   the full DO acceptance gate, create a normalized candidate only for DO's
   bounded citation-ID and optional-range cases after strict JSON, full
   structural schema, and reference-integrity checks. Record `normalizedIds`
   and `removedRanges` separately in private telemetry, and accept the
   candidate only if the entire copy passes the unchanged strict gate.
  Use `tools/Validate-FindingsReport.ps1`, passing the
  exact source paths and fully retrieved article paths; pass `-SkillKind super`
  and `-ExpectedCompositionPath` for the final rolled-up report. The accepted report contains no undeclared
  telemetry fields.
6. Collect each accepted findings-report into `sub-results` in the declared
   `sub-skills` order, not completion order. Run the super-skill self-review
   only after all leaves have finished.
7. Apply the DO composition, failure, deduplication, reference-integrity, and
   outcome rules. Return strict JSON before rendering it for people or another
   system.

The runner must never inspect the diff to skip a review domain. A leaf decides
its own task-level applicability and reports `not-applicable` or
`no-knowledge`.

## Composition acceptance

The findings-report validator requires PowerShell 7.5 or later to preserve
literal JSON strings with `ConvertFrom-Json -DateKind String`.

A report can be internally consistent while omitting a selected review. Bind
the final acceptance gate to the host's selection, not just the returned
reports. The private JSON input to `-ExpectedCompositionPath` follows the
[DO consumer acceptance contract](../skills/do.md#consumer-acceptance-gate).
For example, if style is selected and security was disabled:

```json
{
  "superSkill": { "id": "al-code-review", "version": 1 },
  "subSkills": [{ "id": "al-style-review", "version": 1 }],
  "skipped": [{ "id": "al-security-review", "version": 1, "reason": "configuration" }],
  "acceptedResults": []
}
```

Build this artifact from `Resolve-SkillWorklist.ps1` and the input-compatibility
decision before dispatch. Resolver `skipped` entries have no version: enrich
them from the declared skill's indexed version. Move an input-incompatible
selected slot to `skipped` with its selected version and `not-applicable`
reason; never use source content or later model output to make that decision.
Keep paths, layers, and other resolver metadata if useful for private audit.
Do not add the artifact to the findings-report or overwrite it to hide an
unfinished invocation. Preserve it with the run's raw payloads.

Initialize `acceptedResults` before dispatch. After accepting a leaf, save its
exact accepted copy (including any permitted normalization) in an immutable
host-owned file outside worker/composer write access. Append only its capture
to `acceptedResults`, for example:

```json
{"id": "al-style-review", "version": 1, "reportPath": "accepted/style.json"}
```

`reportPath` may be absolute or relative to the composition artifact's directory.
Capture a host-created failed validation report the same way. Never construct
these captures from the composed `sub-results` or permit the composing model
to supply or alter them. Keep the original selection and exclusions unchanged.

The gate rejects repeated or unexpected leaf IDs, wrong selected versions,
reordered results, fabricated or missing exclusions, and uncaptured or altered
leaf content. JSON property order is immaterial; array order, field presence,
types, and values must match. Every captured leaf must appear in `sub-results`.
If selected leaves remain unfinished, the report must be `partial` with a non-failed returned
report, otherwise `failed`; name every unfinished leaf ID exactly in
`outcome-reason`. Top-level `from-sub-skill: "agent"` findings are rejected
while selected leaf results are missing.
Do not fabricate leaf reports or use configuration skips for budget exhaustion.
Wait for started invocations to finish; omit the self-review if the selected
composition remains incomplete. Coverage still sums the non-failed leaf
knowledge worklists, not the number of selected leaf slots.

Calls without the expected artifact remain supported for structural/semantic
validation, but cannot certify that a composed review covered its selection.
They also cannot bind nested leaves to the host's accepted outputs.
They still reject duplicate leaf IDs and returned-and-skipped conflicts.

## Runner-owned choices

Keep these settings and behaviors outside BCQuality:

- coordinator and leaf models;
- serial or concurrent scheduling and maximum concurrency;
- retries, timeouts, and rate-limit handling;
- token, cost, duration, and actual-concurrency telemetry;
- conversion of the findings report into Markdown, annotations, or PR
  comments.

Model selection and requested concurrency are deployment choices, not review
rules. Evaluate them against representative applications before making them a
default. Report actual usage and concurrency only when the host exposes native
evidence; do not infer them from the requested profile.

## Failure and output checklist

A compatible runner:

- invokes every worklisted leaf exactly once unless a documented retry replaces
  a failed attempt;
- resolves same-ID leaf implementations by `custom > community > microsoft`,
  preserves declared slot order, and falls back when a higher layer is disabled;
- keeps leaf contexts isolated and passes only the inputs they declare;
- preserves each raw Task return unchanged for audit and distinguishes it from
  any normalized accepted copy;
- removes only an optional range whose positive integer bounds contain the
  primary line but start before it, and only when the complete report has no
  other defect and the finding has no `suggested-code`;
- records normalization only in private runner telemetry and never adds fields
  to the findings-report;
- rejects reversed, invalid, or out-of-bounds ranges, range mismatches attached
  to `suggested-code`, and every repair outside DO's bounded exception;
- preserves every leaf report, including failed reports, in `sub-results`;
- excludes unreliable findings from failed leaves and returns `partial` when
  only part of the review is reliable;
- orders `sub-results` by the declared worklist and orders rendered findings
  deterministically;
- validates composition against the host-owned selection, and reports selected
  leaves left unfinished as incomplete rather than clean or configured away;
- calculates top-level severity counts from deduplicated top-level findings,
  not by summing leaf counts;
- preserves knowledge paths verbatim and verifies references before publishing;
- records the BCQuality commit or release used for the run.

A CI integration, custom agent, or small host-native plugin can implement this
runner contract. These remain optional consumers: BCQuality's knowledge and
skills stay independent of their orchestration choices.
