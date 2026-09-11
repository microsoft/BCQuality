<#
.SYNOPSIS
    Validates, prepares, and scores read-only AL development-guidance fixtures.
.DESCRIPTION
    Capture runner-owned evidence BEFORE invoking an agent:
      -CaptureBaseline -WorkspaceMapPath <json> -BaselinePath <new-json>
    The workspace map is {"manifest-case-id":"absolute-standalone-git-root",...}.
    Score AFTER the agent finishes:
      -BaselinePath <json> -BaselineSha256 <runner-retained-digest> -ResultsDirectory <directory>
    Preparation (-PrepareDirectory) is independent; supply -WorkspaceMapPath to
    include runner-selected target paths. Never derive target paths from results.

    Baseline, map, prepared requests, and results must be outside all targets and
    the knowledge checkout. Keep the baseline runner-only; retain the printed
    SHA256 and pass -BaselineSha256 when scoring to detect baseline tampering.
    Capture never overwrites an existing baseline. The runner must protect this
    script, the baseline/digest and its invocation from the agent.

    This compares before/after evidence, NOT an OS sandbox or a write monitor.
    It cannot detect reverted transient writes, prove that articles were opened,
    or validate semantic faithfulness of prose. Files, directories, hashes,
    stable metadata, Git HEAD/refs/index and ignored/untracked files are compared.
    Links/reparse points, hard links, external Git storage in targets,
    submodules and sparse checkouts are rejected rather than followed. Windows
    alternate data streams are included in the evidence by name, length, and
    hash; direct stream paths remain rejected. Run in quiescent repositories.
    The knowledge checkout may itself be a linked Git worktree; its Git storage
    identity is recorded explicitly.
#>
[CmdletBinding()]
param(
    [string] $Root = (Join-Path $PSScriptRoot '..'),
    [string] $ManifestPath,
    [string] $PrepareDirectory,
    [string] $ResultsDirectory,
    [switch] $CaptureBaseline,
    [string] $BaselinePath,
    [string] $BaselineSha256,
    [string] $WorkspaceMapPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'DevelopmentGuidance.Evidence.ps1')

