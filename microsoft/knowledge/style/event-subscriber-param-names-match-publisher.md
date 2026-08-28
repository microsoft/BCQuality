---
bc-version: [all]
domain: style
keywords: [event-subscriber, parameter-name, publisher, signature, eventsubscriber, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Event subscriber parameter names must match the publisher signature

## Description

In AL, an `[EventSubscriber]` procedure is bound to its publisher by event name and parameter list. For every parameter the subscriber declares, the name is not a style choice — it must match the name the publisher declared. The compiler validates the match at build time and emits an error if the subscriber renames a parameter. This means a reviewer cannot apply a generic "use better names" pass to subscriber parameters: `Sender`, `Rec`, `xRec`, `RunTrigger`, the table-and-field-specific parameter names a publisher emits — all are dictated by the publisher and must be reproduced verbatim.

A subscriber may, however, declare fewer parameters than the publisher. AL binds each subscriber parameter to the publisher parameter of the same name, so the subscriber can omit any parameters its handler does not use, from any position, and can even declare the ones it keeps in a different order than the publisher. This compiles and binds correctly, so a shorter or differently ordered subscriber signature is not a signature mismatch. In shipping BCApps code, `Test Runner - Mgt::OnBeforeTestMethodRun` publishes `CurrentTestMethodLine, CodeunitID, CodeunitName, FunctionName, FunctionTestPermissions, Skip`, and subscribers such as `ALTestRunnerResetEnvironment` bind to it while omitting `Skip` and declaring `CurrentTestMethodLine` last.

## Best Practice

Copy each parameter's name and type from the publisher verbatim for every parameter the subscriber keeps, and omit the ones the handler does not use. When in doubt, navigate to the publisher (`OnAfterValidateEvent`, `OnBeforePostSalesDoc`, etc.) and copy its parameter list. Style rules that apply to other locals — descriptive names, no spaces — do not apply to subscriber parameters. Do not flag a subscriber for declaring fewer parameters than the publisher, for omitting one from the middle of the list, or for declaring them in a different order, as long as every parameter it does declare matches a publisher parameter by name and type: that is valid AL, not a mismatch.

## Anti Pattern

Renaming a publisher parameter to look prettier in the subscriber. The build breaks immediately, because the name is what the runtime binds on. More insidiously, a parameter name that happens to match by coincidence in one event publisher but not in a similar one will compile in some versions of BC and fail in others when the publisher signature evolves.

Detection: a subscriber parameter whose name or type does not correspond to any parameter on the publisher — not a subscriber that merely declares fewer parameters, drops one from the middle, or lists them in a different order.
