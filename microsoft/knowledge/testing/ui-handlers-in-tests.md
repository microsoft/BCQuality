---
bc-version: [all]
domain: testing
keywords: [handler, handlerfunctions, confirm, message, strmenu, variable-storage, enqueue, capture, runmodal, unhandled-ui]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Wire UI handlers and verify meaningful outcomes

## Description

A test runs headless, so every UI call on the executed path must be intercepted by a matching handler named in `[HandlerFunctions(...)]`. The list is a two-sided contract: an unhandled UI call aborts the test, while Microsoft documents that [every listed handler must execute at least once](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/attributes/devenv-handlerfunctions-attribute#remarks) or the test fails.

Beyond that wiring guarantee, the test must verify the behavior it cares about. The appropriate pattern depends on the contract: a handler can capture concrete page state or a result and the test can assert that semantic postcondition after `RunModal`; assertions inside a handler are also supported. Queue/enqueue/dequeue and `LibraryVariableStorage.AssertEmpty` are useful when interaction order, count, text, replies, or a scripted sequence is itself part of the contract, but they are not mandatory for every handler.

## Best Practice

List precisely the handlers the scenario triggers and make each handler contribute meaningful evidence. For a single modal page, reset a capture variable before the action, capture a concrete value from the page in the handler, and assert the expected value after `RunModal`. For ordered or repeated interactions, let the test enqueue expectations, let handlers dequeue and verify them, clear storage during initialization, and finish with `AssertEmpty`.

See sample: `ui-handlers-in-tests.good.al`.

## Anti Pattern

Omitting a handler for a UI call, listing a handler the path never reaches, or claiming action success from a Boolean set before the action runs. A handler that only closes a page can also leave the test without a semantic assertion. Do not flag the absence of queue storage by itself; require it only when the test needs to prove interaction order, count, text, replies, or a scripted sequence.

See sample: `ui-handlers-in-tests.bad.al`.
