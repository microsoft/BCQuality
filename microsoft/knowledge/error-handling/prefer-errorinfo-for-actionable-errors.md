---
bc-version: [23..]
domain: error-handling
keywords: [errorinfo, actionable-errors, fix-it, show-it, addaction, addnavigationaction, error-dialog]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer ErrorInfo with recommended actions over a plain Error for recoverable failures

## Description

A plain `Error('text')` ends the operation with a dead-end dialog: the user reads the message but the system offers no way forward. The `ErrorInfo` data type, combined with the actionable-errors framework added in 2023 release wave 2, lets an error carry a recommended action the user can take to unblock themselves without leaving their task. Two kinds exist: a **Fix-it** action (`AddAction`), used when the code already knows the correct value and can apply it in one step, and a **Show-it** action (`AddNavigationAction` together with `PageNo`), used when the correction lives on a related record the user should be taken to. An error dialog renders at most two recommended actions. LLMs trained on older AL almost always emit a bare `Error(...)` and rarely reach for `ErrorInfo`, so this guidance is remedial.

## Best Practice

Build an `ErrorInfo`, set `Title`, `Message`, and `DetailedMessage`, then attach the action that matches the situation. For a Fix-it, call `AddAction(Caption, Codeunit::Handler, 'MethodName')` where the handler method (which receives the `ErrorInfo`) applies the known-good value; phrase the caption as "Set value to …". For a Show-it, set `PageNo := Page::"…"`, set `RecordId` so navigation opens the right record, and call `AddNavigationAction('Show …')`. Raise it with `Error(ErrorInfo)`. Reserve recommended actions for cases where the solution is genuinely known and the user has permission to apply it.

See sample: `prefer-errorinfo-for-actionable-errors.good.al`.

## Anti Pattern

Surfacing a recoverable validation failure with `Error('You cannot invoice more than %1 units.', MaxQty)` and nothing else. The user is blocked with no offered remedy even though the code knows the maximum and could set it. The detection signal: an `Error` call in a validation or posting path whose message names a specific correct value or a specific related page, with no surrounding `ErrorInfo`, `AddAction`, or `AddNavigationAction`. Replace it with an `ErrorInfo` that carries the corresponding Fix-it or Show-it action.

See sample: `prefer-errorinfo-for-actionable-errors.bad.al`.
