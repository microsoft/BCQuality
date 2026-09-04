<#
.SYNOPSIS
    Validates, prepares, and scores read-only AL development-guidance fixtures.
#>
[CmdletBinding()]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..')),
    [string] $ManifestPath,
    [string] $PrepareDirectory,
    [string] $ResultsDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path -LiteralPath $Root).Path
if (-not $ManifestPath) {
    $ManifestPath = Join-Path $Root 'evaluation/development-guidance-fixtures.json'
}

$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$problems = [System.Collections.Generic.List[string]]::new()
$validKinds = @('feature', 'bug', 'refactor', 'upgrade', 'maintenance')

function Get-ModelCaseId {
    param([string] $ManifestId)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($ManifestId)
        $hash = $sha.ComputeHash($bytes)
        $token = ([System.BitConverter]::ToString($hash) -replace '-', '').Substring(0, 8).ToLowerInvariant()
        return "case-$token"
    } finally {
        $sha.Dispose()
    }
}

if ($manifest.version -ne 1) {
    $problems.Add("Unsupported guidance fixture version: $($manifest.version)") | Out-Null
}
foreach ($thresholdName in @('minimumKnowledgeRecall', 'minimumKnowledgePrecision')) {
    $threshold = [double]$manifest.$thresholdName
    if ($threshold -lt 0 -or $threshold -gt 1) {
        $problems.Add("$thresholdName must be between 0 and 1.") | Out-Null
    }
}

$skillPath = [string]$manifest.skill
if (-not (Test-Path -LiteralPath (Join-Path $Root $skillPath) -PathType Leaf)) {
    $problems.Add("Guidance skill does not exist: $skillPath") | Out-Null
}

$seenIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($case in @($manifest.cases)) {
    $id = [string]$case.id
    if ($id -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
        $problems.Add("Fixture id must be kebab-case: '$id'.") | Out-Null
    } elseif (-not $seenIds.Add($id)) {
        $problems.Add("Duplicate fixture id: $id") | Out-Null
    }
    if ($case.PSObject.Properties.Name -notcontains 'development-plan') {
        $problems.Add("${id}: development-plan is required.") | Out-Null
        continue
    }
    $plan = $case.'development-plan'
    if ($validKinds -notcontains [string]$plan.kind) {
        $problems.Add("${id}: development-plan.kind is invalid.") | Out-Null
    }
    if ([string]::IsNullOrWhiteSpace([string]$plan.request)) {
        $problems.Add("${id}: development-plan.request is required.") | Out-Null
    }

    $expectedKnowledge = @($case.requiredKnowledge) + @($case.optionalKnowledge)
    if (@($expectedKnowledge | Sort-Object -Unique).Count -ne $expectedKnowledge.Count) {
        $problems.Add("${id}: requiredKnowledge and optionalKnowledge contain duplicates.") | Out-Null
    }
    foreach ($reference in $expectedKnowledge) {
        $reference = [string]$reference
        if ($reference.Contains('\') -or -not $reference.EndsWith('.md')) {
            $problems.Add("${id}: invalid knowledge path: $reference") | Out-Null
        } elseif (-not (Test-Path -LiteralPath (Join-Path $Root $reference) -PathType Leaf)) {
            $problems.Add("${id}: knowledge article does not exist: $reference") | Out-Null
        }
    }
}

if ($problems.Count) {
    Write-Host "Development guidance fixture validation FAILED ($($problems.Count) problem(s)):" -ForegroundColor Red
    $problems | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

if ($PrepareDirectory) {
    $markerPath = Join-Path $PrepareDirectory '.bcquality-development-guidance-evaluation'
    if (Test-Path -LiteralPath $PrepareDirectory) {
        $existing = @(Get-ChildItem -LiteralPath $PrepareDirectory -Force)
        if ($existing.Count -and -not (Test-Path -LiteralPath $markerPath -PathType Leaf)) {
            throw "PrepareDirectory is not empty and is not a BCQuality development-guidance evaluation directory: $PrepareDirectory"
        }
        if (Test-Path -LiteralPath $markerPath -PathType Leaf) {
            Get-ChildItem -LiteralPath $PrepareDirectory -File |
                Where-Object {
                    $_.Name -eq 'knowledge-index.json' -or
                    $_.Name -like 'request-*.json' -or
                    $_.Name -like 'result-*.json'
                } |
                Remove-Item -Force
        }
    } else {
        New-Item -ItemType Directory -Force -Path $PrepareDirectory | Out-Null
    }
    Set-Content -LiteralPath $markerPath -Value 'BCQuality generated development-guidance evaluation directory' -Encoding UTF8

    $indexPath = Join-Path $PrepareDirectory 'knowledge-index.json'
    & (Join-Path $Root 'tools/Build-KnowledgeIndex.ps1') -BCQualityRoot $Root -IndexPath $indexPath | Out-Null
    $skillInstructions = Get-Content -LiteralPath (Join-Path $Root $skillPath) -Raw

    foreach ($case in @($manifest.cases)) {
        $modelId = Get-ModelCaseId ([string]$case.id)
        [ordered]@{
            protocol = 'Run the supplied AL development-plan skill read-only in a clean fixture repository. Return only guidanceReport using the supplied schema and retain the repository for read-only verification.'
            caseId = $modelId
            skill = $skillPath
            skillInstructions = $skillInstructions
            knowledgeIndex = 'knowledge-index.json'
            'task-context' = [ordered]@{
                goal = [string]$case.'development-plan'.request
                'inputs-available' = @('development-plan', 'repository')
                technologies = @($case.context.technologies)
                countries = @($case.context.countries)
                'application-area' = @($case.context.'application-area')
            }
            'development-plan' = $case.'development-plan'
            resultSchema = [ordered]@{
                caseId = $modelId
                workspaceRoot = 'absolute path to the retained clean fixture repository'
                guidanceReport = [ordered]@{
                    skill = [ordered]@{ id = 'al-development-plan'; version = 1 }
                    outcome = 'completed | not-applicable | no-knowledge | partial | failed'
                    'outcome-reason' = 'required for partial or failed'
                    summary = [ordered]@{
                        request = 'planned change'
                        kind = 'feature | bug | refactor | upgrade | maintenance'
                        candidates = 0
                        selected = 0
                    }
                    context = [ordered]@{
                        'bc-version' = 'resolved target or unknown'
                        technologies = @('al')
                        countries = @('w1')
                        'application-area' = @('all')
                        unknown = @()
                    }
                    knowledge = @([ordered]@{
                        path = 'repo-relative article path'
                        sha = 'optional commit sha'
                        'used-for' = 'plan decision'
                        constraints = @('faithful normative constraint')
                        'sample-paths' = @()
                    })
                    'validation-considerations' = @([ordered]@{
                        id = 'stable id'
                        reason = 'why evidence is needed'
                        evidence = 'evidence implementation should obtain'
                    })
                    suppressed = @()
                    unresolved = @()
                }
            }
        } | ConvertTo-Json -Depth 15 |
            Set-Content -LiteralPath (Join-Path $PrepareDirectory "request-$modelId.json") -Encoding UTF8
    }
}

if ($ResultsDirectory) {
    $failures = [System.Collections.Generic.List[string]]::new()
    foreach ($case in @($manifest.cases)) {
        $modelId = Get-ModelCaseId ([string]$case.id)
        $resultPath = Join-Path $ResultsDirectory "result-$modelId.json"
        if (-not (Test-Path -LiteralPath $resultPath -PathType Leaf)) {
            $failures.Add("$($case.id): missing result file.") | Out-Null
            continue
        }
        try {
            $result = Get-Content -LiteralPath $resultPath -Raw | ConvertFrom-Json
        } catch {
            $failures.Add("$($case.id): result is not valid JSON: $($_.Exception.Message)") | Out-Null
            continue
        }
        if ($result.PSObject.Properties.Name -notcontains 'caseId' -or [string]$result.caseId -ne $modelId) {
            $failures.Add("$($case.id): result caseId mismatch.") | Out-Null
            continue
        }
        if ($result.PSObject.Properties.Name -notcontains 'guidanceReport') {
            $failures.Add("$($case.id): guidanceReport is missing.") | Out-Null
            continue
        }
        $report = $result.guidanceReport
        foreach ($requiredField in @('skill', 'outcome', 'summary', 'context', 'knowledge', 'validation-considerations', 'suppressed', 'unresolved')) {
            if ($report.PSObject.Properties.Name -notcontains $requiredField) {
                $failures.Add("$($case.id): guidance report is missing '$requiredField'.") | Out-Null
            }
        }
        $skillId = if (
            $report.PSObject.Properties.Name -contains 'skill' -and
            $report.skill.PSObject.Properties.Name -contains 'id'
        ) { [string]$report.skill.id } else { '' }
        if ($skillId -ne 'al-development-plan') {
            $failures.Add("$($case.id): guidance skill is '$skillId'.") | Out-Null
        }
        if ($report.PSObject.Properties.Name -notcontains 'outcome' -or [string]$report.outcome -ne 'completed') {
            $failures.Add("$($case.id): guidance outcome is not completed.") | Out-Null
        }
        $kind = if (
            $report.PSObject.Properties.Name -contains 'summary' -and
            $report.summary.PSObject.Properties.Name -contains 'kind'
        ) { [string]$report.summary.kind } else { '' }
        if ($kind -ne [string]$case.'development-plan'.kind) {
            $failures.Add("$($case.id): summary.kind '$kind' does not match the plan.") | Out-Null
        }

        [object[]]$knowledgeEntries = @()
        if ($report.PSObject.Properties.Name -contains 'knowledge') {
            $knowledgeEntries = @($report.knowledge)
        }
        $usedKnowledge = @()
        foreach ($entry in $knowledgeEntries) {
            $path = if ($entry.PSObject.Properties.Name -contains 'path') { [string]$entry.path } else { '' }
            $usedFor = if ($entry.PSObject.Properties.Name -contains 'used-for') { [string]$entry.'used-for' } else { '' }
            [object[]]$constraints = @()
            if ($entry.PSObject.Properties.Name -contains 'constraints') {
                $constraints = @($entry.constraints)
            }
            if ([string]::IsNullOrWhiteSpace($path) -or
                -not (Test-Path -LiteralPath (Join-Path $Root $path) -PathType Leaf)) {
                $failures.Add("$($case.id): invalid knowledge path '$path'.") | Out-Null
            } else {
                $usedKnowledge += $path
            }
            if ([string]::IsNullOrWhiteSpace($usedFor) -or -not $constraints.Count) {
                $failures.Add("$($case.id): '$path' lacks used-for or constraints.") | Out-Null
            }
            if ($entry.PSObject.Properties.Name -contains 'sample-paths') {
                foreach ($samplePath in @($entry.'sample-paths')) {
                    $samplePath = [string]$samplePath
                    if ([string]::IsNullOrWhiteSpace($samplePath) -or
                        -not (Test-Path -LiteralPath (Join-Path $Root $samplePath) -PathType Leaf)) {
                        $failures.Add("$($case.id): invalid sample path '$samplePath'.") | Out-Null
                    }
                }
            }
        }

        $required = @($case.requiredKnowledge | ForEach-Object { [string]$_ })
        $matched = @($required | Where-Object { $usedKnowledge -contains $_ }).Count
        $recall = if ($required.Count) { $matched / $required.Count } else { 1.0 }
        if ($recall -lt [double]$manifest.minimumKnowledgeRecall) {
            $failures.Add("$($case.id): knowledge recall $recall is below $($manifest.minimumKnowledgeRecall).") | Out-Null
        }
        $accepted = @(
            @($case.requiredKnowledge) + @($case.optionalKnowledge) |
                ForEach-Object { [string]$_ } |
                Sort-Object -Unique
        )
        $acceptedUsed = @($usedKnowledge | Where-Object { $accepted -contains $_ }).Count
        $precision = if ($usedKnowledge.Count) { $acceptedUsed / $usedKnowledge.Count } else { 0.0 }
        if ($precision -lt [double]$manifest.minimumKnowledgePrecision) {
            $failures.Add("$($case.id): knowledge precision $precision is below $($manifest.minimumKnowledgePrecision).") | Out-Null
        }

        $workspaceRoot = if ($result.PSObject.Properties.Name -contains 'workspaceRoot') {
            [string]$result.workspaceRoot
        } else {
            ''
        }
        if ([string]::IsNullOrWhiteSpace($workspaceRoot) -or
            -not (Test-Path -LiteralPath $workspaceRoot -PathType Container)) {
            $failures.Add("$($case.id): workspaceRoot is missing or unavailable.") | Out-Null
        } else {
            $status = @(& git -C $workspaceRoot status --porcelain)
            if ($LASTEXITCODE -ne 0) {
                $failures.Add("$($case.id): workspaceRoot is not a readable git worktree.") | Out-Null
            } elseif ($status.Count) {
                $failures.Add("$($case.id): guidance skill changed the target repository.") | Out-Null
            }
        }
    }

    if ($failures.Count) {
        Write-Host "Development guidance scoring FAILED ($($failures.Count) problem(s)):" -ForegroundColor Red
        $failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
        exit 1
    }
    Write-Host "Development guidance scoring PASSED: $(@($manifest.cases).Count) case(s)."
} else {
    Write-Host "Development guidance fixture validation PASSED: $(@($manifest.cases).Count) case(s)."
}
