---
bc-version: [all]
domain: security
keywords: [permission-set, object-permission, grant, object-coverage, rnb]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Include New RNB Objects in a Permission Set

## Description

RNB policy requires each newly introduced, grantable AL object to be included in at least one permission set shipped by the app. Extensions and enum objects are excluded by policy; permission-set definitions are not themselves permission targets. This is a company coverage convention, in addition to the platform-specific access requirements for exposed objects.

## Best Practice

When adding a grantable object, add the matching object permission to an appropriate app permission set and verify the effective grant matches the intended workflow. Use table-data permissions for table access and object execute permissions where applicable. Check the app's complete permission-set files before concluding that a grant is missing.

## Anti Pattern

A new grantable object has no matching permission entry in any permission set shipped by the app. Do not report absence based only on an isolated AL object file when the permission-set scope is unavailable. Do not require membership for object extensions or enum objects, or invent a permission entry for a permission-set definition.

See sample: [`rnb-new-objects-in-permission-sets.good.al`](rnb-new-objects-in-permission-sets.good.al) and [`rnb-new-objects-in-permission-sets.bad.al`](rnb-new-objects-in-permission-sets.bad.al).

## Applies to

This is RNB organization policy. For platform requirements concerning exposed APIs and web services, see [exposed-objects-must-be-in-a-permission-set.md](../../../microsoft/knowledge/security/exposed-objects-must-be-in-a-permission-set.md).