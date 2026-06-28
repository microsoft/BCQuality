---
bc-version: [all]
domain: events
keywords: [event-subscriber, static-subscriber, manual-subscriber, bindsubscription, unbindsubscription, eventsubscriberinstance, scoped-binding]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Choose static vs manual subscribers deliberately and bind manual ones with BindSubscription

## Description

An `[EventSubscriber]` codeunit is static by default (`EventSubscriberInstance = StaticAutomatic`): it is always bound, so it fires for every raise of the event in every session. That is correct for always-on behaviour such as auditing, but wrong for behaviour that must be scoped — test isolation, a one-off migration, or a conditional override — because a static subscriber cannot be switched off. For scoped behaviour, set `EventSubscriberInstance = Manual` and activate the codeunit only while needed with `BindSubscription`, releasing it with `UnbindSubscription`. LLMs are largely unaware the manual model exists and default everything to static, producing always-on side effects that leak across unrelated operations and tests.

## Best Practice

Use a static subscriber for behaviour that genuinely applies all the time. For anything scoped, mark the codeunit `EventSubscriberInstance = Manual`, call `BindSubscription(SubscriberInstance)` at the start of the scope and `UnbindSubscription(SubscriberInstance)` at the end. A manual subscriber held only in a local variable unbinds automatically when that variable leaves scope, which suits test setup/teardown; a binding you intend to outlive a single call must be unbound explicitly. Keep subscriber methods `local` per CodeCop AA0207.

See sample: `choose-static-vs-manual-subscribers-deliberately.good.al`.

## Anti Pattern

Two shapes. First, a static subscriber used for behaviour that should be scoped — an always-on side effect (sending mail, writing extra records) that now fires for every event in every session and test with no way to disable it. Second, a manual subscriber that is bound with `BindSubscription` and never unbound: when the instance is held beyond the intended scope (for example on a `SingleInstance` codeunit), the binding leaks for the whole session and later unrelated operations keep hitting it. Detection: scoped side effects on a static subscriber, or a `BindSubscription` call with no matching `UnbindSubscription` and no scope that releases the instance.

See sample: `choose-static-vs-manual-subscribers-deliberately.bad.al`.
