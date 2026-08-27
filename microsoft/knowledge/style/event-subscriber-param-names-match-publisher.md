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

A subscriber may, however, declare fewer parameters than the publisher. AL binds on a leading prefix of the publisher's parameter list: the subscriber keeps the first parameters in the publisher's order with matching names and types, and omits the rest. This compiles and binds correctly, so a shorter subscriber signature is not a signature mismatch. Parameters may only be dropped from the tail — a subscriber cannot skip a parameter and then declare one that follows it.

## Best Practice

Copy the publisher's parameter list verbatim for every parameter the subscriber keeps, then omit any trailing parameters the handler does not use. When in doubt, navigate to the publisher (`OnAfterValidateEvent`, `OnBeforePostSalesDoc`, etc.) and copy its parameter list. Style rules that apply to other locals — descriptive names, no spaces — do not apply to subscriber parameters. Do not flag a subscriber for declaring fewer parameters than the publisher when the parameters it does declare match the publisher's leading parameters by name, type, and order: that is valid AL, not a mismatch.

## Anti Pattern

Renaming a publisher parameter to look prettier in the subscriber. The build breaks immediately. More insidiously, a parameter name that happens to match by coincidence in one event publisher but not in a similar one will compile in some versions of BC and fail in others when the publisher signature evolves.

Skipping a parameter in the middle of the publisher's list and declaring a later one in its place. The subscriber no longer matches a leading prefix, so it fails to bind. Detection: a subscriber parameter list that is not a prefix of the publisher's — not merely one that is shorter than it.
