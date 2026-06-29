---
bc-version: [all]
domain: testing
keywords: [handler, ui, confirm, unhandled-ui, headless]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Intercept every UI call with a registered test handler

## Description

Any platform UI interaction the code under test triggers — `Confirm`, `Message`, error dialogs, `Page.Run`/`RunModal`, `Report.Run`/`RunModal`, request pages, `StrMenu`, `Hyperlink`, `Notification.Send` — must be intercepted by a handler function carrying the matching handler attribute and registered on the test method via `[HandlerFunctions]`. A test runs headless: there is no interactive user to dismiss a dialog. If the executed path raises a UI call with no registered handler, the platform throws an "unhandled UI" error and aborts the method. This is a runtime failure, not an assertion failure — the test never reaches its verification, so a reviewer sees an infrastructure error instead of a verdict on the behavior under test.

## Best Practice

For each UI call the scenario can hit, add a handler procedure with the correct attribute (`[ConfirmHandler]`, `[MessageHandler]`, `[StrMenuHandler]`, `[ModalPageHandler]`, `[ReportHandler]`/`[RequestPageHandler]`, `[SendNotificationHandler]`, `[HyperlinkHandler]`) and name it in the test's `[HandlerFunctions(...)]` list. The handler decides the response — `[ConfirmHandler]` sets `Reply`, a page handler fills and runs the test page — so the path completes deterministically without human input.

See sample: `ui-calls-require-test-handlers.good.al`.

## Anti Pattern

Writing a `[Test]` method that drives code which calls `Confirm` (or any UI) without declaring a handler. It may pass when run interactively in the client but fails in CI with an unhandled-UI runtime error, looking like a flaky pipeline rather than the missing-handler wiring it actually is.

See sample: `ui-calls-require-test-handlers.bad.al`.
