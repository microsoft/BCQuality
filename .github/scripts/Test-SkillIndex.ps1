<#
.SYNOPSIS
    Validates the BCQuality action-skill index generator and shared schemas.
#>
[CmdletBinding()]
param(
    [string] $Root = (Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath '..' '..'))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path -LiteralPath $Root).Path

function Assert-ThrowsLike {
    param(
        [scriptblock] $Action,
        [string] $Pattern
    )

    try {
        & $Action
    }
    catch {
        if ($_.Exception.Message -like $Pattern) {
            return
        }
        throw "Expected error like '$Pattern', received: $($_.Exception.Message)"
    }
    throw "Expected error like '$Pattern', but no error was thrown."
}

$generator = Join-Path $Root 'tools/Build-SkillIndex.ps1'
$resolver = Join-Path $Root 'tools/Resolve-SkillWorklist.ps1'
$indexSchema = Join-Path $Root 'schemas/skill-index.schema.json'
$reportSchema = Join-Path $Root 'schemas/findings-report.schema.json'
foreach ($path in $generator, $resolver, $indexSchema, $reportSchema) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Required contract file not found: $path"
    }
}

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("skillindex_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp -Force | Out-Null
try {
    $first = Join-Path $tmp 'first.json'
    $second = Join-Path $tmp 'second.json'
    & $generator -BCQualityRoot $Root -IndexPath $first | Out-Null
    & $generator -BCQualityRoot $Root -IndexPath $second | Out-Null

    $normalize = {
        param([string] $Path)
        return ((Get-Content -LiteralPath $Path -Raw) -replace '"generatedAt":"[^"]*"', '"generatedAt":"<timestamp>"')
    }
    if ((& $normalize $first) -ne (& $normalize $second)) {
        throw 'Skill index is not deterministic beyond generatedAt.'
    }

    $raw = Get-Content -LiteralPath $first -Raw
    if (-not ($raw | Test-Json -SchemaFile $indexSchema -ErrorAction Stop)) {
        throw 'Generated skill index does not satisfy schemas/skill-index.schema.json.'
    }

    $index = $raw | ConvertFrom-Json
    $skills = @($index.skills)
    if ($index.skillCount -ne $skills.Count) {
        throw "skillCount is $($index.skillCount), but the index contains $($skills.Count) records."
    }

    $paths = @($skills.path)
    $duplicates = @($paths | Group-Object | Where-Object Count -gt 1)
    if ($duplicates.Count) {
        throw "Duplicate skill paths: $($duplicates.Name -join ', ')"
    }
    foreach ($path in $paths) {
        if (-not (Test-Path -LiteralPath (Join-Path $Root $path) -PathType Leaf)) {
            throw "Indexed skill does not exist: $path"
        }
    }

    $expectedLeaves = @(
        'microsoft/skills/review/al-performance-review.md',
        'microsoft/skills/review/al-security-review.md',
        'microsoft/skills/review/al-privacy-review.md',
        'microsoft/skills/review/al-upgrade-review.md',
        'microsoft/skills/review/al-style-review.md',
        'microsoft/skills/review/al-ui-review.md',
        'microsoft/skills/review/al-error-handling-review.md',
        'microsoft/skills/review/al-events-review.md',
        'microsoft/skills/review/al-interfaces-review.md',
        'microsoft/skills/review/al-breaking-changes-review.md',
        'microsoft/skills/review/al-web-services-review.md',
        'microsoft/skills/review/al-testing-review.md',
        'microsoft/skills/review/al-data-modeling-review.md',
        'microsoft/skills/review/al-query-review.md',
        'microsoft/skills/review/al-reporting-review.md',
        'microsoft/skills/review/al-appsource-review.md',
        'microsoft/skills/review/al-telemetry-review.md',
        'microsoft/skills/review/al-scm-review.md',
        'microsoft/skills/review/al-finance-review.md'
    )
    $review = @($skills | Where-Object id -eq 'al-code-review')
    if ($review.Count -ne 1) {
        throw "Expected exactly one al-code-review record, found $($review.Count)."
    }
    if ((@($review[0].subSkills) -join "`n") -cne ($expectedLeaves -join "`n")) {
        throw "al-code-review subSkills did not preserve the declared $($expectedLeaves.Count)-leaf order."
    }
    foreach ($leafPath in $expectedLeaves) {
        $leaf = @($skills | Where-Object path -ceq $leafPath)
        if ($leaf.Count -ne 1 -or @($leaf[0].subSkills).Count -ne 0) {
            throw "Expected '$leafPath' to resolve to exactly one leaf action skill."
        }
    }

    $minimalReport = @{
        skill = @{ id = 'al-style-review'; version = 1 }
        outcome = 'completed'
        summary = @{
            counts = @{ blocker = 0; major = 0; minor = 0; info = 0 }
            coverage = @{ 'worklist-size' = 0; 'items-evaluated' = 0 }
        }
        findings = @()
        suppressed = @()
    } | ConvertTo-Json -Depth 8
    if (-not ($minimalReport | Test-Json -SchemaFile $reportSchema -ErrorAction Stop)) {
        throw 'Minimal findings report does not satisfy schemas/findings-report.schema.json.'
    }

    $reviewSkillText = Get-Content -LiteralPath (
        Join-Path -Path $Root -ChildPath 'microsoft/skills/review/al-code-review.md'
    ) -Raw
    $reportExamples = [regex]::Matches($reviewSkillText, '(?s)```json\s*(\{.*?\})\s*```')
    if ($reportExamples.Count -ne 2) {
        throw "Expected two al-code-review JSON examples, found $($reportExamples.Count)."
    }
    foreach ($example in $reportExamples) {
        if (-not ($example.Groups[1].Value | Test-Json -SchemaFile $reportSchema -ErrorAction Stop)) {
            throw 'An al-code-review output example does not satisfy schemas/findings-report.schema.json.'
        }
    }

    $fixtureRoot = Join-Path -Path $tmp -ChildPath 'fixture'
    $fixtureSkills = Join-Path -Path $fixtureRoot -ChildPath 'microsoft/skills/review'
    New-Item -ItemType Directory -Path $fixtureSkills -Force | Out-Null
    $leaf = @'
---
kind: action-skill
id: al-leaf-review
version: 1
title: Leaf
description: Test leaf.
inputs: [file-path]
outputs: [findings-report]
---

# Leaf

## Source
Source.
## Relevance
Relevance.
## Worklist
Worklist.
## Action
Action.
## Output
Output.
'@
    Set-Content -LiteralPath (Join-Path $fixtureSkills 'al-leaf-review.md') -Value $leaf -Encoding utf8NoBOM

    $duplicateSuper = @'
---
kind: action-skill
id: al-code-review
version: 1
title: Review
description: Test super-skill.
inputs: [file-path]
outputs: [findings-report]
sub-skills:
  - microsoft/skills/review/al-leaf-review.md
  - microsoft/skills/review/al-leaf-review.md
---

# Review

## Source
Source.
## Relevance
Relevance.
## Worklist
Worklist.
## Action
Action.
## Output
Output.
'@
    $superPath = Join-Path $fixtureSkills 'al-code-review.md'
    Set-Content -LiteralPath $superPath -Value $duplicateSuper -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*duplicate sub-skill*' -Action {
        & $generator -BCQualityRoot $fixtureRoot -IndexPath (Join-Path $tmp 'invalid.json')
    }

    $nestedLeaf = $leaf.Replace('id: al-leaf-review', 'id: al-nested-review').Replace(
        'outputs: [findings-report]',
        "outputs: [findings-report]`nsub-skills:`n  - microsoft/skills/review/al-leaf-review.md"
    )
    Set-Content -LiteralPath (Join-Path $fixtureSkills 'al-nested-review.md') -Value $nestedLeaf -Encoding utf8NoBOM
    $nestedSuper = @'
---
kind: action-skill
id: al-code-review
version: 1
title: Review
description: Test super-skill.
inputs: [file-path]
outputs: [findings-report]
sub-skills:
  - microsoft/skills/review/al-nested-review.md
---

# Review

## Source
Source.
## Relevance
Relevance.
## Worklist
Worklist.
## Action
Action.
## Output
Output.
'@
    Set-Content -LiteralPath $superPath -Value $nestedSuper -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*Nested super-skills are not supported*' -Action {
        & $generator -BCQualityRoot $fixtureRoot -IndexPath (Join-Path $tmp 'nested.json')
    }

    Remove-Item -LiteralPath (Join-Path $fixtureSkills 'al-nested-review.md') -Force
    $validSuper = @'
