---
bc-version: [27..]
domain: agents
keywords: [analyzeagenttaskmessage, agent-annotation, error, warning, setrequiresreview]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AnalyzeAgentTaskMessage: Error stops the task; Warning still requires review

## Description

`IAgentTaskExecution.AnalyzeAgentTaskMessage` runs on inbound and outbound messages. An Error annotation stops processing. A Warning annotation requests user intervention. If analysis returns Warning, the platform still requires approval even when the incoming message used `SetRequiresReview(false)`. Output text can be rewritten here (signature, redaction).

## Best Practice

Validate inbound payloads in analysis: Error when the task must not run; Warning when a human must confirm. For outbound messages, adjust text in this method rather than in a later subscriber. Do not rely on skip-review to bypass warnings.

See sample: [`analyze-message-error-stops-warning-forces-review.good.al`](analyze-message-error-stops-warning-forces-review.good.al).

## Anti Pattern

Ignoring analysis entirely, or emitting Warning while documenting that `SetRequiresReview(false)` means unattended run. Detection signal: empty `AnalyzeAgentTaskMessage` plus skip-review on external input.

See sample: [`analyze-message-error-stops-warning-forces-review.bad.al`](analyze-message-error-stops-warning-forces-review.bad.al).
