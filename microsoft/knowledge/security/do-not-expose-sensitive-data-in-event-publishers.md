---
bc-version: [26..28]
domain: security
keywords: [event, publisher, extensibility, var-parameter]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not expose sensitive data in event publishers

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

Events in AL are extensibility contracts. Every subscriber — third-party, internal, or installed after the fact — receives the full set of event parameters. Parameters that carry secrets, pre-authorization state, or variables the publisher relies on for access control effectively become public, and var-parameters can be mutated by a subscriber to alter publisher behaviour.

## Best Practice

Design event signatures to carry only the data a subscriber legitimately needs. Do not pass SecretText, credential material, or flags the publisher depends on for access control. If a subscriber needs to veto an action, model it as a separate OnBefore event whose Handled pattern is documented — not as a general-purpose var Boolean callers can flip.

See sample: `samples/security/do-not-expose-sensitive-data-in-event-publishers/good.al`.

## Anti Pattern

An OnBeforeElevateAccess publisher that exposes `var CanAccess: Boolean` — any subscriber installed on the tenant can flip it to true and escalate. Or a publisher that passes a SecretText parameter it obtained internally, handing it to every subscriber.

See sample: `samples/security/do-not-expose-sensitive-data-in-event-publishers/bad.al`.

