---
bc-version: [all]
domain: events
keywords: [local-event, internal-event, event-subscriber, compatibility, access-modifier, integration-event, business-event, parameter-name, var-parameter, appsourcecop]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Treat local and internal events as subscriber contracts

## Description

The `local` and `internal` access modifiers on Business and Integration event publishers restrict who can raise the procedure; they do not prevent dependent extensions from subscribing. Once shipped, the event name and each existing parameter's name, type/subtype, and value-versus-`var` passing mode are compatibility contracts even when the publisher is not public. Parameter order is not a subscriber contract because subscribers bind the parameters they use by name. This differs from `[InternalEvent]`, which is module-only except for modules named by `internalsVisibleTo`.

## Best Practice

Preserve a shipped Business or Integration event's identity and every existing parameter's name, type/subtype, and passing mode regardless of the procedure access modifier. AS0025 protects names and types, while AS0063 and AS0077 protect removal and addition of `var`. New parameters may be added at any position on a `local` or `internal` event because subscribers can omit them; public event procedures follow the stricter caller contract described by `add-new-event-parameters-at-the-end`.

Apply the runtime 18.0+ (BC 29+) `Integer`-to-`BigInteger` parameter-widening exception rather than treating every numeric retype as an unconditional subscriber break. Preserve parameter names and `var` modifiers, check the target runtime and analyzer diagnostics, and review dependent subscribers for narrowing or output paths that still use `Integer`. Platform-supported widening does not guarantee that an old subscriber can process values above 2,147,483,647; report that concrete range risk separately. See [published procedure signatures](../breaking-changes/do-not-change-published-procedure-signatures.md).

See sample: [`treat-local-and-internal-events-as-subscriber-contracts.good.al`](treat-local-and-internal-events-as-subscriber-contracts.good.al).

## Anti Pattern

Renaming or removing an existing parameter, making an unsupported type/subtype change, or adding/removing its `var` modifier because the event publisher procedure is `local` or `internal`. AppSourceCop checks these subscriber-breaking changes because dependent event subscribers can still bind to the event. Reordering unchanged parameters, inserting a new parameter among them, and supported `Integer`-to-`BigInteger` widening on runtime 18.0+ are not this anti-pattern.

See sample: [`treat-local-and-internal-events-as-subscriber-contracts.bad.al`](treat-local-and-internal-events-as-subscriber-contracts.bad.al).

## References

- [AS0147: supported Integer-to-BigInteger parameter widening and dependent-extension risks](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0147).
