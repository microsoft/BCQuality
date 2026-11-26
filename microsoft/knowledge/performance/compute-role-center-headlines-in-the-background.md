---
bc-version: [all]
domain: performance
keywords: [headline, headline-rc, headlinepart, oncomputeheadlines, onisanyextensionheadlinevisible, onsetvisibility, rc-headlines-executor, page-background-task]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Compute data-driven Role Center headlines in the background, not when the page opens

## Description

Code in a headline part's `OnOpenPage`, or in a subscriber to an event raised from it, runs every time the Role Center opens. When that code loops over documents or ledger entries, every Role Center open pays for work that grows with transaction volume.

Base App's `Headline RC ...` pages (for example page 1441 `"Headline RC Order Processor"`) provide background infrastructure for headlines added through page extensions. Their `OnOpenPage` calls `"RC Headlines Page Common".HeadlineOnOpenPage`, which schedules codeunit 1441 `"RC Headlines Executor"` (`TableNo = "Job Queue Entry"`) through `"Job Queue - Enqueue"`. The executor's `OnRun` reads the opening user's `"RC Headlines User Data"` record (`Get(UserSecurityId(), ...)`) and raises `OnComputeHeadlines(RoleCenterPageID)`. The same `HeadlineOnOpenPage` raises `OnIsAnyExtensionHeadlineVisible`; a subscriber that sets it to `true` hides the page's default documentation headline. Microsoft's Essential Business Headlines app computes in `OnComputeHeadlines`, stores results per user in `"Ess. Business Headline Per Usr"`, and only reads that table on the page side. The AL Guidelines (NAV Design Patterns) article describes the same split and says "The computation is done in a background task, not to decrease the performance of the role center pages". Microsoft Learn does not document these events.

Microsoft's own code does not always follow this. `"Headline RC A/P Admin"`, a Base App `HeadlinePart` page, loops over three months of vendor ledger entries in its `OnOpenPage`.

## Best Practice

For a headline added to a Base App `Headline RC ...` page whose content comes from iterating documents or entries:

1. Subscribe to `OnComputeHeadlines` on `Codeunit::"RC Headlines Executor"`, filter on `RoleCenterPageID`, compute, and store the result per user (`UserSecurityId()`).
2. Subscribe to `OnIsAnyExtensionHeadlineVisible` on `Codeunit::"RC Headlines Page Common"` and set `ExtensionHeadlinesVisible := true` only when a stored headline is visible. Do not set it to `false`; Microsoft's subscriber comments that this "could overrride some other extensions setting the value to true".
3. In the page extension's `OnOpenPage`, read the stored text and visibility.

Expect the trade-off: a headline appears only after the job has run. `HeadlineOnOpenPage` requests a refresh at most once an hour per user, and `ScheduleTask` does not enqueue when a Ready or In Process entry already exists for that Role Center, or restarts a failed or on-hold entry the next day. Nothing is computed when the job cannot be scheduled, for example without Job Queue permissions.

A headline on your own `HeadlinePart` page has no executor event. Run that work in a page background task; Learn lists `HeadlinePart` among the part pages that support them, and notes that a part page shows dashes for its fields until all of its background tasks complete. See `page-background-tasks-for-expensive-cues.md`.

See sample: [`compute-role-center-headlines-in-the-background.good.al`](compute-role-center-headlines-in-the-background.good.al).

## Anti Pattern

A headline page extension's `OnOpenPage`, a subscriber to its visibility event, or a `HeadlinePart` page's `OnOpenPage` loops over documents or ledger entries (`FindSet` with `repeat ... until Next() = 0`) or runs a query to build headline text. See sample: [`compute-role-center-headlines-in-the-background.bad.al`](compute-role-center-headlines-in-the-background.bad.al).

Not this pattern:

- The same loop in an `OnComputeHeadlines` subscriber or in a page background task codeunit.
- Static text, or visibility from a setup or availability check. Microsoft's Connectivity Apps banking headline does this in `OnOpenPage`.
- A FlowField or `CalcSums` aggregate computed once per page instance. Microsoft's Sustainability headline part calculates cue FlowFields for today and yesterday this way.

## References

- [RCHeadlinesExecutor.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/System/Headlines/RCHeadlinesExecutor.Codeunit.al): `TableNo` (line 7), `OnRun` with the user `Get` at 15 and `OnComputeHeadlines` at 17, `ScheduleTask` (21-53; pending-entry check 29-34, next-day restart 36-40), event (72-75). [RCHeadlinesPageCommon.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/System/Headlines/RCHeadlinesPageCommon.Codeunit.al): `HeadlineOnOpenPage` (15-41), one-hour `ShouldCreateAComputeJob` (49-57), `ComputeDefaultFieldsVisibility` (59-66), `OnIsAnyExtensionHeadlineVisible` (104-107).
- Essential Business Headlines: [EssBusHeadlineSubscribers.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Apps/W1/EssentialBusinessHeadlines/App/src/codeunits/EssBusHeadlineSubscribers.Codeunit.al) (`OnComputeHeadlines` 55-93, `OnIsAnyExtensionHeadlineVisible` 95-139 with the comment at 136, `OnSetVisibility` 192-204), [HeadlinesRCOrderProcExt.PageExt.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Apps/W1/EssentialBusinessHeadlines/App/src/pages/HeadlinesRCOrderProcExt.PageExt.al) (59-68).
- Inline in Microsoft code: [HeadlineRCAPAdmin.Page.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Finance/RoleCenters/HeadlineRCAPAdmin.Page.al) (`OnOpenPage` 89-96, `FindVendorLedgerEntryWithMaxAmountInLastQuater` 119-143); [Connectivity Apps HeadlineRCAccountantExt.PageExt.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Apps/W1/ConnectivityApps/app/src/Page%20Extensions/HeadlineRCAccountantExt.PageExt.al) (35-42); [Sustainability RCHeadlinePageSust.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Apps/W1/Sustainability/app/src/RoleCenters/RCHeadlinePageSust.Codeunit.al) (18-55).
- [Page Background Tasks](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-page-background-tasks), section "Designing part pages for page background tasks". [Creating a Role Center headline](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-create-role-center-headline).
- [Extending the Role Center Headlines](https://github.com/microsoft/alguidelines/blob/53923c5010f293f59552193c235209518da8ff8b/content/docs/NAVPatterns/patterns/extending-the-role-center-headlines/index.md), AL Guidelines (NAV Design Patterns) article by David Bastide at Microsoft Development Center Copenhagen, from the April 2018 release (steps at line 46-49). Its event locations are outdated: it places `OnComputeHeadlines` on a codeunit per headline page, without the `RoleCenterPageID` parameter.
