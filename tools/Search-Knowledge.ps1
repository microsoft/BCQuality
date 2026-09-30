<#
.SYNOPSIS
    Returns bounded pages of every domain/layer/READ-applicable catalog row.
.DESCRIPTION
    Consumes Entry's prepared index read-only. Results are never ranked, sampled,
    top-k limited, deduplicated by basename, or narrowed by query text. Omit an
    unknown task dimension; an explicit empty array is a known empty set.
#>
#requires -Version 7.2
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()] [string] $BCQualityRoot = (Split-Path $PSScriptRoot -Parent),
    [Parameter(Mandatory)] [ValidateNotNullOrEmpty()]
    [ValidateScript({ -not [string]::IsNullOrWhiteSpace($_) })] [string] $Domain,
    [ValidateSet('microsoft', 'community', 'custom')]
    [AllowEmptyCollection()] [string[]] $EnabledLayers = @('microsoft', 'community', 'custom'),
    [ValidateRange(1, 2147483647)] [int] $BCVersion,
    [AllowEmptyCollection()] [string[]] $Technologies,
    [AllowEmptyCollection()] [string[]] $Countries,
    [AllowEmptyCollection()] [string[]] $ApplicationAreas,
    [switch] $ExcludeConditional,
    [string] $IndexPath,
    [ValidateRange(1024, 16000)] [int] $MaxBytes = 16000,
    [ValidateRange(0, 2147483647)] [int] $Offset = 0,
    [ValidatePattern('^[a-f0-9]{64}$')] [string] $Snapshot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Knowledge-Retrieval.ps1')
. (Join-Path $PSScriptRoot 'Bounded-Results.ps1')

$BCQualityRoot = Resolve-KnowledgeRoot $BCQualityRoot
if (-not $IndexPath) {
    $IndexPath = Join-Path $BCQualityRoot 'knowledge-index.json'
}
if ($null -eq $EnabledLayers) {
    throw 'EnabledLayers must be an array; use an empty array to disable all layers.'
}
if (@($EnabledLayers | Where-Object { $_ -cnotin @('microsoft', 'community', 'custom') }).Count -or
    @($EnabledLayers | Group-Object -CaseSensitive | Where-Object Count -gt 1).Count) {
    throw 'EnabledLayers must contain unique canonical lowercase layer names.'
}

$context = [ordered]@{}
foreach ($pair in @(
    @('BCVersion', 'bc-version'),
    @('Technologies', 'technologies'),
    @('Countries', 'countries'),
    @('ApplicationAreas', 'application-area')
)) {
    if (-not $PSBoundParameters.ContainsKey($pair[0])) {
        continue
    }
    $value = $PSBoundParameters[$pair[0]]
    if ($null -eq $value) {
        throw "Omit unknown context; do not pass null for $($pair[0])."
    }
    if ($pair[0] -ne 'BCVersion') {
        foreach ($entry in $value) {
            if ([string]::IsNullOrWhiteSpace($entry) -or $entry -cne $entry.Trim()) {
                throw "Invalid context value for $($pair[0]): '$entry'"
            }
        }
    }
    $context[$pair[1]] = $value
}
if ($context.Contains('technologies') -and $context['technologies'] -ccontains 'all') {
    throw "Technologies has no 'all' sentinel. Omit unknown context."
}

$recovery = "Run Entry preparation once before dispatch, or use READ's path-discovery fallback. Do not rebuild in a leaf."
$preparedIndex = Read-PreparedKnowledgeIndex -IndexPath $IndexPath -Recovery $recovery
$index = $preparedIndex.index
$indexContent = $preparedIndex.content
$byPath = $preparedIndex.byPath
$paths = $preparedIndex.paths

# The v1 generator historically serialized an omitted EnabledLayers parameter as [null].
$unrestricted = $index.enabledLayers.Count -eq 0 -or
    ($index.enabledLayers.Count -eq 1 -and $null -eq $index.enabledLayers[0])
$indexedLayers = @(
    if ($unrestricted) {
        'microsoft', 'community', 'custom'
    }
    else {
        $index.enabledLayers
    }
)
if (@($indexedLayers | Where-Object { $_ -cnotin @('microsoft', 'community', 'custom') }).Count -or
    @($indexedLayers | Group-Object -CaseSensitive | Where-Object Count -gt 1).Count -or
    @($EnabledLayers | Where-Object { $_ -cnotin $indexedLayers }).Count) {
    throw "Index layer coverage does not cover EnabledLayers. $recovery"
}

foreach ($path in $paths) {
    $row = $byPath[$path]
    if ($row.layer -cnotin $indexedLayers) {
        throw "Index row layer is outside index coverage: $path. $recovery"
    }
    $problem = Get-KnowledgeMetadataProblem -Row $row
    if ($problem) {
        throw "Malformed knowledge index row at ${path}: $problem. $recovery"
    }
}

