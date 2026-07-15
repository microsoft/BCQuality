---
bc-version: [23..]
domain: appsource
keywords: [namespace, two-level, affix, prefix, suffix, as0011, tableextension, pageextension]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A two-level namespace replaces an object affix, not an extension-member affix

## Description

Current AppSource naming guidance accepts a namespace with at least two levels, such as `Contoso.Rentals`, instead of a registered prefix or suffix on the names of objects the app owns. The namespace does not qualify members added to another publisher's object: fields, keys, controls, and actions introduced through table or page extensions still share the target object's flat member namespace and still need the registered affix.

## Best Practice

Choose one collision strategy for owned objects: a registered affix or a globally meaningful namespace with at least two levels. Regardless of that choice, apply the registered affix to every member added to a base or third-party object. Keep the affix configured for AppSourceCop so member validation remains deterministic.

See sample: `two-level-namespace-replaces-object-affix-not-extension-member-affix.good.al`.

## Anti Pattern

Using `namespace Contoso;` as though one level satisfied the AppSource alternative, or declaring `namespace Contoso.Rentals;` and then adding an unaffixed `Loyalty Points` field to `Customer`. The namespace distinguishes the extension's own objects; it cannot disambiguate members on Customer.

See sample: `two-level-namespace-replaces-object-affix-not-extension-member-affix.bad.al`.
