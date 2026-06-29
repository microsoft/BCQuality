---
bc-version: [all]
domain: testing
keywords: [handler, enqueue, variable-storage, assert, verdict]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Enqueue from handlers; assert in the test body

## Description

A UI handler function runs in its own invocation context, separate from the `[Test]` method's verdict scope. An assertion that fails inside a handler does not reliably surface as the test's failure: the error can be swallowed by the calling UI operation or reported in a way that masks which test failed, so a broken expectation can silently pass. The reliable pattern is to make handlers capture, not judge — push the values they observe into `LibraryVariableStorage.Enqueue` — and let the test body dequeue those values and assert on them, where the verdict belongs. Finishing with `LibraryVariableStorage.AssertEmpty` confirms every expected interaction actually fired and nothing was left unconsumed.

## Best Practice

In the handler, `Enqueue` the message text, the page values, or the confirm question. In the test body, after acting, `Dequeue` each value and verify it with `Assert`; then call `LibraryVariableStorage.AssertEmpty` to prove the handler ran exactly as often as expected. This keeps the pass/fail decision in the method the runner scores and turns a missed or extra UI call into a real failure.

See sample: `handlers-enqueue-never-assert.good.al`.

## Anti Pattern

Calling `Assert.AreEqual` (or `Error`) directly inside a `[MessageHandler]` or `[ConfirmHandler]`. If the expectation is wrong, the failure may never reach the test verdict, so the suite reports green while the behavior is broken — the most dangerous kind of test, one that cannot fail.

See sample: `handlers-enqueue-never-assert.bad.al`.
