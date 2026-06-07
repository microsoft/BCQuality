---
bc-version: [all]
domain: process
keywords: [constitution, brief, tech-design, roadmap, project-context, sdd]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Ground work in a solution constitution

## Description

A Business Central solution should maintain a small set of durable, high-level documents (the constitution) that every feature spec is grounded in: a project brief (customer and localisation, business processes, goals, non-goals, constraints, success measures), a technical design (architecture, which standard BC modules to reuse, the honest custom-code gaps, the assigned object ID range, the high-level data model, integrations, cross-cutting concerns), and a roadmap (an ordered, numbered feature list with status). These are the documents every agent and engineer reads before doing anything, so individual feature work stays consistent with the agreed direction instead of each feature re-deciding the architecture.

The constitution exists so that decisions are made once and reused, not re-litigated per feature. The brief fixes the business intent, the technical design fixes the architecture and the object ID range, and the roadmap fixes the order and the numbering that feature folders follow. Because every spec is checked against all three, the documents are where solution-wide consistency actually lives; without them each feature quietly invents its own answer to questions the solution already decided.

## Best Practice

Establish the constitution once at the start of a solution, and refresh rather than rewrite it when the business need changes materially, preserving decisions still valid. Interview for missing facts rather than inventing them. Write the brief in plain language with no AL, the technical design favouring reuse of standard BC and justifying every custom-code gap, and the roadmap as a numbered feature list so feature folders match the numbering. Treat the constitution as a human decision: stop for review before proceeding to feature specs. Every feature spec must then be consistent with all three documents.

## Anti Pattern

Specifying or building features with no shared brief, technical design, or roadmap to ground them. The consequence is features that contradict each other on architecture, object ID ranges, or which standard modules to reuse, because each one re-decides in isolation. The signal: feature specs that exist with no constitution behind them, or custom AL introduced with no recorded justification for not reusing standard BC.

## See also

- `specify-before-you-build.md`
- `map-each-feature-to-an-object-id-range.md`
