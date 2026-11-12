---
bc-version: [all]
domain: style
keywords: [productname, product-name, hardcoded-string, branding, rebranding, label, short, full, marketing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Insert the product name with `ProductName`, not as literal text in a message

## Description

Messages, confirmations and errors sometimes name the product ("Welcome to Business Central", "This feature requires Dynamics 365 Business Central"). Written as literal text, the name follows neither a rename of the product nor an on-premises deployment that configures its own product name. The `ProductName` data type (available from runtime 1.0) returns the configured names at run time: `ProductName.Short()` (default `Business Central`), `ProductName.Full()` (default `Dynamics 365 Business Central`) and `ProductName.Marketing()` (default `Microsoft Dynamics 365 Business Central`). Learn states that the name variations are defined in the `navsettings.json` configuration file. Each method's Learn page gives the reason: "Instead of using static text for the name, you use one of the ProductName methods. This lets you reuse the same text string across different applications, and makes it easier if the application is ever renamed." The System Application calls these methods directly, for example in the User Settings, Page Summary Provider and OAuth2 modules.

A literal product name compiles, reads correctly today and passes every test; it only becomes wrong after a rename or in a deployment with a different configured name.

## Best Practice

Put a placeholder in the label, describe it in the label's `Comment`, and pass the `ProductName` method at run time. A common convention, not stated on Learn, is `Short()` for most in-product text, `Full()` where the text sits next to other Microsoft product names, and `Marketing()` only where a formal marketing name is required. The methods return `Text` and work in any expression; they cannot be used in static property values such as `Caption` or `ToolTip`.

This is low-severity guidance: report it as `minor`. Not findings: text that deliberately names a legacy product such as Dynamics NAV (migration, consolidation); `Locked = true` labels and telemetry or log text that is not shown to users; captions and tooltips, which cannot call the methods; and existing text in code you are not changing. Base Application itself still contains labels with a literal "Business Central", so the rule applies to new or changed user-facing text.

See sample: [`use-productname-instead-of-hardcoded-product-name.good.al`](use-productname-instead-of-hardcoded-product-name.good.al).

## Anti Pattern

A new or changed user-facing label or text constant passed to `Message`, `Error`, `Confirm`, `StrMenu` or a notification contains a literal product name such as "Business Central" or "Dynamics 365 Business Central", instead of a placeholder filled from `ProductName`.

See sample: [`use-productname-instead-of-hardcoded-product-name.bad.al`](use-productname-instead-of-hardcoded-product-name.bad.al).

## References

- [Learn: ProductName data type](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/productname/productname-data-type) and its [Full](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/productname/productname-full-method), [Short](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/productname/productname-short-method) and [Marketing](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/productname/productname-marketing-method) methods.
- [BCApps: `ProductName.Marketing()` and `ProductName.Short()` in the User Settings module](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/System%20Application/App/User%20Settings/src/UserSettingsImpl.Codeunit.al#L232).
- [BCApps: `ProductName.Short()` in the OAuth2 module](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/System%20Application/App/OAuth2/OAuth2Impl.Codeunit.al#L204).
