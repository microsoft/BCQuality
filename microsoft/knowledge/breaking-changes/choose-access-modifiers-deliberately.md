---
bc-version: [all]
domain: breaking-changes
keywords: [access-modifier, internal, local, public, protected, scope, encapsulation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Choose access modifiers deliberately

## Description

Access is a decision about what you are willing to support forever. A procedure reachable from another extension can become a contract that callers bind to, so assess both its member access and its containing object's access. Omitting `local` does not make a procedure on an `Access = Internal` codeunit an external public API; it remains callable within the app and by explicitly permitted friend apps. The safe default is the narrowest access that works: `local` for implementation detail confined to one object, `internal` for in-app reuse on a public object, and `protected var` for an intended inheritance point. Reserve externally reachable entry points for deliberate, supported APIs.

## Best Practice

Expose a small, intentional surface and keep implementation helpers `internal` for in-app reuse or `local` when single-object. Adding `internal` to a procedure on an already internal codeunit does not narrow its same-app audience. Do not make a service `local` merely because no caller appears in that object; other objects may be its intended callers. Do not drop `[Scope('OnPrem')]` without intent, since that widens platform availability. These are compile-time API decisions, not runtime authorization: see [internal access is not a security boundary](../security/internal-access-is-not-a-security-boundary.md).

See sample: [`choose-access-modifiers-deliberately.good.al`](choose-access-modifiers-deliberately.good.al).

## Anti Pattern

Exposing implementation helpers on an externally reachable object as public procedures, creating a wider contract than the intended entry point requires. Establish the effective access and helper role before recommending a narrower modifier; a missing procedure modifier on an internal object is not evidence of an accidental external contract.

See sample: [`choose-access-modifiers-deliberately.bad.al`](choose-access-modifiers-deliberately.bad.al).

## References

[Access property](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-access-property) documents object visibility, friend access and the limits of access modifiers as a security boundary.
