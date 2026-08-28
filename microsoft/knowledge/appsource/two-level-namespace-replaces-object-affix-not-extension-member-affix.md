---
bc-version: [23..]
domain: appsource
keywords: [namespace, two-level, affix, prefix, suffix, as0011, tableextension, pageextension, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A two-level namespace replaces an object affix, not an extension-member affix

## Description

Current AppSource naming guidance accepts a namespace with at least two levels, such as `Contoso.Rentals`, instead of a registered prefix or suffix on the names of objects the app owns. The namespace does not qualify members added to another publisher's object: fields, keys, controls, and actions introduced through table or page extensions still share the target object's flat member namespace and still need the registered affix.

The requirement comes from AppSourceCop rule AS0011, which only runs when the app enables AppSourceCop and configures a mandatory affix — normally an `AppSourceCop.json` next to the app manifest. An app that ships no such configuration is not subject to AS0011, and its extension members are not a compliance gap. This is the usual situation for first-party, in-box apps that ship as part of the product rather than through AppSource: their uniqueness comes from allocated object ID ranges and a controlled source tree, not from a registered affix. Confirm the extending app actually configures a mandatory affix before reporting an unaffixed extension member.

## Best Practice

Choose one collision strategy for owned objects: a registered affix or a globally meaningful namespace with at least two levels. Regardless of that choice, apply the registered affix to every member added to a base or third-party object. Keep the affix configured for AppSourceCop so member validation remains deterministic. Do not raise a missing member affix against an app that does not enable AppSourceCop with a mandatory affix; there AS0011 never fires, and the app's namespace is not the reason — the absent configuration is.

See sample: `two-level-namespace-replaces-object-affix-not-extension-member-affix.good.al`.

## Anti Pattern

Using `namespace Contoso;` as though one level satisfied the AppSource alternative, or declaring `namespace Contoso.Rentals;` and then adding an unaffixed `Loyalty Points` field to `Customer` in an app that does configure a mandatory affix. The namespace distinguishes the extension's own objects; it cannot disambiguate members on Customer. The mirror-image mistake is reporting an unaffixed extension member in an app that enables no mandatory affix at all — AS0011 does not apply there, and the finding is a false positive.

See sample: `two-level-namespace-replaces-object-affix-not-extension-member-affix.bad.al`.
