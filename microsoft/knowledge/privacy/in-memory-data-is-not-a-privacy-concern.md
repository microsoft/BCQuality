---
bc-version: [all]
domain: privacy
keywords: [memory, dictionary, list, temporary-record, scope, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# In-memory variables are not a privacy concern in Business Central

## Description

Business Central runs in a managed server environment. Local variables, Dictionary, List, and temporary Record buffers exist only for the duration of the request or session; the runtime reclaims them when the scope exits. Memory dumps are not a realistic threat vector in this architecture, and flagging an in-memory collection of customer emails or names as a privacy issue misstates the product's security model.

## Best Practice

Focus privacy review on persistence, transit, and telemetry: what is written to tables, sent over the network, or logged. Treat in-memory handling of personal data as normal business functionality. When an in-memory buffer is copied into IsolatedStorage, a table, or a telemetry call, that downstream write is what gets reviewed.

## Anti Pattern

Flagging `Dictionary of [Code[20], Text]`, `List of [Text]`, or `Record Customer temporary` variables that hold customer data during a calculation as a privacy concern. The flag is a false positive that trains authors to avoid a normal pattern and distracts from the persistent storage that does matter.
