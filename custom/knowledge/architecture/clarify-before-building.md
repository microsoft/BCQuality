---
bc-version: [all]
domain: architecture
keywords: [clarify, ambiguity, requirements, questions, before-coding, task-evaluation]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

Before writing any AL code, the agent must evaluate whether the task is
unambiguously defined. If the task can be interpreted in more than one way,
the agent must ask clarifying questions and wait for answers before proceeding.

No code may be written, edited or deleted until the task is 100% clear.

This rule exists because AL code changes affect compiled extensions, running
BC environments and test databases. An incorrect assumption costs more to
undo than a clarifying question costs to ask.

## When to ask

Ask before coding if any of the following is true:

- The task mentions an object, field or flow that does not exist yet and the
  design is not specified
- The expected behaviour could match more than one existing code path
- The task involves a business rule (amounts, thresholds, VAT, posting groups)
  where an assumption could produce silently wrong ledger entries
- The scope is unclear: "fix this" or "make it work" without specifying what
  correct behaviour looks like
- The counterparty type, document type, direction or posting flags are not
  stated and cannot be unambiguously inferred from context
- The test assertions reference calculated values that depend on setup data
  the agent has not yet read

## How to ask

State what you understand the task to be, then list the specific questions:

```
I understand the task as: [one sentence summary]

Before I proceed, I need clarification on:
1. [specific question]
2. [specific question]

I will not write any code until these are answered.
```

Do not write partial code while waiting. Do not write "placeholder" code.
Do not write code with TODO comments where a business decision is needed.

## When NOT to ask

Do not ask if:
- The task is fully specified with object names, field names, expected values
  and posting behaviour
- The answer can be determined by reading existing source files or .md
  documentation in the project
- The ambiguity is purely cosmetic (formatting, comment wording)

If the answer is in the project's source files or documentation, read those
files first and resolve the ambiguity yourself before asking the developer.

## Anti Pattern

```
// WRONG: Assuming and building
// Task: "write a test for the vendor flow"
// Agent assumes: Vendor, Incoming, Handle+Invoice, no contact
// Writes 80 lines of code
// Developer says: "I meant outgoing flow with a customer"
// Result: wasted work, possible production code changes to revert
```

## Best Practice

```
// CORRECT: Clarify first
// Task: "write a test for the vendor flow"

I understand the task as: writing a test codeunit for a Settlement Voucher
flow where the counterparty is a Vendor.

Before I proceed, I need clarification on:
1. Incoming (vendor delivers goods) or Outgoing (vendor picks up goods)?
2. Handle-only, Invoice-only, or combined Handle+Invoice in one run?
3. Should the test use an existing vendor from the database or create one
   via LibraryPurchase.CreateVendor?

I will not write any code until these are answered.
```
