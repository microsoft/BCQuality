<#
.SYNOPSIS
    Validates and prepares BCQuality AL development fixtures.

.DESCRIPTION
    Static validation checks fixture IDs, capability links, knowledge references,
    and the development skill. -PrepareDirectory emits opaque requests for model
    runs. -ResultsDirectory scores implementation reports produced by an
    external runner that performed the declared compile, test, and review checks.
#>
[CmdletBinding()]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..')),
    [string] $ManifestPath,
    [string] $CapabilitiesPath,
    [string] $PrepareDirectory,
    [string] $ResultsDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path -LiteralPath $Root).Path
if (-not $ManifestPath) {
    $ManifestPath = Join-Path $Root 'evaluation/development-fixtures.json'
}
if (-not $CapabilitiesPath) {
    $CapabilitiesPath = Join-Path $Root 'coverage/development-capabilities.json'
}

$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$capabilityManifest = Get-Content -LiteralPath $CapabilitiesPath -Raw | ConvertFrom-Json
$problems = [System.Collections.Generic.List[string]]::new()

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
    $problems.Add("Unsupported development fixture version: $($manifest.version)") | Out-Null
}
if ($capabilityManifest.version -ne 1) {
    $problems.Add("Unsupported capability manifest version: $($capabilityManifest.version)") | Out-Null
}
$minimumFixtureCoverage = if ($capabilityManifest.PSObject.Properties.Name -contains 'minimumFixtureCoverage') {
    [double]$capabilityManifest.minimumFixtureCoverage
} else {
    -1
}
if ($minimumFixtureCoverage -lt 0 -or $minimumFixtureCoverage -gt 1) {
    $problems.Add("minimumFixtureCoverage must be between 0 and 1.") | Out-Null
}
$maximumReviewRounds = if ($manifest.PSObject.Properties.Name -contains 'maximumReviewRounds') {
    [int]$manifest.maximumReviewRounds
} else {
    0
}
if ($maximumReviewRounds -le 0) {
    $problems.Add("maximumReviewRounds must be a positive integer.") | Out-Null
}
foreach ($thresholdName in @('minimumKnowledgeRecall', 'minimumKnowledgePrecision')) {
    $threshold = [double]$manifest.$thresholdName
    if ($threshold -lt 0 -or $threshold -gt 1) {
        $problems.Add("$thresholdName must be between 0 and 1.") | Out-Null
    }
}

$skillPath = [string]$manifest.skill
if (-not (Test-Path -LiteralPath (Join-Path $Root $skillPath) -PathType Leaf)) {
    $problems.Add("Development skill does not exist: $skillPath") | Out-Null
} else {
    $skillText = Get-Content -LiteralPath (Join-Path $Root $skillPath) -Raw
    $limitMatch = [regex]::Match($skillText, '(?m)^quality-round-limit:\s*(\d+)\s*$')
    if (-not $limitMatch.Success -or [int]$limitMatch.Groups[1].Value -ne $maximumReviewRounds) {
        $problems.Add("maximumReviewRounds must match the development skill quality-round-limit.") | Out-Null
    }
}

