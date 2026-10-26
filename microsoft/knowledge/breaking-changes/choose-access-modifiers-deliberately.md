---
bc-version: [all]
domain: breaking-changes
keywords: [access-modifier, internal, local, public, protected, scope, encapsulation, caller, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Choose access modifiers deliberately

## Description

Access is a decision about the API you intend to support. A procedure reachable by dependent extensions can become a caller contract; narrowing its access after release can break those consumers. For new code, the safe default is the narrowest access that satisfies the intended callers and contracts. That design principle is not evidence that an existing public procedure is an accidental API.

Procedure visibility and object accessibility are different: `local` restricts a procedure to its declaring object, while an object's `Access = Internal` restricts compile-time access to that object across app boundaries, subject to `internalsVisibleTo`. A procedure without `local` on an internal codeunit can legitimately serve another object in the same app; it is not automatically an externally supported API.

## Best Practice

Use `local` for implementation details confined to one object, `internal` for in-app reuse where the contract permits it, and `protected var` for state intended as an inheritance point. Preserve deliberate public entry points. Do not drop `[Scope('OnPrem')]` without intent, since that can widen the caller contract.

Before recommending narrower access, inspect available repository call sites, the containing object's `Access`, app dependencies and `internalsVisibleTo`, interface implementations, and documented or released API contracts. A call from another object rules out `local`; a supported caller in another app can require public access. Do not infer that all consumers are known from a small diff or synthetic sample. No callers found, a helper-like name, or an omitted explanation of public access is not sufficient evidence to publish a visibility finding. If intended consumers remain unknown, do not recommend narrowing access solely on that basis.

Publish an encapsulation finding when concrete evidence establishes an unintended exposed boundary, such as an explicit implementation-only API contract contradicted by the declaration or a callable helper that bypasses required validation. Identify that evidence and preserve the access needed by legitimate callers in the proposed fix. This does not require enumerating every downstream consumer before reporting a demonstrated defect, such as a public getter exposing a raw credential. Do not present `internal` as authorization; see [internal access is not a security boundary](../security/internal-access-is-not-a-security-boundary.md).

Do not silently narrow a shipped caller contract as cleanup; preserve compatibility and follow the [deprecation lifecycle](deprecate-public-members-with-the-obsolete-lifecycle.md) when retiring it. Event publishers have separate raiser and subscriber contracts; apply [the event publisher guidance](../events/declare-event-publishers-local-or-internal.md) rather than inferring visibility from subscriber call sites.

See sample: [`choose-access-modifiers-deliberately.good.al`](choose-access-modifiers-deliberately.good.al).

## Anti Pattern

Exposing procedures established as implementation-only, such as the `ValidateOrder` and `PostOrder` helpers in the sample, as a de-facto external API alongside the supported `ProcessOrder` entry point. The finding is the evidenced mismatch with the intended API boundary, not merely the absence of `local` or `internal`.

The reviewer-side anti-pattern is recommending `local` for a method called by a separate dispatcher, treating a public procedure on an `Access = Internal` codeunit as automatically exposed to every app, or treating missing consumers in the reviewed patch as proof that public access is unnecessary. Do not publish these claims or merely downgrade their severity.

See sample: [`choose-access-modifiers-deliberately.bad.al`](choose-access-modifiers-deliberately.bad.al).

## References

- [Working with AL methods: local and global scope](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-al-methods#local-and-global-scope).
- [Access property: object accessibility and runtime limitations](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-access-property).
- [Using access modifiers: internalsVisibleTo](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-using-access-modifiers).
