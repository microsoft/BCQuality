---
bc-version: [all]
domain: upgrade
keywords: [get-execution-context, execution-context-upgrade, skip, report-selection, runtime-trigger]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Skip non-essential runtime work when `GetExecutionContext() = ExecutionContext::Upgrade`

## Description

Runtime procedures (table triggers, install routines, helpers called from many places) sometimes fire during the upgrade window because the upgrade itself touches the data they react to. When the work those procedures do is not strictly required for the upgrade to succeed — inserting report-selection entries, seeding optional configuration, sending welcome notifications — they should detect upgrade context with `GetExecutionContext() = ExecutionContext::Upgrade` and exit. This keeps upgrade transactions tight and avoids side effects that the upgrade pipeline did not ask for.

This is the opposite of a load-bearing concern: code that MUST run during the upgrade does not consult execution context. The check is for *optional* side effects that happen to be wired into runtime code paths.

## Best Practice

In a runtime procedure that performs non-essential side effects, guard the side-effect block with `if GetExecutionContext() = ExecutionContext::Upgrade then exit;` and include a brief comment explaining what is being skipped and why.

See sample: [`skip-nonessential-work-via-execution-context.good.al`](skip-nonessential-work-via-execution-context.good.al).

## Anti Pattern

Using `GetExecutionContext()` to *enable* upgrade behaviour from outside an upgrade codeunit. Upgrade behaviour belongs in a codeunit with `Subtype = Upgrade`; runtime code should only use the check to *suppress* optional work.

See sample: [`skip-nonessential-work-via-execution-context.bad.al`](skip-nonessential-work-via-execution-context.bad.al).