$defaults = [ordered]@{
    'bc-version' = @('all')
    technologies = @('al')
    countries = @('w1')
    'application-area' = @('all')
}
$candidates = [Collections.Generic.List[object]]::new()
$excluded = [Collections.Generic.List[object]]::new()
foreach ($path in $paths) {
    $row = $byPath[$path]
    if ($row.domain -cne $Domain) {
        continue
    }

    $unknown = [Collections.Generic.List[string]]::new()
    $matchesContext = $true
    foreach ($field in $defaults.Keys) {
        $values = $row[$field]
        if ($field -eq 'bc-version') {
            $values = @(Get-NormalizedKnowledgeVersions -Values $values)
        }
        $sentinel = switch ($field) {
            'bc-version' { 'all' }
            'countries' { 'w1' }
            'application-area' { 'all' }
            default { '' }
        }
        if ($sentinel -and $values -ccontains $sentinel) {
            continue
        }
        if (-not $context.Contains($field)) {
            $unknown.Add($field)
            continue
        }

        $target = $context[$field]
        $matched = $false
        if ($field -eq 'bc-version') {
            # Compare as bigint on both sides: metadata validation accepts bounds
            # wider than Int32, and an int left operand would coerce them down.
            $targetVersion = [bigint]$target
            if ($values.Count -eq 1 -and $values[0] -match '^(\d+)\.\.(\d+)?$') {
                $matched = $targetVersion -ge [bigint]::Parse($Matches[1]) -and
                    (-not $Matches[2] -or $targetVersion -le [bigint]::Parse($Matches[2]))
            }
            else {
                $matched = @($values | Where-Object { [bigint]::Parse($_) -eq $targetVersion }).Count -gt 0
            }
        }
        else {
            $matched = @($values | Where-Object { $target -ccontains $_ }).Count -gt 0
        }
        if (-not $matched) {
            $matchesContext = $false
            break
        }
    }
    if (-not $matchesContext -or ($ExcludeConditional -and $unknown.Count)) {
        continue
    }
    $null = Resolve-KnowledgePath -Root $BCQualityRoot -Path $path

    $candidate = [ordered]@{
        path = $path
        layer = $row.layer
        keywords = $row.keywords
        title = $row.title
        description = $row.description
    }
    foreach ($field in $defaults.Keys) {
        if (($row[$field] -join "`0") -cne ($defaults[$field] -join "`0")) {
            $candidate[$field] = $row[$field]
        }
    }
    $candidate.applicability = if ($unknown.Count) { 'conditional' } else { 'applicable' }
    $candidate.unknownDimensions = @($unknown)
    if ($row.layer -cin $EnabledLayers) {
        $candidates.Add($candidate)
    }
    else {
        $excluded.Add($candidate)
    }
}

$header = [ordered]@{
    version = 2
    domain = $Domain
    context = $context
    enabledLayers = @($EnabledLayers)
    indexedLayers = @($indexedLayers)
    excludeConditional = [bool]$ExcludeConditional
    defaults = $defaults
    candidateCount = $candidates.Count
    excludedByConfigurationCount = $excluded.Count
}

function Get-CatalogSnapshot {
    param(
        [string] $PreparedIndexSha256,
        [Collections.IDictionary] $Request,
        [Collections.IDictionary] $Groups
    )

    $hash = [Security.Cryptography.IncrementalHash]::CreateHash(
        [Security.Cryptography.HashAlgorithmName]::SHA256
    )
    try {
        foreach ($value in @(
            $PreparedIndexSha256,
            (ConvertTo-Json -InputObject $Request -Depth 8 -Compress)
        )) {
            $hash.AppendData([Text.Encoding]::UTF8.GetBytes($value))
            $hash.AppendData([byte[]](10))
        }
        foreach ($groupName in $Groups.Keys) {
            $hash.AppendData([Text.Encoding]::UTF8.GetBytes("[$groupName]"))
            $hash.AppendData([byte[]](10))
            foreach ($row in $Groups[$groupName]) {
                $hash.AppendData([Text.Encoding]::UTF8.GetBytes(
                    (ConvertTo-Json -InputObject $row -Depth 8 -Compress)
                ))
                $hash.AppendData([byte[]](10))
            }
        }
        return [Convert]::ToHexString($hash.GetHashAndReset()).ToLowerInvariant()
    }
    finally {
        $hash.Dispose()
    }
}

$groups = [ordered]@{
    candidates = $candidates
    excludedByConfiguration = $excluded
}
$header.snapshot = Get-CatalogSnapshot -PreparedIndexSha256 $indexContent.sha256 -Request $header -Groups $groups

ConvertTo-BoundedPage -Header $header -Groups $groups -Offset $Offset -Snapshot $Snapshot -MaxBytes $MaxBytes
