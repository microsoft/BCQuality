---
bc-version: [all]
domain: performance
keywords: [job-queue, background-session, guiallowed, confirm, runmodal, client-callback]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Job queue handlers must not require user interaction

> Contributions welcome — open a PR to refine or extend this article.

## Description

A job queue handler runs in a background session with no client UI. Calls that require a client callback, such as `Confirm`, `Page.RunModal`, `Report.RunModal`, upload, or download, can stop the job with a non-retriable callback error. `Message` is suppressed and logged by the server, so it cannot communicate a result to the user who scheduled the job.

## Best Practice

Make a dedicated job queue entry point non-interactive. Validate parameters and data in AL, persist business-visible status when needed, and let failures propagate to the job queue log. If one procedure genuinely serves both foreground and background callers, isolate optional UI-only behavior behind `GuiAllowed`; do not use the guard to silently skip a decision that the operation requires.

See sample: `job-queue-handlers-must-not-require-ui.good.al`.

## Anti Pattern

Calling `Confirm`, `Page.Run`, `Page.RunModal`, `Report.Run`, `Report.RunModal`, `Hyperlink`, `File.Upload`, or `File.Download` from a codeunit run by the job queue. Another signal is using `Message` as the only success or failure notification: no user is attached to receive it.

See sample: `job-queue-handlers-must-not-require-ui.bad.al`.