try {
    if ($CaptureBaseline -and ($ResultsDirectory -or $PrepareDirectory)) {
        throw 'CaptureBaseline is a separate pre-run operation.'
    }
    if (($CaptureBaseline -or $ResultsDirectory) -and -not $BaselinePath) {
        throw 'Capture and scoring require BaselinePath.'
    }
    if ($ResultsDirectory -and -not $BaselineSha256) {
        throw 'Scoring requires the runner-retained pre-run BaselineSha256.'
    }
    if ($CaptureBaseline -and -not $WorkspaceMapPath) {
        throw 'Capture requires a runner-owned WorkspaceMapPath.'
    }
    if ($ResultsDirectory -and ($WorkspaceMapPath -or $PrepareDirectory)) {
        throw 'Scoring uses only the recorded workspace map; run preparation separately.'
    }
    $Root = Get-GuidanceSafePath $Root -Directory
    if (-not $ManifestPath) { $ManifestPath = Join-Path $Root 'evaluation\development-guidance-fixtures.json' }
    $ManifestPath = Get-GuidanceSafePath $ManifestPath -File
    $manifest = Read-GuidanceJson $ManifestPath
    Assert-GuidanceManifest $manifest $Root
    $caseIds = @($manifest.cases | ForEach-Object { $_.id })
    $workspaces = [ordered]@{}
    $baseline = $null
    if ($WorkspaceMapPath) {
        $WorkspaceMapPath = Get-GuidanceSafePath $WorkspaceMapPath -File
        $map = Read-GuidanceJson $WorkspaceMapPath
        Assert-GuidanceObject $map 'workspace map'
        if ($map.Count -ne $caseIds.Count) { throw 'Workspace map must bind exactly every manifest case.' }
        foreach ($id in $caseIds) {
            Assert-GuidanceString $map[$id] 'workspace map value'
            if (-not [IO.Path]::IsPathFullyQualified($map[$id])) { throw 'Workspace roots must be absolute.' }
            $workspaces[$id] = Get-GuidanceSafePath $map[$id] -Directory
        }
    }
    if ($ResultsDirectory) {
        $BaselinePath = Get-GuidanceSafePath $BaselinePath -File
        if ($BaselineSha256 -cnotmatch '^[0-9A-Fa-f]{64}$') {
            throw 'BaselineSha256 must be a SHA256 digest.'
        }
        if ((Get-GuidanceHash $BaselinePath) -ne $BaselineSha256) {
            throw 'Runner baseline digest mismatch.'
        }
        $baseline = Read-GuidanceJson $BaselinePath
        Assert-GuidanceObject $baseline 'baseline' @('version', 'kind', 'root', 'manifestPath', 'manifestSha256', 'workspaces', 'rootSnapshot')
        if ($baseline.version -ne 1 -or $baseline.kind -cne 'bcquality-guidance-runner-baseline') {
            throw 'Unsupported runner baseline.'
        }
        if ($baseline.root -cne $Root -or $baseline.manifestPath -cne $ManifestPath -or
            $baseline.manifestSha256 -ne (Get-GuidanceHash $ManifestPath)) {
            throw 'Runner baseline does not match the knowledge root or manifest.'
        }
        Assert-GuidanceObject $baseline.workspaces 'baseline workspaces'
        if ($baseline.workspaces.Count -ne $caseIds.Count) { throw 'Runner baseline case set mismatch.' }
        foreach ($id in $caseIds) {
            $entry = $baseline.workspaces[$id]
            Assert-GuidanceObject $entry 'baseline workspace entry' @('caseId', 'root', 'snapshot')
            if ($entry.caseId -cne (Get-GuidanceCaseId $id)) { throw 'Runner baseline case identity mismatch.' }
            $workspaces[$id] = Get-GuidanceSafePath $entry.root -Directory
        }
    }
    $protectedRoots = @($Root) + @($workspaces.Values)
    for ($i = 0; $i -lt $protectedRoots.Count; $i++) {
        for ($j = $i + 1; $j -lt $protectedRoots.Count; $j++) {
            if ((Test-GuidanceWithin $protectedRoots[$i] $protectedRoots[$j]) -or
                (Test-GuidanceWithin $protectedRoots[$j] $protectedRoots[$i])) {
                throw 'Knowledge checkout and case workspaces must be distinct, non-overlapping roots.'
            }
        }
    }
    foreach ($artifact in @($BaselinePath, $WorkspaceMapPath, $PrepareDirectory, $ResultsDirectory)) {
        if ($artifact) {
            $safeArtifact = Get-GuidanceSafePath $artifact -AllowMissing
            foreach ($protectedRoot in $protectedRoots) {
                if (Test-GuidanceWithin $safeArtifact $protectedRoot) {
                    throw 'Runner artifacts must be outside target workspaces and the knowledge checkout.'
                }
            }
        }
    }
    if ($CaptureBaseline) {
        $BaselinePath = Get-GuidanceSafePath $BaselinePath -AllowMissing
        if (Test-Path -LiteralPath $BaselinePath) { throw 'Baseline already exists; capture never overwrites evidence.' }
        $snapshots = [ordered]@{}
        foreach ($id in $caseIds) {
            $snapshots[$id] = [ordered]@{
                caseId = Get-GuidanceCaseId $id
                root = $workspaces[$id]
                snapshot = Get-GuidanceSnapshot $workspaces[$id] -Target
            }
        }
        $record = [ordered]@{
            kind = 'bcquality-guidance-runner-baseline'
            version = 1
            root = $Root
            manifestPath = $ManifestPath
            manifestSha256 = Get-GuidanceHash $ManifestPath
            rootSnapshot = Get-GuidanceSnapshot $Root
            workspaces = $snapshots
        }
        Write-GuidanceNewJson $BaselinePath $record
        Write-Host "Guidance baseline captured. Runner SHA256: $(Get-GuidanceHash $BaselinePath)"
    } elseif ($PrepareDirectory) {
        $PrepareDirectory = Get-GuidanceSafePath $PrepareDirectory -AllowMissing
        if ((Test-Path -LiteralPath $PrepareDirectory) -and
            @(Get-ChildItem -LiteralPath $PrepareDirectory -Force).Count) {
            throw 'PrepareDirectory must be new or empty; existing requests/evidence are never overwritten.'
        }
        [IO.Directory]::CreateDirectory($PrepareDirectory) | Out-Null
        # The index builder walks recursively; reject linked corpus paths first.
        Assert-GuidanceTree $Root
        & (Join-Path $Root 'tools\Build-KnowledgeIndex.ps1') -BCQualityRoot $Root `
            -IndexPath (Join-Path $PrepareDirectory 'knowledge-index.json') | Out-Null
        $skillInstructions = [IO.File]::ReadAllText((Resolve-GuidanceReference $Root $manifest.skill))
        foreach ($case in $manifest.cases) {
            $modelId = Get-GuidanceCaseId $case.id
            $request = [ordered]@{
                protocol = 'Run the supplied read-only skill on the runner-assigned repository and existing plan. Return only caseId and guidanceReport. The runner captures evidence before invocation; do not capture or modify it. Do not create artifacts in the target or knowledge checkout.'
                caseId = $modelId
                skill = $manifest.skill
                skillInstructions = $skillInstructions
                knowledgeIndex = Join-Path $PrepareDirectory 'knowledge-index.json'
                knowledgeRoot = $Root
                'task-context' = [ordered]@{
                    goal = Get-GuidancePlanRequest $case.'development-plan'
                    'inputs-available' = @('development-plan', 'repository')
                    'bc-version' = $case.context.'bc-version'
                    technologies = $case.context.technologies
                    countries = $case.context.countries
                    'application-area' = $case.context.'application-area'
                }
                'development-plan' = $case.'development-plan'
                resultSchema = Get-GuidanceResultSchema $modelId
            }
            if ($workspaces.Count) { $request.repository = $workspaces[$case.id] }
            Write-GuidanceNewJson (Join-Path $PrepareDirectory "request-$modelId.json") $request
        }
        Write-Host "Development guidance preparation PASSED: $($caseIds.Count) case(s)."
    } elseif ($ResultsDirectory) {
        $ResultsDirectory = Get-GuidanceSafePath $ResultsDirectory -Directory
        $failures = [Collections.Generic.List[string]]::new()
        if (-not (Test-GuidanceSnapshotEqual $baseline.rootSnapshot (Get-GuidanceSnapshot $Root))) {
            $failures.Add('Knowledge checkout identity/content changed after baseline capture.')
        }
        foreach ($case in $manifest.cases) {
            $id = $case.id
            try {
                if (-not (Test-GuidanceSnapshotEqual $baseline.workspaces[$id].snapshot `
                        (Get-GuidanceSnapshot $workspaces[$id] -Target))) {
                    throw 'Target repository identity/content changed after baseline capture.'
                }
                $resultPath = Get-GuidanceSafePath (Join-Path $ResultsDirectory "result-$(Get-GuidanceCaseId $id).json") -File
                $result = Read-GuidanceJson $resultPath
                Assert-GuidanceResult $result $case $manifest $Root $workspaces[$id]
            } catch {
                # Only evaluator-authored diagnostics are printed, never model or file contents.
                $failures.Add("${id}: $(Get-GuidanceDiagnostic $_)")
            }
        }
        if ($failures.Count) {
            Write-Host "Development guidance scoring FAILED ($($failures.Count) problem(s)):"
            $failures | ForEach-Object { Write-Host "  - $_" }
            exit 1
        }
        Write-Host "Development guidance scoring PASSED: $($caseIds.Count) case(s)."
    } else {
        Write-Host "Development guidance fixture validation PASSED: $($caseIds.Count) case(s)."
    }
} catch {
    Write-Host "Development guidance FAILED: $(Get-GuidanceDiagnostic $_)"
    exit 1
}
