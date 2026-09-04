<#
.SYNOPSIS
    Validates Microsoft Learn ingestion coverage and reports progress.
#>
[CmdletBinding()]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..')),
    [string] $CatalogPath,
    [string] $CoveragePath,
    [switch] $Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path -LiteralPath $Root).Path
if (-not $CatalogPath) {
    $CatalogPath = Join-Path $Root 'coverage/microsoft-learn-developer-catalog.json'
}
if (-not $CoveragePath) {
    $CoveragePath = Join-Path $Root 'coverage/learn-coverage.json'
}

foreach ($path in @($CatalogPath, $CoveragePath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Coverage input not found: $path"
    }
}

$catalog = Get-Content -LiteralPath $CatalogPath -Raw | ConvertFrom-Json
$coverage = Get-Content -LiteralPath $CoveragePath -Raw | ConvertFrom-Json
$problems = [System.Collections.Generic.List[string]]::new()

if ($catalog.version -ne 1) {
    $problems.Add("Unsupported catalog version: $($catalog.version)") | Out-Null
}
if ($coverage.version -ne 1) {
    $problems.Add("Unsupported coverage version: $($coverage.version)") | Out-Null
}
if ([string]$coverage.catalog -ne 'coverage/microsoft-learn-developer-catalog.json') {
    $problems.Add("Coverage catalog path must be coverage/microsoft-learn-developer-catalog.json.") | Out-Null
}

$catalogUnits = @{}
foreach ($unit in @($catalog.units)) {
    $uid = [string]$unit.uid
    if ($catalogUnits.ContainsKey($uid)) {
        $problems.Add("Duplicate catalog unit uid: $uid") | Out-Null
    } else {
        $catalogUnits[$uid] = $unit
    }
    if ([string]::IsNullOrWhiteSpace([string]$unit.title)) {
        $problems.Add("${uid}: catalog unit title is empty.") | Out-Null
    }
    if ([string]::IsNullOrWhiteSpace([string]$unit.url) -or
        -not ([string]$unit.url).StartsWith('https://learn.microsoft.com/', [System.StringComparison]::OrdinalIgnoreCase)) {
        $problems.Add("${uid}: catalog unit URL is missing or not a Microsoft Learn URL.") | Out-Null
    }
}

$catalogModules = @{}
foreach ($module in @($catalog.modules)) {
    $uid = [string]$module.uid
    if ($catalogModules.ContainsKey($uid)) {
        $problems.Add("Duplicate catalog module uid: $uid") | Out-Null
    } else {
        $catalogModules[$uid] = $module
    }
    foreach ($unitUid in @($module.unitUids)) {
        if (-not $catalogUnits.ContainsKey([string]$unitUid)) {
            $problems.Add("${uid}: references unknown unit '$unitUid'.") | Out-Null
        }
    }
}

$catalogPaths = @{}
foreach ($path in @($catalog.learningPaths)) {
    $uid = [string]$path.uid
    if ($catalogPaths.ContainsKey($uid)) {
        $problems.Add("Duplicate catalog learning-path uid: $uid") | Out-Null
    } else {
        $catalogPaths[$uid] = $path
    }
    foreach ($moduleUid in @($path.moduleUids)) {
        if (-not $catalogModules.ContainsKey([string]$moduleUid)) {
            $problems.Add("${uid}: references unknown module '$moduleUid'.") | Out-Null
        }
    }
}

if ([int]$catalog.counts.units -ne $catalogUnits.Count) {
    $problems.Add("Catalog unit count does not match units array.") | Out-Null
}
if ([int]$catalog.counts.modules -ne $catalogModules.Count) {
    $problems.Add("Catalog module count does not match modules array.") | Out-Null
}
if ([int]$catalog.counts.learningPaths -ne $catalogPaths.Count) {
    $problems.Add("Catalog learning-path count does not match learningPaths array.") | Out-Null
}

foreach ($unit in @($catalog.units)) {
    foreach ($moduleUid in @($unit.moduleUids)) {
        if (-not $catalogModules.ContainsKey([string]$moduleUid)) {
            $problems.Add("$($unit.uid): references unknown module '$moduleUid'.") | Out-Null
        } elseif (@($catalogModules[[string]$moduleUid].unitUids) -notcontains [string]$unit.uid) {
            $problems.Add("$($unit.uid): module '$moduleUid' does not link back to the unit.") | Out-Null
        }
    }
}

$validStatuses = @('in-progress', 'complete')
$validDispositions = @('candidate', 'authored', 'covered-existing', 'rejected', 'deferred')
$seenUnits = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$seenOutcomes = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$articlePaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$dispositionCounts = @{}
foreach ($disposition in $validDispositions) {
    $dispositionCounts[$disposition] = 0
}

