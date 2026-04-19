---
bc-version: [26..28]
domain: performance
keywords: [singleinstance, subscriber, event, memory, session]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Avoid growing globals in SingleInstance subscribers

> **Seed article.** Ported from BC Code Intelligence to seed the community corpus. Community contributors are invited to expand or refine.

## Description

A codeunit with `SingleInstance = true` is allocated once per session and lives until the session ends. Global variables on it are never collected between event fires. A subscriber that accumulates data into a global — buffering payloads, appending to a list, caching without a cap — steadily grows its session footprint for the entire user session. The symptom is memory that only recovers on sign-out, and it surfaces only on long-running sessions.

## Best Practice

Keep the global footprint on a SingleInstance subscriber bounded and intentional: a handful of flags, a setup record, a bounded cache with a maximum size. When cross-event state is genuinely needed, define an explicit reset point — end of a business process, arrival of a specific terminal event — that clears the growing collection.

See sample: `avoid-growing-globals-in-singleinstance-subscribers.good.al`.

## Anti Pattern

A SingleInstance subscriber that appends each event's payload to a global list, dictionary, or temporary record without a cap or cleanup trigger. The list grows for hours, memory pressure builds quietly, and debugging the root cause on a live environment is substantially harder than noticing the unbounded append in code review.

See sample: `avoid-growing-globals-in-singleinstance-subscribers.bad.al`.
