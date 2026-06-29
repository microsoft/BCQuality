---
bc-version: [all]
domain: testing
keywords: [handlerfunctions, handler, ui-path, not-executed, wiring]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep [HandlerFunctions] in sync with the UI the path actually hits

## Description

`[HandlerFunctions]` is a two-sided contract with the executed code path. Every UI call the path raises must have a handler named in the list, and every handler named in the list must be exercised by the path. Miss a handler the path hits and the platform throws an unhandled-UI error. Name a handler the path never reaches and the platform fails the test with a "handler function was not executed" error at the end of the method. Both are runtime failures. So the list must track the scenario's real UI interactions exactly — not a superset "just in case", not a subset that happens to work today.

## Best Practice

List precisely the handlers the scenario triggers, comma-separated, in any order. When a path raises both a `Confirm` and a `Message`, register both: `[HandlerFunctions('ConfirmHandlerYes,PostMessageHandler')]`. When you change the scenario so it no longer hits a dialog, remove that handler from the list. Treat "handler function was not executed" as a signal that the path diverged from what the test claims to exercise, and reconcile the two.

## Anti Pattern

Listing only one of the handlers a path needs — the other UI call goes unhandled and aborts — or padding the list with a handler the path never reaches, which fails the test for the unused handler. Either way the attribute lies about the path, and the failure points at wiring rather than behavior.

See samples: `handlerfunctions-attribute-must-match-ui-path.good.al`, `handlerfunctions-attribute-must-match-ui-path.bad.al`.
