---
bc-version: [all]
domain: style
keywords: [geturl, deep-link, client-url, web-client-url, businesscentral-dynamics-com, company-parameter, clienttype-web, multitenant-url]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Build links into the current environment's client with GetUrl, not a hand-written URL

## Description

This applies only to links that open a page, report, or record in the environment the code runs in. It does not apply to:

- Documented web client parameters appended to a `GetUrl` result. Base App appends `&$filter=...&mode=View` for the Job Queue failure link and a filter for the Sales Documents drill-down.
- A link to a different environment whose base URL comes from setup, which `GetUrl` cannot target. Master Data Management builds its source-environment OData URL from `"Source Environment URL"`.
- Fixed endpoints that are not object links, such as the `OAuthLanding.htm` redirect URL or a webhook callback address.
- Code that deliberately points at the online service from another deployment. Base App's `[Scope('OnPrem')]` `GetIntelligentCloudInsightsUrl` takes the path from `GetUrl` and sets the host to `businesscentral.dynamics.com`.
- URLs outside Business Central, such as documentation links.

Two `GetUrl` behaviors to know before relying on its result. A runtime error occurs "if the ClientType is set to SOAP or OData but the specified object type and ID has not been published as a web service"; checking the result for `''` does not catch it. With `UseFilters`, Learn says filters are supported only for listed client types "when CurrenClientType is one of the ClientType mentioned. An empty string is returned otherwise." By that wording, a call with `UseFilters = true` from a background or job queue session returns `''`.

Within that scope, the URL depends on the host, the Microsoft Entra tenant or server instance, the environment, the company, and the object (Learn's "Web client URL" format, `https://businesscentral.dynamics.com/?company=...&page=...`). `GetUrl` "Generates a URL for the specified client target that is based on the configuration of the server instance. If the code runs in a multitenant deployment architecture, the generated URL will automatically apply to the tenant ID of the current user." Its signature is `GetUrl(ClientType [, Company: Text] [, ObjectType] [, ObjectId: Integer] [, Record] [, UseFilters: Boolean] [, Layout: Text])`; a `Record` "specifies which record to open". A URL assembled from a literal host, tenant, or environment name keeps pointing at one deployment when the code runs in a sandbox, another tenant, or on-premises, and has to encode the company name and filters itself.

## Best Practice

Call `GetUrl` with the company, object type, object ID, and, for a specific record, the record. Base App's `"Page Management".GetWebUrl` sets a record filter, resolves the page for the record's table, and calls `GetUrl` with the `RecordRef`; its notification email builds the settings link with `GetUrl` too. Both pass `ClientType::Web`; Learn says to pass `ClientType::Current` when the URL should depend on the client the user is accessing it from. See sample: [`build-client-links-with-geturl.good.al`](build-client-links-with-geturl.good.al).

## Anti Pattern

Code builds a link to a page, report, or record in the environment it runs in by concatenating or formatting a literal Business Central host, tenant, or environment with `?company=`, `&page=`, `&report=`, or `&bookmark=` parameters. See sample: [`build-client-links-with-geturl.bad.al`](build-client-links-with-geturl.bad.al).

## References

- [System.GetUrl method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/system/system-geturl-clienttype-string-objecttype-integer-table-boolean-string-method): signature, tenant handling, `Current`, the SOAP/OData runtime error, and `UseFilters`. [Web client URL](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-web-client-urls): hostname, Entra tenant, environment, `company`, `page`, `report`, `bookmark`, and `filter`.
- [PageManagement.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Utilities/PageManagement.Codeunit.al) (`GetWebUrl`, lines 525-534) and [NotificationEmail.Report.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/System/Notifications/NotificationEmail.Report.al) (`CreateSettingsLink`, 182-191).
- Appended parameters: [JobQueueSendNotification.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Modules/System/JobQueue/JobQueueSendNotification.Codeunit.al) (`SetURL`, 196-212) and [SalesDocuments.Page.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Sales/Document/SalesDocuments.Page.al) (65-69).
- Carve-outs: [MDMHttpSourceTransport.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Apps/W1/MasterDataManagement/app/src/codeunits/MDMHttpSourceTransport.Codeunit.al) (41, 176-182), [ImportConsolidationFromAPI.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/Finance/Consolidation/ImportConsolidationFromAPI.Codeunit.al) (68), [ShpfySyncShopLocations.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Apps/W1/Shopify/App/src/Inventory/Codeunits/ShpfySyncShopLocations.Codeunit.al) (29), [IntelligentCloudManagement.Codeunit.al](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/W1/BaseApp/IntelligentCloudManagement.Codeunit.al) (15-28).
- [Create URLs to NAV Clients](https://github.com/microsoft/alguidelines/blob/53923c5010f293f59552193c235209518da8ff8b/content/docs/NAVPatterns/patterns/create-urls-to-nav-clients/index.md), AL Guidelines (NAV Design Patterns) article by Mike Borg Cardona and Bogdana Botez at Microsoft Development Center Copenhagen. It says `GETURL` returns an empty string for invalid parameters (line 103); current Learn documents the runtime error above for unpublished SOAP/OData objects, so follow Learn.
