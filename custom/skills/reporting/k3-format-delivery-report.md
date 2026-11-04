---
name: K3 Format Delivery Report
description: "Draft a factual K3-Pebblestone delivery report from verified branch discovery and AL change analysis. Use when creating or revising a feature handoff report."
type: skill
scope: workspace
---

# K3 Format Delivery Report

Compose the report from [K3 Discover Branch AL Changes](./k3-discover-branch-al-changes.md) and [K3 Analyse AL Changes](./k3-analyse-al-changes.md). Draft only; do not write files. Pass the complete draft to [K3 Save Delivery Report](./k3-save-delivery-report.md).

## Template

```markdown
# Delivery Report: <Feature Title>

**Feature ID:** <ID>  
**Branch:** <branch>  
**Pull Request:** <[#number](PR URL) or none yet>  
**Repository:** <owner/repo>  
**Delivery Date:** <verified date>

## Executive Summary
<Plain-language description of the functional change and why it matters, 1-2 paragraphs>

## Feature Functionality
<User-facing flow, conditions, permissions, and prerequisites>

## Testing Checklist
- [ ] <concrete check derived from verified logic>

## Files Modified

### 1. <FileName>
**Object:** `<object type> <id> "<name>"` *(added / modified / deleted)*  
**Location:** [<relative path>](<relative path>)  
**Global Changes:** <one concise prose paragraph>

<repeat for every in-scope file in the discovered order>

## Deployment Notes
- <prerequisites, compatibility, known limitations, or none identified>

## Open Items
- <clearly flagged uncertainty, or omit if none>

## Change Summary
| Metric | Value |
|--------|-------|
| Files Updated | <count> |
| Files Added | <count> |
| Files Deleted | <count> |
| Modules Affected | <verified modules> |
```

## Content Rules

- Every in-scope functional file appears under Files Modified in the discovery order. Excluded housekeeping and report files do not appear or count in metrics.
- Keep one short prose paragraph per file; do not use a line-by-line breakdown.
- Testing Checklist items must be specific and verifiable. Do not imply that proposed checks have passed.
- Use the repository/PR metadata and date established during discovery. If the delivery date cannot be verified, state that it is unconfirmed and flag it rather than inventing one.
- Include every open item from analysis, clearly marked with `⚠️`.
- Do not include author, committer, reviewer, or merger names/handles, or PR merge status/dates.
- If an earlier report exists, use it only as a comparison aid. Correct any detail that conflicts with the verified source and change set.
- Use factual developer-to-developer language; this is a handoff, not marketing copy.
- Show the complete draft in chat and state the intended output path. Never save from this skill.
