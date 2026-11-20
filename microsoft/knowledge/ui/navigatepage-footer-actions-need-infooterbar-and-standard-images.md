---
bc-version: [all]
domain: ui
keywords: [navigatepage, wizard, infooterbar, back-next-finish, assisted-setup, action-image, footer]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Wizard navigation actions need `InFooterBar` and the standard images

## Description

A page with `PageType = NavigatePage` is a wizard: it has no action bar, and the user moves through it with **Back**, **Next**, and **Finish** buttons at the bottom. Those buttons are ordinary `action()` controls, and two properties decide how the client treats them. An action is added to the footer only when `InFooterBar` is `true`. The `Image` values `PreviousRecord`, `NextRecord`, and `Approve` let the client recognize the actions as the back, next, and finish navigation and apply the standard presentation, which also adapts on mobile devices.

Both properties are optional to the compiler, so a wizard that omits them builds and still runs. It only looks and behaves unlike every other assisted setup guide.

## Best Practice

Give each navigation action `InFooterBar = true` and the matching image: `PreviousRecord` for **Back**, `NextRecord` for **Next**, and `Approve` for **Finish**. Bind each action's `Enabled` property to a Boolean that the page updates for the active step, so **Back** is disabled on the first step and **Next** on the last.

The order of the step groups in the layout does not define the sequence. The page's own logic decides which group is visible, so review the step logic, not the layout order, when checking the flow.

See sample: [`navigatepage-footer-actions-need-infooterbar-and-standard-images.good.al`](navigatepage-footer-actions-need-infooterbar-and-standard-images.good.al).

## Anti Pattern

Navigation actions on a `NavigatePage` that omit `InFooterBar`, or that set it but use arbitrary images. Without `InFooterBar` the action is not placed in the footer of a page type that has no action bar; with other images the client cannot identify which button is which and does not apply the standard presentation.

Do not apply promoted-action or action-bar guidance to a `NavigatePage`: it has no action bar, and its footer actions are not promoted actions.

See sample: [`navigatepage-footer-actions-need-infooterbar-and-standard-images.bad.al`](navigatepage-footer-actions-need-infooterbar-and-standard-images.bad.al).

## References

[Designing assisted setup guides](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-designing-navigate-pages) and [InFooterBar property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-infooterbar-property).
