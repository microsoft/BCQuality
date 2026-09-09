# Build a lightweight standalone review runner

BCQuality provides review knowledge, routing, execution instructions, and
structured output contracts. It intentionally does not choose models, schedule
agents, retry failures, or collect usage telemetry. A standalone runner can add
those host-specific capabilities without copying Business Central rules out of
BCQuality.

Use the built-in standalone plugin when the host's default execution is
sufficient. Build a runner when you need explicit control over cost, latency,
concurrency, or integration with another review surface.

## Keep BCQuality current

Install or update the plugin with GitHub Copilot CLI:

```shell
copilot plugin install microsoft/BCQuality
copilot plugin update bcquality
```

A runner that reads BCQuality from a checkout should pin a commit or release
and upgrade it deliberately. Do not copy knowledge files or action-skill prose
into the runner; doing so creates a second, drifting quality policy.

## Review a complete app folder

For a committed app, generated fixture, or source tree that has no meaningful
diff, supply the app's root directory as `folder-path`. The review scope is
every relevant file below that directory, including `app.json` and AL source.
The folder does not need to be a Git repository.

With the standalone plugin installed, start a fresh Copilot session in the app
folder and ask:

> Use the installed `al-code-review` skill to review the complete Business
> Central app in this folder. Execute every dispatched review domain and return
> the complete BCQuality findings report.

The adapter maps this request to `folder-path`; Entry routes it to the broad
review super-skill. Because a folder is a current-state snapshot, the review
must not invent a previous app version when evaluating comparison-only rules.

## Minimal runner flow

1. Give the agent the review input and a task context containing the user's
   actual goal, available input types, and any known BC applicability
   dimensions.
2. Invoke `skills/entry.md`. Entry prepares the knowledge index and returns the
   action skills to run. Do not reproduce its routing logic.
3. Execute every dispatched action skill with the exact input subset in its
   dispatch record. Read `skills/read.md` and `skills/do.md` on demand.
4. When an action skill declares `sub-skills`, execute every relevant leaf as a
   discrete invocation. Leaves are independent and may be scheduled serially
   or concurrently.
5. Collect each complete findings-report into `sub-results` in the declared
   `sub-skills` order, not completion order. Run the super-skill self-review
   only after all leaves have finished.
6. Apply the DO composition, failure, deduplication, reference-integrity, and
   outcome rules. Return strict JSON before rendering it for people or another
   system.

The runner must never inspect the diff to skip a review domain. A leaf decides
its own task-level applicability and reports `not-applicable` or
`no-knowledge`.

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
- keeps leaf contexts isolated and passes only the inputs they declare;
- preserves every leaf report, including failed reports, in `sub-results`;
- excludes unreliable findings from failed leaves and returns `partial` when
  only part of the review is reliable;
- orders `sub-results` by the declared worklist and orders rendered findings
  deterministically;
- calculates top-level severity counts from deduplicated top-level findings,
  not by summing leaf counts;
- preserves knowledge paths verbatim and verifies references before publishing;
- records the BCQuality commit or release used for the run.

BC-ALAgents, AL-Go, a Copilot custom agent, or a small host-native plugin can
all implement this runner contract. They remain optional consumers:
BCQuality's knowledge and skills stay independent of their orchestration
choices.
