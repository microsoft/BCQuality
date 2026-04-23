---
bc-version: [all]
domain: security
keywords: [commit-behavior, attribute, integration-event, subscriber, commit, atomic]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use [CommitBehavior] to protect an atomic operation from third-party commits

## Description

`[CommitBehavior(CommitBehavior::Ignore)]` and `[CommitBehavior(CommitBehavior::Error)]` are method-level attributes that restrict what an explicit `Commit()` does inside the annotated method's scope: `Ignore` silently discards the call; `Error` raises a runtime error. The behavior only lasts for that method's activation — it reverts on method exit whether the method succeeded or errored. The attribute only tightens, never loosens: a parent method running under `Error` overrides any attempt to declare `Ignore` on a nested method. The primary use case is protecting an atomic publisher method — typically an `IntegrationEvent` — from `Commit()` calls in subscribers written by third parties: "you can protect your code from commits happening in event subscriber code; typically written by a third party." The attribute applies to explicit commits only; it does not affect the implicit commit performed by `Codeunit.Run` (see `codeunit-run-requires-prior-commit-inside-transaction.md`). It combines with `[TryFunction]` — a single method may carry both attributes, and each governs its own dimension: `[CommitBehavior]` the commit policy, `[TryFunction]` the error-propagation policy (see `use-tryfunction-for-error-catching-not-rollback.md`).

## Best Practice

Annotate publisher methods whose transactional guarantees must survive extension code. The attribute is a selective guard, not a convention: most `IntegrationEvent` publishers do not need it. Events that fire from a standalone query, events fired after the publisher has already committed, informational hooks, and notification-style events are unaffected by subscriber commits. Reach for the attribute only when the publisher has uncommitted writes at the moment of firing and a premature inner commit would persist inconsistent state. Prefer `Ignore` over `Error` when the intent is "silently nullify" — an `Error` from an extension's commit would surface as a subscriber-authored dialog rather than a publisher-defined failure mode. Pair the attribute with the actual atomic-boundary logic in the publisher (validate, then `Commit` on success); a subscriber's suppressed commit remains a no-op regardless of how the publisher completes.

See sample: `commitbehavior-attribute-scopes-explicit-commits.good.al`.

## Anti Pattern

Publishing an `IntegrationEvent` from inside an atomic operation without `[CommitBehavior(CommitBehavior::Ignore)]`. A third-party subscriber that calls `Commit()` — intentionally or by accident — persists the publisher's partial state, defeating any rollback the publisher would have performed on a later validation failure. Another anti-pattern is placing the attribute on a wrapper method and calling a nested `Codeunit.Run` that writes, expecting the attribute to suppress the implicit commit: it does not. The mirror-image anti-pattern is applying the attribute reflexively to every `IntegrationEvent` regardless of context — events that fire outside an atomic sequence gain nothing from the protection, and adding it everywhere clutters the review surface and masks the publishers that genuinely need it.

See sample: `commitbehavior-attribute-scopes-explicit-commits.bad.al`.
