---
bc-version: [13..]
domain: error-handling
keywords: [tryfunction, try-method, boolean-return, ignored-return-value, error-propagation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Consume a TryFunction return value to enable try semantics

## Description

A procedure marked `[TryFunction]` catches errors only when the caller uses its Boolean return value. An assignment or conditional makes the invocation a try-method call; a bare call is treated as an ordinary procedure call and exposes errors as usual. The attribute alone does not make every invocation non-throwing.

## Best Practice

Consume the result directly: assign it to a Boolean or use the call in an `if` condition. Handle `false` immediately while the last-error state still describes that failure.

See sample: `ignored-tryfunction-return-disables-try-semantics.good.al`.

## Anti Pattern

Calling a `[TryFunction]` procedure as a standalone statement and assuming the attribute suppresses its errors. The call has ordinary error semantics because its Boolean result is ignored.

See sample: `ignored-tryfunction-return-disables-try-semantics.bad.al`.
