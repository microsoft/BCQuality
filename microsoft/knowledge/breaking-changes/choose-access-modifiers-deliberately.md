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

Access is a decision about what you are willing to support forever. The moment a procedure or object is reachable from another extension — no `local`, or a removed `[Scope('OnPrem')]` — it becomes a contract: callers bind to it, and changing or removing it later is a breaking change. The safe default is the narrowest access that works. Use `local` for implementation detail confined to one object, `internal` for code shared within the app but not exposed to consumers, and `protected var` for state intended as an inheritance point for extension objects. Reserve `public` for the deliberate, supported entry points you intend to maintain as a stable API. LLMs tend to make everything public "to be safe," which inverts the rule and turns every helper into an accidental contract.

## Best Practice

Start everything `local` or `internal` and promote a member to `public` only when you have decided to support it as a stable contract. Expose a small, intentional surface — the supported entry point — and keep validation, posting, and helper routines `internal` for in-app reuse or `local` when single-object. Do not drop `[Scope('OnPrem')]` without intent, since that too widens the contract. Every public member is a maintenance commitment; spend them deliberately.

The object-level `Access` property only applies to Codeunit, Query, Table, Table field, Enum Type, Interface, and Permission Set objects. Page, Report, XmlPort, and PageExtension/TableExtension/ReportExtension objects do not support `Access`; adding it there is a compile error (AL0124). Do not suggest `Access = Internal` on a page (including an implementation-detail dialog page) — there is no object-level way to narrow a page's accessibility, so review it under other criteria instead (for example, whether it is reachable from a menu/role center, not whether `Access` is set).

See sample: [`choose-access-modifiers-deliberately.good.al`](choose-access-modifiers-deliberately.good.al).

## Anti Pattern

Declaring every procedure `public` by default, so internal helpers like `ValidateOrder` and `PostOrder` become a de-facto API that consumers bind to and that can no longer be changed freely. Detection: an object where implementation-detail procedures carry no access modifier or are `public` without a reason to support them externally. Default them to `internal`/`local` and make only the intended entry point public.

See sample: [`choose-access-modifiers-deliberately.bad.al`](choose-access-modifiers-deliberately.bad.al).
