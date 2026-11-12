---
bc-version: [all]
domain: data-modeling
keywords: [derived-field, search-name, onvalidate, xrec, user-override, cascading-update]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Recompute an editable derived field only while it still holds the derived value

## Description

Some fields are derived from another field by a fixed transform — `"Search Name"` (`Code[100]`) is `Name` (`Text[100]`) as normalized by the `Code` assignment, which converts to uppercase and removes leading and trailing spaces. When the derived field is **editable**, a user may have typed their own value into it. If the source field's `OnValidate` recomputes the derived field unconditionally, the next change to the source (a typo fix in `Name`) silently replaces that value, with no error.

Base Application mainly shows two shapes. Customer, Vendor, Item, Contact, G/L Account, Bank Account, Resource, Project (`Job` table), Fixed Asset and others guard the recompute: `if ("Search Name" = UpperCase(xRec.Name)) or ("Search Name" = '') then "Search Name" := Name;`. Employee also has a blank-only refill in `"Search Name"`'s own `OnValidate` and a change-detecting `UpdateSearchName`. Work Center, Machine Center, Production Order, Routing, Production BOM, Cost Type and others assign unconditionally — Work Center's `"Search Name"` is shown and editable on the Work Center Card, so a value typed there lasts only until `Name` is next validated. Treat that as existing behaviour, not as a template for a field whose user-entered value is meant to persist.

### What `xRec` contributes, and what happens when it has no before-image

Learn describes `xRec` only as "the original values of the record before the changes" and does not state what it holds in a field's `OnValidate` for each code-driven call shape (`Validate(Field, NewValue)`, assign-then-`Validate(Field)`, or a record that was never read). See [`xrec-is-a-before-image-only-in-some-triggers.md`](xrec-is-a-before-image-only-in-some-triggers.md) for triggers where `xRec` is known to mirror `Rec` from code. Do not make correctness depend on it here.

The guard does not need it to. Consider the three states `xRec` can be in here: a true before-image (the guard works as intended); a copy that already holds the new `Name` (the condition reduces to *"`Search Name` is blank or already equals the new transform"*); or a blank/initialized record (the condition reduces to *"`Search Name` is blank"*). In none of them does the guard overwrite a value that differs from both the old and the new transform; its only failure mode is **skipping** the recompute, leaving an unedited `"Search Name"` that still reflects the old `Name`. The blank branch is what still populates a new record's derived field from code, whatever `xRec` holds (Base Application uses the assign-then-validate shape, for example `Item.Description := ...; Item.Validate(Description, Item.Description);` in `CatalogItemManagement.Codeunit.al`). Code that renames existing records in bulk and must also refresh unedited derived values can compare against the stored row (`Get` the record and compare with the transform of the stored `Name`) instead of relying on `xRec`.

## Best Practice

When the derived field is meant to accept user input, recompute it in the source field's `OnValidate` only if it is blank or still equals the transform of the previous source value. Compare using the **same transform you assign** — for a `Code` target that means `UpperCase(xRec.Name)`, not `xRec.Name`, or the guard stops matching as soon as the name contains a lowercase letter. When the derived field is not meant to accept user input, make that explicit with `Editable = false` and recompute unconditionally; the guard would be dead code.

See sample: [`only-cascade-derived-field-update-when-not-user-overridden.good.al`](only-cascade-derived-field-update-when-not-user-overridden.good.al).

## Anti Pattern

A new or changed source-field `OnValidate` copies the source into a derived `Text`/`Code` field (directly, or through `UpperCase`/`CopyStr`/`DelChr`) unconditionally — `"Search Name" := Name;` — while the target is presented to users as their own alias: an editable page field, or a caption/ToolTip calling it an alternate or search name. Any value a user entered there is lost the next time the source is validated. Not this anti-pattern: a target declared `Editable = false`; a target on no page and with no other writer (a pure cache, such as Assembly Header's `"Search Description"`); arithmetic or quantity recomputes; or a guard comparing against a re-read stored value instead of `xRec`.

See sample: [`only-cascade-derived-field-update-when-not-user-overridden.bad.al`](only-cascade-derived-field-update-when-not-user-overridden.bad.al).

## References

- [System-defined variables (`Rec`, `xRec`)](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-system-defined-variables).
- [BCApps: Customer `Name` `OnValidate` guard and editable `Search Name`](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Sales/Customer/Customer.Table.al#L112-L133).
- [BCApps: Vendor `Name` `OnValidate` guard](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Purchases/Vendor/Vendor.Table.al#L103-L106).
- [BCApps: Contact `UpdateSearchName` guard](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/CRM/Contact/Contact.Table.al#L2249-L2250).
- [Learn: Code data type](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/code/code-data-type).
- [BCApps: Item `Description` guard with `CopyStr`](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Inventory/Item/Item.Table.al#L108-L111).
- [BCApps: Work Center unconditional recompute](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Manufacturing/WorkCenter/WorkCenter.Table.al#L44-L53) and [editable on Work Center Card](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Manufacturing/WorkCenter/WorkCenterCard.Page.al#L59-L62).
- [BCApps: assign-then-validate shape on a new item](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Inventory/Item/Catalog/CatalogItemManagement.Codeunit.al#L560-L570).
- NAV Design Patterns, "Conditional Cascading Update", originally by Jan Hoek at IDYN ([AL-Dev-Help](https://github.com/BC-Design-Patterns/AL-Dev-Help/blob/d93e2b9166d7f18cfb7533ac32b8d6b40439de62/content/NAVPatterns/1-patterns/conditional-cascading-update/index.md)).