---
kind: action-skill
id: al-code-review
version: 1
title: Review
description: Test super-skill.
inputs: [file-path]
outputs: [findings-report]
sub-skills:
  - microsoft/skills/review/al-leaf-review.md
---

# Review

## Source
Source.
## Relevance
Relevance.
## Worklist
Worklist.
## Action
Action.
## Output
Output.
'@
    Set-Content -LiteralPath $superPath -Value $validSuper -Encoding utf8NoBOM

    $customSkills = Join-Path -Path $fixtureRoot -ChildPath 'custom/skills/review'
    New-Item -ItemType Directory -Path $customSkills -Force | Out-Null
    $customLeaf = $leaf.Replace('title: Leaf', 'title: Custom Leaf')
    Set-Content -LiteralPath (Join-Path $customSkills 'custom-leaf-review.md') -Value $customLeaf -Encoding utf8NoBOM

    $layeredPath = Join-Path $tmp 'layered.json'
    & $generator -BCQualityRoot $fixtureRoot -IndexPath $layeredPath | Out-Null
    $layeredIndex = Get-Content -LiteralPath $layeredPath -Raw | ConvertFrom-Json
    $layeredLeaves = @($layeredIndex.skills | Where-Object id -eq 'al-leaf-review')
    if ($layeredLeaves.Count -ne 2) {
        throw "Expected both layered al-leaf-review implementations, found $($layeredLeaves.Count)."
    }
    if ((@($layeredLeaves.layer | Sort-Object) -join ',') -cne 'custom,microsoft') {
        throw 'Layered al-leaf-review implementations did not preserve custom and microsoft records.'
    }

    $resolved = & $resolver -BCQualityRoot $fixtureRoot -IndexPath $layeredPath -SuperSkillPath (
        'microsoft/skills/review/al-code-review.md'
    )
    if ($resolved.subSkills.Count -ne 1 -or
        $resolved.subSkills[0].path -cne 'custom/skills/review/custom-leaf-review.md') {
        throw 'The custom implementation did not win the layered leaf slot.'
    }

    $microsoftOnly = & $resolver -BCQualityRoot $fixtureRoot -IndexPath $layeredPath -SuperSkillPath (
        'microsoft/skills/review/al-code-review.md'
    ) -EnabledLayers microsoft
    if ($microsoftOnly.subSkills.Count -ne 1 -or
        $microsoftOnly.subSkills[0].path -cne 'microsoft/skills/review/al-leaf-review.md') {
        throw 'Disabling the custom layer did not fall back to the Microsoft implementation.'
    }

    $customDisabled = & $resolver -BCQualityRoot $fixtureRoot -IndexPath $layeredPath -SuperSkillPath (
        'microsoft/skills/review/al-code-review.md'
    ) -DisabledSkills 'custom/skills/review/custom-leaf-review.md'
    if ($customDisabled.subSkills.Count -ne 1 -or
        $customDisabled.subSkills[0].path -cne 'microsoft/skills/review/al-leaf-review.md') {
        throw 'Disabling the custom implementation did not fall back to Microsoft.'
    }

    Set-Content -LiteralPath (Join-Path $customSkills 'duplicate-leaf-review.md') -Value $customLeaf -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*Duplicate action-skill IDs within a layer: custom:al-leaf-review*' -Action {
        & $generator -BCQualityRoot $fixtureRoot -IndexPath (Join-Path $tmp 'duplicate-layer.json')
    }
}
finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output "Skill-index check PASSED: deterministic, schema-valid, layered overrides resolved, and all $($expectedLeaves.Count) review leaves preserved in order."
