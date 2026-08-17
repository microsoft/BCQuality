---
bc-version: [all]
domain: error-handling
keywords: [page-action, onaction, enabled-expression, testfield, mandatory-field, ui-validation, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# An enabled expression can make a repeated TestField unnecessary in OnAction

## Description

A page action's `Enabled` expression controls whether the user can invoke its `OnAction` trigger. When that expression requires a record field to be nonblank, the UI cannot invoke the action while the field is blank. Repeating the same presence check with `TestField` at the start of `OnAction` is therefore not required for that UI path.

## Best Practice

Do not flag a missing `TestField` in `OnAction` when the action's `Enabled` expression already proves that the same field is nonblank before UI invocation. Require validation in shared business logic or other entry points that do not have the action's UI guard.

## Anti Pattern

Recommending an unconditional duplicate `TestField` solely because `OnAction` uses the field, without accounting for an `Enabled` expression that prevents invocation while the field is blank.
