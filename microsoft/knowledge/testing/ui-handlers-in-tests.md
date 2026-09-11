---
bc-version: [all]
domain: testing
keywords: [handler, handlerfunctions, confirm, message, notification, optional-handler, enqueue, capture, runmodal, unhandled-ui]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Wire UI handlers and verify meaningful outcomes

## Description

A test runs headless, so every UI call on the executed path must be intercepted by a matching handler named in `[HandlerFunctions(...)]`. The list is a two-sided contract: an unhandled UI call aborts the test, while Microsoft documents that [every nonoptional listed handler must execute at least once](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/attributes/devenv-handlerfunctions-attribute#remarks) or the test fails.

Optionality is declared, not inferred. `SendNotificationHandler` and `RecallNotificationHandler` accept a `HandlerIsOptional` argument, so `[SendNotificationHandler(true)]` may stay listed on a run that never raises the notification, while the same attribute written without that argument is nonoptional like every other handler type. Notifications are conditional by nature, so an optional notification handler is listed precisely because the scenario may or may not reach it.

Beyond that wiring guarantee, the test must verify the behavior it cares about. The appropriate pattern depends on the contract: a handler can capture concrete page state or a result and the test can assert that semantic postcondition after `RunModal`; assertions inside a handler are also supported. Queue/enqueue/dequeue and `LibraryVariableStorage.AssertEmpty` are useful when interaction order, count, text, replies, or a scripted sequence is itself part of the contract, but they are not mandatory for every handler.

## Best Practice

List the handlers the scenario triggers, keep an optional notification handler listed for a notification the scenario may conditionally raise, and make each executed handler contribute meaningful evidence. For a single modal page, reset a capture variable before the action, capture a concrete value from the page in the handler, and assert the expected value after `RunModal`. For ordered or repeated interactions, let the test enqueue expectations, let handlers dequeue and verify them, clear storage during initialization, and finish with `AssertEmpty`.

See sample: [`ui-handlers-in-tests.good.al`](ui-handlers-in-tests.good.al).

## Anti Pattern

Omitting a handler for a UI call, listing a nonoptional handler the path never reaches, or claiming action success from a Boolean set before the action runs. A handler that only closes a page can also leave the test without a semantic assertion. Do not flag the absence of queue storage by itself; require it only when the test needs to prove interaction order, count, text, replies, or a scripted sequence. Do not flag a listed `[SendNotificationHandler(true)]` or `[RecallNotificationHandler(true)]` that the run does not reach, and never propose removing one: the entry is what keeps the test passing on the runs where the notification does fire.

See sample: [`ui-handlers-in-tests.bad.al`](ui-handlers-in-tests.bad.al).
