---
bc-version: [27..]
domain: agents
keywords: [instruction-keywords, request-a-review, memorize, write-an-email, invoke-action]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use the toolkit instruction keywords for review, mail, and memory

## Description

The agent runtime looks for specific phrases: ask for assistance, request a review, reply, write an email, memorize, `Set field`, use lookup, `Invoke action`. Ordinary English such as get a human to look or remember this is weaker. Outbound reply and email always require review; that is platform policy, not optional tone.

## Best Practice

In the instruction resource, use those keywords at the decision points: request a review before posting; write an email only after stating that outbound mail is reviewed; memorize values the later steps need. Pair `Reply` / `Write an email` with an explicit review sentence.

See sample: [`use-documented-instruction-keywords.good.al`](use-documented-instruction-keywords.good.al).

## Anti Pattern

Inventing tool-like verbs (call Copilot, click Post_Promoted) or omitting request a review before posting. Detection signal: instruction text that says email the customer with no review keyword.

See sample: [`use-documented-instruction-keywords.bad.al`](use-documented-instruction-keywords.bad.al).

## See also

`instruction-structure-is-role-rules-steps.md` defines the containing document structure, while `instructions-describe-work-not-tool-ids.md` keeps outcomes independent of UI tool identifiers.
