---
bc-version: [28..]
domain: web-services
keywords: [api-page, api-query, abouttext, mcp, tool-description, entitysetcaption, metadata]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Describe API objects intended for Business Central MCP tools

## Description

For API pages and API queries exposed through the Business Central online MCP server, the documented tool-description precedence is `AboutText`, then `EntitySetCaption`, then a camel-cased `EntityName`. Treating `AboutText` only as a UI teaching-tip property can leave an agent with a caption that omits essential scope or computed-value semantics. This guidance covers BC 28 and later online environments with the relevant MCP API-object support; the earlier MCP preview is outside its scope.

## Best Practice

For an API object intended for MCP use, provide a tool description that explains what a row represents, material filters and any computed values that affect interpretation. Prefer `AboutText` when captions alone cannot convey those facts. Keep the description consistent with the actual filters, fields and allowed operations. Verify the description exposed by the configured MCP tool; metadata text does not enforce filters or permissions.

The documented extraction order does not use `AboutTitle`. Do not require it solely for MCP: Microsoft ships API queries with `AboutText` and no `AboutTitle`, and the compiler accepts that form. Teaching tips have separate pairing requirements. Do not flag an absent `AboutText` when the effective fallback already describes the tool adequately, or when the object has no established MCP use. Other MCP servers and connectors can choose a different description source; check their contract before applying this rule.

See sample: [`describe-api-pages-for-mcp-with-abouttext.good.al`](describe-api-pages-for-mcp-with-abouttext.good.al).

## Anti Pattern

An API object intended for an MCP tool exposes a description that omits material endpoint semantics, such as excluding credit memos or including only item lines, because it relies on a bare entity caption. Another defect is an `AboutText` that promises restrictions the endpoint does not implement. Missing `AboutText` alone is a discovery signal, not sufficient evidence of a finding; establish the intended MCP use and the deficient effective description.

See sample: [`describe-api-pages-for-mcp-with-abouttext.bad.al`](describe-api-pages-for-mcp-with-abouttext.bad.al).

## References

- [API page type and MCP description precedence](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-api-pagetype#describe-the-api-for-mcp-tools)
- [API query type and MCP description precedence](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-api-querytype#describe-the-api-for-mcp-tools)
- [AboutText property and teaching-tip requirements](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-abouttext-property)
- [BC 28 release and generally available enhanced MCP server](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/whatsnew/whatsnew-update-28-0)
- [API query support in the 2026 release wave 1 MCP enhancements](https://learn.microsoft.com/dynamics365/release-plan/2026wave1/smb/dynamics365-business-central/unlock-more-business-central-data-mcp-server-enhancements)
- [Microsoft API Finance query with AboutText and no AboutTitle](https://github.com/microsoft/BCApps/blob/e51c552efbeb6821db450b199aae6b015371866c/src/Apps/W1/APIReportsFinance/App/src/APIFinanceGLEntry.Query.al)
