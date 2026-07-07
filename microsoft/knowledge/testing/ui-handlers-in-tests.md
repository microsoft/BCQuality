---
bc-version: [all]
domain: testing
keywords: [handler, handlerfunctions, confirm, message, strmenu, variable-storage, enqueue, unhandled-ui]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Wire and verify UI handlers with enqueue-driven expectations

## Description

A test runs headless: there is no interactive user to answer a dialog. Every UI call the executed path raises — `Confirm`, `Message`, error dialogs, `Page.Run`/`RunModal`, `Report.Run`/`RunModal`, request pages, `StrMenu`, `Notification.Send` — must be intercepted by a handler carrying the matching attribute (`[ConfirmHandler]`, `[MessageHandler]`, `[StrMenuHandler]`, `[ModalPageHandler]`, …) and named in the method's `[HandlerFunctions(...)]`. The list is a two-sided contract: raise a UI call with no listed handler and the platform aborts with an *unhandled UI* error; list a handler the path never hits and it fails with *"handler function was not executed"*. Both are runtime failures — the test never reaches its verdict, so a reviewer sees an infrastructure error instead of a result on the behavior under test.

Getting the handler *present* is only half the job; the handler must also verify the *right* dialog fired the *right* number of times. Do that by driving handlers from the test, not by hardcoding answers inside them.

## Best Practice

Make the test own the expectations and the handlers consume them. Before acting, the test `Enqueue`s — in interaction order — the expected text (a stable substring) and any reply each handler must return. The handler `Dequeue`s the expected text, verifies it with the purpose-built asserts (`Assert.ExpectedMessage`, `Assert.ExpectedConfirm`, `Assert.ExpectedStrMenu` — which match on a fragment, not the full localized caption), then `Dequeue`s and returns its reply. Finish the test body with `LibraryVariableStorage.AssertEmpty` to prove every enqueued interaction fired exactly once, and start each test with an `Initialize` that calls `LibraryVariableStorage.Clear` so a value leaked by an earlier test cannot cascade. List in `[HandlerFunctions]` precisely the handlers the scenario triggers — no superset "just in case", no subset that happens to work today.

See sample: `ui-handlers-in-tests.good.al`.

## Anti Pattern

Omitting a handler for a UI call the path raises (unhandled-UI abort), padding the list with a handler the path never reaches ("handler function was not executed"), or writing handlers that hardcode their answer and assert inline with no enqueue/dequeue. The last is the subtle one: nothing proves the correct dialog fired the expected number of times, and an inline assertion that fails inside a handler can be swallowed by the calling UI operation, leaving the suite green while the behavior is broken. Skipping `Initialize`/`AssertEmpty` hides both a leaked queue and a missing or extra dialog.

See sample: `ui-handlers-in-tests.bad.al`.
