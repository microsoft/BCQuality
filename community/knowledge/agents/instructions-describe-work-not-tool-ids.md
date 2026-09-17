---
bc-version: [27..]
domain: agents
keywords: [instructions, tools, invoke-action, memorize, page-actions]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Instructions describe outcomes, not page action or tool names

## Description

Agent tools are the UI the profile exposes. Action names and tool ids change across pages and versions. Best-practice guidance is to say what to accomplish, not which tool to invoke. Page state is also not fully in history; values needed later must be memorized. Models paste Promoted action names into the prompt.

## Best Practice

Write steps as business outcomes (release the order, set the hold reason). Tell the agent to memorize identifiers it must reuse. Do not hard-code action captions or tool ids.

See sample: [`instructions-describe-work-not-tool-ids.good.al`](instructions-describe-work-not-tool-ids.good.al).

## Anti Pattern

Instructions that say invoke SalesOrder.Post_Promoted or use tool page-42-action-3. Detection signal: instruction text containing Promoted action names or tool identifiers.

See sample: [`instructions-describe-work-not-tool-ids.bad.al`](instructions-describe-work-not-tool-ids.bad.al).

## See also

`instruction-structure-is-role-rules-steps.md` defines the containing document structure, and `use-documented-instruction-keywords.md` identifies runtime-recognized phrases.
