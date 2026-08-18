---
bc-version: [all]
domain: events
keywords: [ishandled, initialization, deterministic, onbefore, reset, integration-event, control-flow]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Reset IsHandled before publishing only when its value can carry over

## Description

A routine that raises an `OnBefore…` integration event with a `var IsHandled: Boolean` parameter passes that variable by reference, so a pre-existing `true` can affect the following control flow. AL [automatically initializes Boolean variables to `false`](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-al-variables#initialization), so a freshly declared local Boolean passed to one event exactly once per procedure invocation is already deterministic. Initialization does not repeat for each loop iteration: a local declared outside a loop can carry `true` from one iteration to the next even when the source contains only one textual event raise. Outside a loop, reaching a later raise after `if IsHandled then exit;` also proves the value is `false`, provided that early exit is semantically correct and does not skip required downstream events.

## Best Practice

Reset `IsHandled := false;` before a raise only when the value might otherwise carry over as `true`: the same variable is reused after an earlier raise without a control-flow proof that it is false, a raise is re-entered by a loop, the value comes from an input parameter, field, or global, or earlier code seeds it. Prefer separate fresh locals when independent event seams need independent handled state. A reset on a guaranteed-false fresh local used by one non-looping raise, or before a later raise reached only after a semantically valid `if IsHandled then exit;`, can be retained for readability, but its absence is not a correctness finding.

See sample: `initialize-ishandled-to-false-before-publishing.good.al`.

## Anti Pattern

Raising `OnBeforeX(…, IsHandled)` when the variable can still be `true` from an earlier raise, an earlier loop iteration, or another source, so the publisher call starts with stale state. Do not match a single non-looping raise using a fresh local Boolean, or a later raise reached only after a semantically valid `if IsHandled then exit;` proves the value is false.

See sample: `initialize-ishandled-to-false-before-publishing.bad.al`.
