---
bc-version: [all]
domain: performance
keywords: [performance-profiler, alcpuprofile, analyze-performance, slow-page, slow-posting, evidence, triage]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Profile before optimising with the performance profiler

## Description

When a Business Central page, report, or posting routine is slow, the first step is to capture a profile with the built-in Analyze Performance profiler, not to start changing code. The profiler produces an `.alcpuprofile` snapshot that shows which app, which objects, and which functions consumed the time during the exact slow action, across Microsoft first-party apps and all installed third-party extensions. Optimising before profiling means guessing: the obvious suspect is often not the real cost, and a change made without evidence cannot be shown to have helped. The profile is also the evidence a technical consultant or partner needs to triage the problem.

Profiling first reframes the work from a hunch into a measurement. The snapshot attributes time to a concrete call path, so the conversation moves from "the customer card feels slow" to "this subscriber runs a FindSet inside a loop and accounts for most of the time." That attribution is what makes a fix targeted and what lets a before-and-after comparison prove the fix worked rather than merely shifting the cost somewhere less visible.

## Best Practice

Capture the profile against the real slow action: open Help and Support, choose Troubleshooting then Analyze Performance, click Start, reproduce the slow action exactly (open the slow page, post the slow document, run the slow report), then Stop and Download Profile. Aim for a 5 to 30 second capture; longer runs get noisy. Read it starting from Active Apps to find the dominant app, cross-check Time Spent to tell continuous AL cost from spiky SQL or external-service cost, then use Aggregate Results and the Call Tree to find the specific functions to fix. When handing a profile to a partner, attach the `.alcpuprofile` file (it is plain JSON, safe to send) with the plain-language action description, the exact reproduction steps, expected versus actual timing, and the BC version and installed-extensions list.

## Anti Pattern

Changing AL code to "make it faster" on a hunch, without first capturing a profile of the slow action, or sending a partner a vague slowness report ("the customer card is slow") with no `.alcpuprofile` and no reproduction steps. The consequence is wasted effort optimising code that was never the bottleneck and no way to prove the change helped. The signal to look for: a performance-motivated code change or a partner escalation that cites no captured profile and no before-and-after timing as evidence. Remember the profiler shows AL-side time only: for network latency, SQL execution plans, or Job Queue contention, reach for telemetry instead.
