---
bc-version: [21..]
domain: ui
keywords: [action-groups, area-promoted, actionref, showas, split-button, group-caption, navigate-group, entity-group]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Use Standard Promoted Action Group Names And Placements

## Description
Business Central ships a fixed vocabulary of promoted action groups, and users build muscle memory around where each kind of action lives. When you define `area(Promoted)` groups, reusing the standard caption and placement for a given action class makes the page feel native; inventing your own caption or putting an action in the wrong group forces every user to relearn your page. Frontier models tend to emit plausible-but-nonstandard captions (`Go To`, `Vendor Actions`, `Related`) instead of the established BC names, which is exactly what breaks cross-page consistency.

## Best Practice
Map each action to its conventional group and use the exact standard caption: `Home`/`Process` for data-modifying and workflow actions (entity/card/document pages use `Home`, lists and worksheets use `Process`); an entity-named group (`Customer`, `Item`, `Order`) for navigation tied to the current record (statistics, ledger entries, dimensions); `Navigate` for related pages that are useful regardless of the selected record; `Report` for printing and analysis; and the workflow groups `Posting`, `Release`, `Approve`, `Request Approval`, and `Prepare` for their respective document lifecycle actions. Standard guidance recommends `ShowAs = SplitButton` for `Posting` (Post / Post and Print / Preview) and `Release` (Release / Reopen), while the other common groups normally render as standard groups. Use a split button elsewhere only for closely related alternatives with an obvious primary action. The first enabled and visible action becomes the primary button, so place the expected default first and remember that extensions or personalization can reorder it. Within a common group keep the same action sequence you see on the matching base-app page (for example, mirror Sales Order for a sales document) so order stays predictable.

## Anti Pattern
Custom captions for what is really a standard group (`Vendor Actions` instead of the `Vendor` entity group, `Go To` instead of `Navigate`), posting or statistics actions dropped into the wrong group, or many tiny one-action groups that fragment the ribbon. The reviewer signal is an `area(Promoted)` block whose `group` captions do not match the base-application names for the same page type, or a split button whose actions are unrelated or lack an obvious primary operation.
