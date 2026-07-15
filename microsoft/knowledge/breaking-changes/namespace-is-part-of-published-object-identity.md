---
bc-version: [23..]
domain: breaking-changes
keywords: [namespace, published-object, dependency, breaking-change, as0007, compile-time-identity]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Treat a published namespace as part of object identity

## Description

AL resolves an object by namespace and name. Once an app ships and dependent extensions compile against that identity, changing the namespace breaks their references even when the object name and ID stay unchanged. AppSourceCop AS0007 rejects changing the namespace of published objects; namespaces are therefore not a cosmetic folder-like label that can be reorganized after release.

## Best Practice

Choose a globally meaningful namespace before first publication and keep it stable. Add new functional areas beneath that structure without moving existing published objects. If an identity must move, use the platform's supported move/obsoletion lifecycle rather than a source-only namespace rename.

See sample: `namespace-is-part-of-published-object-identity.good.al`.

## Anti Pattern

Changing `namespace Contoso.Rentals;` to `namespace Contoso.RentalManagement;` as a cleanup while leaving the object name and ID untouched. Every dependent `using` directive and qualified reference targets the old identity and stops compiling.

See sample: `namespace-is-part-of-published-object-identity.bad.al`.
