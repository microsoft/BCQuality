---
bc-version: [all]
domain: process
keywords: [spec, specification, acceptance-criteria, requirements, sdd, before-implementation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Specify before you build

## Description

Before planning or writing any AL for a Business Central feature, write a feature specification that captures the problem, the users and roles, the scope and out-of-scope edges, the user flow, and testable acceptance criteria. The spec is the what and why; it deliberately names no AL objects. Writing it first grounds the work in agreed requirements and makes the result verifiable: each acceptance criterion is concrete enough to become a test, so "done" is something you can check rather than something you argue about after the code exists.

Keeping AL out of the spec is deliberate, not an omission. Naming objects too early collapses the what into the how and quietly commits the design before anyone has agreed what the feature must do. The acceptance criteria are the load-bearing part: they are written so each one maps to a single test, which means the spec doubles as the test plan and the definition of done is fixed before any code can drift away from it.

## Best Practice

For each feature, produce a spec before the plan and before any code. State the problem and the affected users and roles, draw the scope and out-of-scope boundaries, describe the user flow, and write acceptance criteria concrete enough to turn directly into tests. Record genuinely open items under open questions rather than guessing, and stop for human review of the spec before planning or implementing. Keep AL object names out of the spec; those belong to the planning step. At implementation, confirm every acceptance criterion is covered by a passing test.

## Anti Pattern

Jumping into AL with only an informal idea of the feature and no written, reviewable acceptance criteria. The consequence is scope that drifts during coding, no shared definition of done, and a result that cannot be verified against agreed requirements. The signal: a feature being implemented with no spec, or a spec that lists vague goals instead of testable acceptance criteria, or one that has already committed to AL object names before the what and why are agreed.

## See also

- `ground-work-in-a-solution-constitution.md`
- `map-each-feature-to-an-object-id-range.md`