$validChecks = @('compile', 'tests', 'review')
$validInputKinds = @('auto', 'feature', 'bug', 'refactor', 'upgrade', 'maintenance')
$validOutputKinds = @('feature', 'bug', 'refactor', 'upgrade', 'maintenance')
$caseById = @{}
foreach ($case in @($manifest.cases)) {
    $id = [string]$case.id
    if ($id -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
        $problems.Add("Fixture id must be kebab-case: '$id'.") | Out-Null
    } elseif ($caseById.ContainsKey($id)) {
        $problems.Add("Duplicate fixture id: $id") | Out-Null
    } else {
        $caseById[$id] = $case
    }

    if ($case.PSObject.Properties.Name -notcontains 'development-request') {
        $problems.Add("${id}: development-request is required.") | Out-Null
        continue
    }
    $request = $case.'development-request'
    if ($validInputKinds -notcontains [string]$request.kind) {
        $problems.Add("${id}: development-request.kind must be one of $($validInputKinds -join ', ').") | Out-Null
    }
    $description = if ($request.PSObject.Properties.Name -contains 'description') {
        [string]$request.description
    } else {
        ''
    }
    $planText = if ($request.PSObject.Properties.Name -contains 'plan') {
        [string]$request.plan
    } else {
        ''
    }
    if ([string]::IsNullOrWhiteSpace($description) -and [string]::IsNullOrWhiteSpace($planText)) {
        $problems.Add("${id}: development-request requires description or plan.") | Out-Null
    }
    if ($request.PSObject.Properties.Name -notcontains 'acceptance-criteria' -or
        -not @($request.'acceptance-criteria').Count) {
        $problems.Add("${id}: development-request.acceptance-criteria must not be empty.") | Out-Null
    }
    $expectedKind = if ($case.PSObject.Properties.Name -contains 'expectedKind') {
        [string]$case.expectedKind
    } else {
        ''
    }
    if ($validOutputKinds -notcontains $expectedKind) {
        $problems.Add("${id}: expectedKind must be one of $($validOutputKinds -join ', ').") | Out-Null
    }
    if ([string]$request.kind -ne 'auto' -and [string]$request.kind -ne $expectedKind) {
        $problems.Add("${id}: explicit request kind '$($request.kind)' must equal expectedKind '$expectedKind'.") | Out-Null
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
    foreach ($check in @($case.requiredChecks)) {
        if ($validChecks -notcontains [string]$check) {
            $problems.Add("${id}: unsupported required check '$check'.") | Out-Null
        }
    }
}

$validCapabilityStatuses = @('planned', 'fixture', 'validated')
$capabilityIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($capability in @($capabilityManifest.capabilities)) {
    $id = [string]$capability.id
    if (-not $capabilityIds.Add($id)) {
        $problems.Add("Duplicate capability id: $id") | Out-Null
    }
    if ($validCapabilityStatuses -notcontains [string]$capability.status) {
        $problems.Add("${id}: invalid capability status '$($capability.status)'.") | Out-Null
    }
    $fixtureIds = @($capability.fixtureIds)
    if ($capability.status -in @('fixture', 'validated') -and -not $fixtureIds.Count) {
        $problems.Add("${id}: status '$($capability.status)' requires at least one fixture.") | Out-Null
    }
    foreach ($fixtureId in $fixtureIds) {
        if (-not $caseById.ContainsKey([string]$fixtureId)) {
            $problems.Add("${id}: unknown fixture id '$fixtureId'.") | Out-Null
        } elseif (@($caseById[[string]$fixtureId].capabilities) -notcontains $id) {
            $problems.Add("${id}: fixture '$fixtureId' does not link back to the capability.") | Out-Null
        }
    }
}

foreach ($case in @($manifest.cases)) {
    foreach ($capabilityId in @($case.capabilities)) {
        if (-not $capabilityIds.Contains([string]$capabilityId)) {
            $problems.Add("$($case.id): unknown capability '$capabilityId'.") | Out-Null
            continue
        }
        $capability = @(
            $capabilityManifest.capabilities |
                Where-Object id -eq ([string]$capabilityId)
        )[0]
        if (@($capability.fixtureIds) -notcontains [string]$case.id) {
            $problems.Add("$($case.id): capability '$capabilityId' does not link back to the fixture.") | Out-Null
        }
    }
}

$fixtureBackedCount = @(
    $capabilityManifest.capabilities |
        Where-Object status -in @('fixture', 'validated')
).Count
$capabilityCount = @($capabilityManifest.capabilities).Count
$fixtureCoverage = if ($capabilityCount) { $fixtureBackedCount / $capabilityCount } else { 0.0 }
if ($fixtureCoverage -lt $minimumFixtureCoverage) {
    $problems.Add("Fixture-backed capability coverage $fixtureCoverage is below minimumFixtureCoverage $minimumFixtureCoverage.") | Out-Null
}

if ($problems.Count) {
    Write-Host "Development fixture validation FAILED ($($problems.Count) problem(s)):" -ForegroundColor Red
    $problems | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

if ($PrepareDirectory) {
    $markerPath = Join-Path $PrepareDirectory '.bcquality-development-evaluation'
    if (Test-Path -LiteralPath $PrepareDirectory) {
        $existing = @(Get-ChildItem -LiteralPath $PrepareDirectory -Force)
        if ($existing.Count -and -not (Test-Path -LiteralPath $markerPath -PathType Leaf)) {
            throw "PrepareDirectory is not empty and is not a BCQuality development evaluation directory: $PrepareDirectory"
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
    Set-Content -LiteralPath $markerPath -Value 'BCQuality generated development evaluation directory' -Encoding UTF8

    $indexPath = Join-Path $PrepareDirectory 'knowledge-index.json'
    & (Join-Path $Root 'tools/Build-KnowledgeIndex.ps1') -BCQualityRoot $Root -IndexPath $indexPath | Out-Null
    $skillInstructions = Get-Content -LiteralPath (Join-Path $Root $skillPath) -Raw

    foreach ($case in @($manifest.cases)) {
        $modelId = Get-ModelCaseId ([string]$case.id)
        $request = [ordered]@{
            protocol = 'Run the supplied AL development skill in a fresh writable fixture repository. Persist the implementation, run real checks, and return only implementationReport using the supplied schema.'
            caseId = $modelId
            skill = $skillPath
            skillInstructions = $skillInstructions
            knowledgeIndex = 'knowledge-index.json'
            'task-context' = [ordered]@{
                goal = if ($case.'development-request'.PSObject.Properties.Name -contains 'description') {
                    [string]$case.'development-request'.description
                } else {
                    [string]$case.'development-request'.plan
                }
                'inputs-available' = @('development-request', 'repository')
                technologies = @($case.context.technologies)
                countries = @($case.context.countries)
                'application-area' = @($case.context.'application-area')
            }
            'development-request' = [ordered]@{
                kind = [string]$case.'development-request'.kind
                description = if ($case.'development-request'.PSObject.Properties.Name -contains 'description') {
                    [string]$case.'development-request'.description
                } else {
                    $null
                }
                plan = if ($case.'development-request'.PSObject.Properties.Name -contains 'plan') {
                    [string]$case.'development-request'.plan
                } else {
                    $null
                }
                'acceptance-criteria' = @($case.'development-request'.'acceptance-criteria')
            }
            resultSchema = [ordered]@{
                caseId = $modelId
                workspaceRoot = 'absolute path to the retained fixture repository'
                implementationReport = [ordered]@{
                    skill = [ordered]@{ id = 'al-development'; version = 1 }
                    outcome = 'completed | not-applicable | no-knowledge | partial | failed'
                    'outcome-reason' = 'required for partial or failed'
                    summary = [ordered]@{
                        request = 'implemented change'
                        'files-created' = 0
                        'files-modified' = 0
                        'files-deleted' = 0
                    }
                    plan = [ordered]@{
                        kind = 'feature | bug | refactor | upgrade | maintenance'
                        assumptions = @()
                        decisions = @()
                        objects = @()
                    }
                    knowledge = @([ordered]@{ path = 'repo-relative knowledge article path'; sha = 'optional commit sha'; 'used-for' = 'decision' })
                    changes = @([ordered]@{ path = 'repo-relative changed file'; action = 'created | modified | deleted'; purpose = 'reason' })
                    validation = @([ordered]@{ id = 'compile | tests | review'; command = 'command or quality-skill path'; status = 'passed | failed | not-run'; details = 'non-empty evidence' })
                    review = [ordered]@{
                        skill = [ordered]@{ id = 'al-code-review'; version = 1 }
                        outcome = 'completed | partial | failed'
                        summary = [ordered]@{
                            counts = [ordered]@{ blocker = 0; major = 0; minor = 0; info = 0 }
                            coverage = [ordered]@{ 'worklist-size' = 0; 'items-evaluated' = 0 }
                        }
                        findings = @()
                        suppressed = @()
                    }
                    'review-rounds' = @([ordered]@{
                        round = 1
                        outcome = 'clean | fixing | stalled | limit-reached'
                        'gating-finding-ids' = @()
                    })
                    suppressed = @()
                    remaining = @()
                }
            }
        }
        $request | ConvertTo-Json -Depth 12 |
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
        if ($result.PSObject.Properties.Name -notcontains 'implementationReport') {
            $failures.Add("$($case.id): implementationReport is missing.") | Out-Null
            continue
        }
        $report = $result.implementationReport
        foreach ($requiredField in @('skill', 'outcome', 'summary', 'plan', 'knowledge', 'changes', 'validation', 'review', 'review-rounds', 'suppressed', 'remaining')) {
            if ($report.PSObject.Properties.Name -notcontains $requiredField) {
                $failures.Add("$($case.id): implementation report is missing '$requiredField'.") | Out-Null
            }
        }
        $reportedSkillId = if (
            $report.PSObject.Properties.Name -contains 'skill' -and
            $report.skill.PSObject.Properties.Name -contains 'id'
        ) {
            [string]$report.skill.id
        } else {
            ''
        }
        if ($reportedSkillId -ne 'al-development') {
            $failures.Add("$($case.id): implementation report skill is '$reportedSkillId'.") | Out-Null
        }
        $summaryRequest = if (
            $report.PSObject.Properties.Name -contains 'summary' -and
            $report.summary.PSObject.Properties.Name -contains 'request'
        ) {
            [string]$report.summary.request
        } else {
            ''
        }
        if ([string]::IsNullOrWhiteSpace($summaryRequest)) {
            $failures.Add("$($case.id): summary.request is missing or empty.") | Out-Null
        }
        $reportedKind = if (
            $report.PSObject.Properties.Name -contains 'plan' -and
            $report.plan.PSObject.Properties.Name -contains 'kind'
        ) {
            [string]$report.plan.kind
        } else {
            ''
        }
        if ($reportedKind -ne [string]$case.expectedKind) {
            $failures.Add("$($case.id): plan.kind '$reportedKind' does not match expected mode '$($case.expectedKind)'.") | Out-Null
        }
        $outcome = if ($report.PSObject.Properties.Name -contains 'outcome') { [string]$report.outcome } else { '' }
        if ($outcome -ne 'completed') {
            $failures.Add("$($case.id): implementation outcome is '$outcome'.") | Out-Null
        }

        [object[]]$knowledgeEntries = @()
        if ($report.PSObject.Properties.Name -contains 'knowledge') {
            $knowledgeEntries = @($report.knowledge)
        }
        if (-not $knowledgeEntries.Count) {
            $failures.Add("$($case.id): implementation report contains no knowledge entries.") | Out-Null
        }
        $usedKnowledge = @(
            $knowledgeEntries |
                Where-Object { $_.PSObject.Properties.Name -contains 'path' } |
                ForEach-Object { [string]$_.path }
        )
        if (@($usedKnowledge | Sort-Object -Unique).Count -ne $usedKnowledge.Count) {
            $failures.Add("$($case.id): knowledge contains duplicate paths.") | Out-Null
        }
        foreach ($entry in $knowledgeEntries) {
            $path = if ($entry.PSObject.Properties.Name -contains 'path') { [string]$entry.path } else { '' }
            $usedFor = if ($entry.PSObject.Properties.Name -contains 'used-for') { [string]$entry.'used-for' } else { '' }
            if ([string]::IsNullOrWhiteSpace($path) -or
                [System.IO.Path]::IsPathRooted($path) -or
                @($path -split '/|\\') -contains '..' -or
                -not (Test-Path -LiteralPath (Join-Path $Root $path) -PathType Leaf)) {
                $failures.Add("$($case.id): knowledge entry has a missing or invalid path '$path'.") | Out-Null
            }
            if ([string]::IsNullOrWhiteSpace($usedFor)) {
                $failures.Add("$($case.id): knowledge entry '$path' has no used-for explanation.") | Out-Null
            }
        }
        $requiredKnowledge = @($case.requiredKnowledge | ForEach-Object { [string]$_ })
        $matched = @($requiredKnowledge | Where-Object { $usedKnowledge -contains $_ }).Count
        $recall = if ($requiredKnowledge.Count) { $matched / $requiredKnowledge.Count } else { 1.0 }
        if ($recall -lt [double]$manifest.minimumKnowledgeRecall) {
            $failures.Add("$($case.id): knowledge recall $recall is below $($manifest.minimumKnowledgeRecall).") | Out-Null
        }
        $acceptedKnowledge = @(
            @($case.requiredKnowledge) + @($case.optionalKnowledge) |
                ForEach-Object { [string]$_ } |
                Sort-Object -Unique
        )
        $acceptedUsed = @($usedKnowledge | Where-Object { $acceptedKnowledge -contains $_ }).Count
        $precision = if ($usedKnowledge.Count) { $acceptedUsed / $usedKnowledge.Count } else { 0.0 }
        if ($precision -lt [double]$manifest.minimumKnowledgePrecision) {
            $failures.Add("$($case.id): knowledge precision $precision is below $($manifest.minimumKnowledgePrecision).") | Out-Null
        }

        [object[]]$validationEntries = @()
        if ($report.PSObject.Properties.Name -contains 'validation') {
            $validationEntries = @($report.validation)
        }
        foreach ($requiredCheck in @($case.requiredChecks)) {
            $check = @($validationEntries | Where-Object {
                $_.PSObject.Properties.Name -contains 'id' -and [string]$_.id -eq $requiredCheck
            })
            $checkStatus = if ($check.Count -eq 1 -and $check[0].PSObject.Properties.Name -contains 'status') {
                [string]$check[0].status
            } else {
                ''
            }
            if ($check.Count -ne 1 -or $checkStatus -ne 'passed') {
                $failures.Add("$($case.id): required check '$requiredCheck' did not pass exactly once.") | Out-Null
                continue
            }
            $command = if ($check[0].PSObject.Properties.Name -contains 'command') { [string]$check[0].command } else { '' }
            $details = if ($check[0].PSObject.Properties.Name -contains 'details') { [string]$check[0].details } else { '' }
            if ([string]::IsNullOrWhiteSpace($command) -or [string]::IsNullOrWhiteSpace($details)) {
                $failures.Add("$($case.id): required check '$requiredCheck' lacks command or evidence details.") | Out-Null
            }
        }

        [object[]]$changes = @()
        if ($report.PSObject.Properties.Name -contains 'changes') {
            $changes = @($report.changes)
        }
        if (-not $changes.Count) {
            $failures.Add("$($case.id): implementation report contains no changed files.") | Out-Null
        }

        $workspaceRoot = if ($result.PSObject.Properties.Name -contains 'workspaceRoot') { [string]$result.workspaceRoot } else { '' }
        if ([string]::IsNullOrWhiteSpace($workspaceRoot) -or
            -not (Test-Path -LiteralPath $workspaceRoot -PathType Container)) {
            $failures.Add("$($case.id): workspaceRoot is missing or unavailable.") | Out-Null
        } else {
            & git -C $workspaceRoot rev-parse --is-inside-work-tree 2>$null | Out-Null
            if ($LASTEXITCODE -ne 0) {
                $failures.Add("$($case.id): workspaceRoot is not a readable git worktree.") | Out-Null
                continue
            }
            $actualChanges = @(
                @(& git -C $workspaceRoot diff --name-only HEAD) +
                @(& git -C $workspaceRoot ls-files --others --exclude-standard) |
                    Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } |
                    ForEach-Object { ([string]$_).Replace('\', '/') } |
                    Sort-Object -Unique
            )
            if ($LASTEXITCODE -ne 0) {
                $failures.Add("$($case.id): unable to read the workspace diff.") | Out-Null
            } else {
                $reportedChanges = @(
                    $changes |
                        Where-Object { $_.PSObject.Properties.Name -contains 'path' } |
                        ForEach-Object {
                            $path = ([string]$_.path).Replace('\', '/')
                            if ([System.IO.Path]::IsPathRooted($path) -or @($path -split '/') -contains '..') {
                                $failures.Add("$($case.id): changed path is not repository-relative: $path") | Out-Null
                            }
                            $path
                        } |
                        Sort-Object -Unique
                )
                foreach ($path in @($reportedChanges | Where-Object { $actualChanges -notcontains $_ })) {
                    $failures.Add("$($case.id): reported change is absent from the worktree diff: $path") | Out-Null
                }
                foreach ($path in @($actualChanges | Where-Object { $reportedChanges -notcontains $_ })) {
                    $failures.Add("$($case.id): worktree change is absent from the implementation report: $path") | Out-Null
                }
            }
        }

        if ($report.PSObject.Properties.Name -notcontains 'review') {
            $failures.Add("$($case.id): complete post-implementation review is missing.") | Out-Null
        } else {
            $review = $report.review
            foreach ($requiredField in @('skill', 'outcome', 'summary', 'findings', 'suppressed')) {
                if ($review.PSObject.Properties.Name -notcontains $requiredField) {
                    $failures.Add("$($case.id): review is missing '$requiredField'.") | Out-Null
                }
            }
            [object[]]$reviewFindings = @()
            if ($review.PSObject.Properties.Name -contains 'findings') {
                $reviewFindings = @($review.findings)
            }
            $reviewOutcome = if ($review.PSObject.Properties.Name -contains 'outcome') { [string]$review.outcome } else { '' }
            if ($reviewOutcome -ne 'completed') {
                $failures.Add("$($case.id): post-implementation review outcome is '$reviewOutcome'.") | Out-Null
            }
            $gatingFindings = @(
                $reviewFindings |
                    Where-Object {
                        $_.PSObject.Properties.Name -contains 'severity' -and
                        [string]$_.severity -in @('blocker', 'major')
                    }
            )
            if ($gatingFindings.Count) {
                $failures.Add("$($case.id): post-implementation review has $($gatingFindings.Count) gating finding(s).") | Out-Null
            }
        }
        [object[]]$reviewRounds = @()
        if ($report.PSObject.Properties.Name -contains 'review-rounds') {
            $reviewRounds = @($report.'review-rounds')
        }
        if (-not $reviewRounds.Count -or $reviewRounds.Count -gt $maximumReviewRounds) {
            $failures.Add("$($case.id): review-rounds must contain 1..$maximumReviewRounds entries.") | Out-Null
        } else {
            for ($index = 0; $index -lt $reviewRounds.Count; $index++) {
                $round = $reviewRounds[$index]
                $roundNumber = if ($round.PSObject.Properties.Name -contains 'round') { [int]$round.round } else { 0 }
                $roundOutcome = if ($round.PSObject.Properties.Name -contains 'outcome') { [string]$round.outcome } else { '' }
                if ($roundNumber -ne ($index + 1)) {
                    $failures.Add("$($case.id): review round numbering is not contiguous.") | Out-Null
                }
                if ($roundOutcome -notin @('clean', 'fixing', 'stalled', 'limit-reached')) {
                    $failures.Add("$($case.id): review round $roundNumber has invalid outcome '$roundOutcome'.") | Out-Null
                }
                [object[]]$roundGatingIds = @()
                if ($round.PSObject.Properties.Name -contains 'gating-finding-ids') {
                    $roundGatingIds = @($round.'gating-finding-ids')
                }
                if ($roundOutcome -eq 'clean' -and $roundGatingIds.Count) {
                    $failures.Add("$($case.id): clean review round $roundNumber must have no gating IDs.") | Out-Null
                }
                if ($roundOutcome -in @('fixing', 'stalled', 'limit-reached') -and -not $roundGatingIds.Count) {
                    $failures.Add("$($case.id): review round $roundNumber outcome '$roundOutcome' requires gating IDs.") | Out-Null
                }
                if (@($roundGatingIds | Sort-Object -Unique).Count -ne $roundGatingIds.Count) {
                    $failures.Add("$($case.id): review round $roundNumber has duplicate gating IDs.") | Out-Null
                }
            }
            if ([string]$reviewRounds[-1].outcome -ne 'clean') {
                $failures.Add("$($case.id): completed implementation must end with a clean review round.") | Out-Null
            }
        }
        [object[]]$remaining = @()
        if ($report.PSObject.Properties.Name -contains 'remaining') {
            $remaining = @($report.remaining)
        }
        if ($remaining.Count) {
            $failures.Add("$($case.id): completed report still lists remaining work.") | Out-Null
        }
    }

    if ($failures.Count) {
        Write-Host "Development fixture scoring FAILED ($($failures.Count) problem(s)):" -ForegroundColor Red
        $failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
        exit 1
    }
    Write-Host "Development fixture scoring PASSED: $(@($manifest.cases).Count) case(s)."
} else {
    Write-Host "Development fixture validation PASSED: $(@($manifest.cases).Count) cases; $fixtureBackedCount of $($capabilityIds.Count) capabilities have fixtures (minimum $minimumFixtureCoverage)."
}
