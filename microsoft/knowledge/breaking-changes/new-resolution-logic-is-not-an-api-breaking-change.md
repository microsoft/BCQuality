---
bc-version: [all]
domain: breaking-changes
keywords: [runtime-behavior, business-logic, matching, fallback, resolve, false-positive, new-feature]
technologies: [al]
countries: [w1]
application-area: [all]
---

# New matching/resolution logic added by the PR is not an API breaking change

## Description

The `breaking-changes` domain protects contracts that have already shipped: published procedure signatures, object/field identity, access modifiers, and data exposed through a public API. It does not cover runtime business-logic behavior, such as a document-import routine gaining a new fallback step that resolves more lines automatically than it did before. When a PR's own explicit purpose is to add a new matcher, heuristic, or fallback step to an existing process (for example, resolving a purchase line to an item on an exact description match after item-reference and text-to-account matching fail), the resulting change in outcomes is the intended, reviewed effect of the change — not an unannounced break of a shipped contract. There is no published signature, object identity, or exposed field involved, so the breaking-changes rules do not apply.

Flagging this kind of intentional behavior change as a "breaking change" and suggesting it be gated behind an opt-in setting is a generic product/design opinion, not a defect grounded in BCQuality's breaking-changes guidance. Reviewers should not manufacture breaking-changes findings for business logic that a PR description or diff shows was deliberately added as a new capability.

## Best Practice

Reserve breaking-changes findings for changes to published procedure signatures, object/field/enum identity, access modifiers, obsolete-lifecycle handling, or data exposed through a public API. When a diff adds new matching, resolution, or fallback logic to a process as its stated purpose, do not flag the resulting change in runtime behavior as a breaking change; that is a design/product consideration outside this domain, not an API-stability defect.

## Anti Pattern

Emitting a breaking-changes finding against a PR's own new fallback/matching logic (for example, "this auto-resolves lines that previously stayed unresolved, gate it behind a setting") when nothing about a published signature, object identity, access modifier, or exposed API surface changed.