foreach ($unitCoverage in @($coverage.units)) {
    $uid = [string]$unitCoverage.uid
    if (-not $seenUnits.Add($uid)) {
        $problems.Add("Duplicate coverage unit uid: $uid") | Out-Null
    }
    if (-not $catalogUnits.ContainsKey($uid)) {
        $problems.Add("Coverage unit is absent from the catalog: $uid") | Out-Null
    }

    $reviewStatus = [string]$unitCoverage.reviewStatus
    if ($validStatuses -notcontains $reviewStatus) {
        $problems.Add("${uid}: invalid reviewStatus '$reviewStatus'.") | Out-Null
    }

    [object[]]$outcomes = @()
    if ($unitCoverage.PSObject.Properties.Name -contains 'outcomes') {
        $outcomes = @($unitCoverage.outcomes)
    }
    if ($reviewStatus -eq 'in-progress' -and -not $outcomes.Count) {
        $problems.Add("${uid}: an in-progress unit must contain at least one outcome.") | Out-Null
    }

    foreach ($outcome in $outcomes) {
        $id = [string]$outcome.id
        if ($id -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
            $problems.Add("${uid}: outcome id must be kebab-case: '$id'.") | Out-Null
        } elseif (-not $seenOutcomes.Add($id)) {
            $problems.Add("Duplicate outcome id: $id") | Out-Null
        }

        $disposition = [string]$outcome.disposition
        if ($validDispositions -notcontains $disposition) {
            $problems.Add("${id}: invalid disposition '$disposition'.") | Out-Null
            continue
        }
        $dispositionCounts[$disposition]++

        if ([string]::IsNullOrWhiteSpace([string]$outcome.title)) {
            $problems.Add("${id}: title is required.") | Out-Null
        }

        if ($disposition -in @('candidate', 'authored', 'covered-existing')) {
            if ([string]::IsNullOrWhiteSpace([string]$outcome.domain)) {
                $problems.Add("${id}: domain is required for disposition '$disposition'.") | Out-Null
            }
        }

        [object[]]$paths = @()
        if ($outcome.PSObject.Properties.Name -contains 'articlePaths') {
            $paths = @($outcome.articlePaths)
        }
        if ($disposition -in @('authored', 'covered-existing')) {
            if (-not $paths.Count) {
                $problems.Add("${id}: articlePaths is required for disposition '$disposition'.") | Out-Null
            }
            foreach ($relativePath in $paths) {
                $relativePath = [string]$relativePath
                if ($relativePath.Contains('\') -or -not $relativePath.EndsWith('.md')) {
                    $problems.Add("${id}: article path must be a forward-slash .md path: $relativePath") | Out-Null
                    continue
                }
                if (-not (Test-Path -LiteralPath (Join-Path $Root $relativePath) -PathType Leaf)) {
                    $problems.Add("${id}: article does not exist: $relativePath") | Out-Null
                }
                $articlePaths.Add($relativePath) | Out-Null
            }
        } elseif ($paths.Count) {
            $problems.Add("${id}: disposition '$disposition' must not set articlePaths.") | Out-Null
        }

        $rationale = if ($outcome.PSObject.Properties.Name -contains 'rationale') {
            [string]$outcome.rationale
        } else {
            ''
        }
        if ($disposition -in @('rejected', 'deferred') -and
            [string]::IsNullOrWhiteSpace($rationale)) {
            $problems.Add("${id}: rationale is required for disposition '$disposition'.") | Out-Null
        }
    }
}

if ($problems.Count) {
    Write-Host "Learn coverage validation FAILED ($($problems.Count) problem(s)):" -ForegroundColor Red
    $problems | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

$complete = @($coverage.units | Where-Object reviewStatus -eq 'complete').Count
$inProgress = @($coverage.units | Where-Object reviewStatus -eq 'in-progress').Count
$summary = [ordered]@{
    catalogUnits = $catalogUnits.Count
    completeUnits = $complete
    inProgressUnits = $inProgress
    unreviewedUnits = $catalogUnits.Count - $complete - $inProgress
    candidateOutcomes = $dispositionCounts.candidate
    authoredOutcomes = $dispositionCounts.authored
    coveredExistingOutcomes = $dispositionCounts.'covered-existing'
    rejectedOutcomes = $dispositionCounts.rejected
    deferredOutcomes = $dispositionCounts.deferred
    referencedArticles = $articlePaths.Count
}

if ($Json) {
    $summary | ConvertTo-Json
} else {
    $message = (
        'Learn coverage: {0} units; {1} complete, {2} in progress, {3} unreviewed; ' +
        '{4} candidate outcomes, {5} authored outcomes, {6} existing-coverage outcomes.'
    ) -f @(
        $summary.catalogUnits,
        $summary.completeUnits,
        $summary.inProgressUnits,
        $summary.unreviewedUnits,
        $summary.candidateOutcomes,
        $summary.authoredOutcomes,
        $summary.coveredExistingOutcomes
    )
    Write-Host $message
}
