---
bc-version: [28..]
domain: agents
keywords: [setrequiresreview, agent-task-message-builder, approval, trusted-input, skip-review]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Skip incoming message review only after the caller validated the payload

## Description

Incoming task messages default to requiring user approval before the agent runs. From 28.1, `Agent Task Message Builder.SetRequiresReview(false)` starts the agent immediately. That is safe only for inputs you already validated in AL (your page action, your posting subscriber). External email or partner payloads are not trusted by default. Analysis Warnings still force a review.

## Best Practice

Leave the default review-on for anything that originated outside your extension. Call `SetRequiresReview(false)` only on messages you constructed from already-authorized BC data.

See sample: [`skip-incoming-review-only-for-trusted-input.good.al`](skip-incoming-review-only-for-trusted-input.good.al).

## Anti Pattern

`SetRequiresReview(false)` on simulated email, incoming webhooks, or user-free text. Detection signal: `SetRequiresReview(false)` next to external content with no prior validation.

See sample: [`skip-incoming-review-only-for-trusted-input.bad.al`](skip-incoming-review-only-for-trusted-input.bad.al).
