<#
.SYNOPSIS
    Updates the committed Microsoft Learn Business Central developer catalog.

.DESCRIPTION
    Filters a Microsoft Learn catalog payload to modules tagged for both
    dynamics-business-central and developer. The output is intentionally only
    source metadata; editorial dispositions live in coverage/learn-coverage.json.

    The legacy unauthenticated catalog endpoint remains the default while it is
    available. Use -CatalogPath with an export from the authenticated Learn
    Platform API when the legacy endpoint is retired.
#>
[CmdletBinding(DefaultParameterSetName = 'Remote')]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..')),

    [Parameter(ParameterSetName = 'Remote')]
    [uri] $CatalogUri = 'https://learn.microsoft.com/api/catalog/?locale=en-us',

    [Parameter(Mandatory, ParameterSetName = 'File')]
    [string] $CatalogPath,

    [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path -LiteralPath $Root).Path
if (-not $OutputPath) {
    $OutputPath = Join-Path $Root 'coverage/microsoft-learn-developer-catalog.json'
}

function Get-CanonicalUrl {
    param([string] $Url)

    if ([string]::IsNullOrWhiteSpace($Url)) {
        return $null
    }

    $parsed = [uri]$Url
    return "$($parsed.Scheme)://$($parsed.Host)$($parsed.AbsolutePath)".TrimEnd('/')
}

function Get-CatalogProperty {
    param(
        [object] $Object,
        [string] $Name,
        [object] $Default = $null
    )

    $property = $Object.PSObject.Properties[$Name]
    if ($property) {
        return $property.Value
    }
    return $Default
}

function Get-LatestTimestamp {
    param([object[]] $Values)

    $timestamps = @(
        $Values |
            Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) } |
            ForEach-Object { [datetimeoffset]::Parse([string]$_) } |
            Sort-Object
    )
    if (-not $timestamps.Count) {
        return $null
    }

    return $timestamps[-1].ToUniversalTime().ToString(
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
        [System.Globalization.CultureInfo]::InvariantCulture
    )
}

function Convert-ToUtcTimestamp {
    param([object] $Value)

    return ([datetimeoffset]$Value).ToUniversalTime().ToString(
        "yyyy-MM-dd'T'HH:mm:ss'Z'",
        [System.Globalization.CultureInfo]::InvariantCulture
    )
}

$catalog = if ($PSCmdlet.ParameterSetName -eq 'File') {
    Get-Content -LiteralPath $CatalogPath -Raw | ConvertFrom-Json
} else {
    Invoke-RestMethod -Uri $CatalogUri
}

$product = 'dynamics-business-central'
$role = 'developer'
$modules = @(
    $catalog.modules |
        Where-Object {
            @(Get-CatalogProperty $_ 'products' @()) -contains $product -and
            @(Get-CatalogProperty $_ 'roles' @()) -contains $role
        } |
        Sort-Object uid
)

$moduleIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($module in $modules) {
    $moduleIds.Add([string]$module.uid) | Out-Null
}

$learningPaths = @(
    $catalog.learningPaths |
        Where-Object {
            $path = $_
            $pathModules = @(Get-CatalogProperty $path 'modules' @())
            @($pathModules | Where-Object { $moduleIds.Contains([string]$_) }).Count -gt 0 -and
            @(Get-CatalogProperty $path 'products' @()) -contains $product -and
            @(Get-CatalogProperty $path 'roles' @()) -contains $role
        } |
        Sort-Object uid
)

$pathIdsByModule = @{}
foreach ($path in $learningPaths) {
    foreach ($moduleId in @(Get-CatalogProperty $path 'modules' @())) {
        if (-not $moduleIds.Contains([string]$moduleId)) {
            continue
        }
        if (-not $pathIdsByModule.ContainsKey([string]$moduleId)) {
            $pathIdsByModule[[string]$moduleId] = [System.Collections.Generic.List[string]]::new()
        }
        $pathIdsByModule[[string]$moduleId].Add([string]$path.uid)
    }
}

$unitById = @{}
foreach ($unit in @(Get-CatalogProperty $catalog 'units' @())) {
    $unitById[[string]$unit.uid] = $unit
}

$moduleIdsByUnit = @{}
$moduleById = @{}
$unitIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($module in $modules) {
    $moduleById[[string]$module.uid] = $module
    foreach ($unitId in @(Get-CatalogProperty $module 'units' @())) {
        $unitId = [string]$unitId
        $unitIds.Add($unitId) | Out-Null
        if (-not $moduleIdsByUnit.ContainsKey($unitId)) {
            $moduleIdsByUnit[$unitId] = [System.Collections.Generic.List[string]]::new()
        }
        $moduleIdsByUnit[$unitId].Add([string]$module.uid)
    }
}

$pathRecords = @(
    foreach ($path in $learningPaths) {
        [ordered]@{
            uid = [string]$path.uid
            title = [string]$path.title
            url = Get-CanonicalUrl ([string]$path.url)
            lastModified = if (Get-CatalogProperty $path 'last_modified') {
                Convert-ToUtcTimestamp (Get-CatalogProperty $path 'last_modified')
            } else {
                $null
            }
            durationInMinutes = [int](Get-CatalogProperty $path 'duration_in_minutes' 0)
            moduleUids = @(
                @(Get-CatalogProperty $path 'modules' @()) |
                    Where-Object { $moduleIds.Contains([string]$_) } |
                    ForEach-Object { [string]$_ } |
                    Sort-Object -Unique
            )
        }
    }
)

$moduleRecords = @(
    foreach ($module in $modules) {
        [ordered]@{
            uid = [string]$module.uid
            title = [string]$module.title
            summary = [string](Get-CatalogProperty $module 'summary' '')
            url = Get-CanonicalUrl ([string]$module.url)
            lastModified = Convert-ToUtcTimestamp (Get-CatalogProperty $module 'last_modified')
            durationInMinutes = [int](Get-CatalogProperty $module 'duration_in_minutes' 0)
            levels = @(@(Get-CatalogProperty $module 'levels' @()) | ForEach-Object { [string]$_ } | Sort-Object -Unique)
            subjects = @(@(Get-CatalogProperty $module 'subjects' @()) | ForEach-Object { [string]$_ } | Sort-Object -Unique)
            learningPathUids = if ($pathIdsByModule.ContainsKey([string]$module.uid)) {
                @($pathIdsByModule[[string]$module.uid] | Sort-Object -Unique)
            } else {
                @()
            }
            unitUids = @(@(Get-CatalogProperty $module 'units' @()) | ForEach-Object { [string]$_ })
        }
    }
)

$unitRecords = @(
    foreach ($unitId in @($unitIds | Sort-Object)) {
        if (-not $unitById.ContainsKey($unitId)) {
            throw "Catalog module references missing unit '$unitId'."
        }
        $unit = $unitById[$unitId]
        $unitUrl = [string](Get-CatalogProperty $unit 'url' '')
        if ([string]::IsNullOrWhiteSpace($unitUrl)) {
            $moduleId = [string]@($moduleIdsByUnit[$unitId])[0]
            $moduleUrl = Get-CanonicalUrl ([string]$moduleById[$moduleId].url)
            $unitSlug = if ($unitId.StartsWith("$moduleId.", [System.StringComparison]::Ordinal)) {
                $unitId.Substring($moduleId.Length + 1)
            } else {
                @($unitId -split '\.')[-1]
            }
            $unitUrl = "$moduleUrl/$unitSlug"
        }
        [ordered]@{
            uid = $unitId
            title = [string]$unit.title
            url = Get-CanonicalUrl $unitUrl
            lastModified = if (Get-CatalogProperty $unit 'last_modified') {
                Convert-ToUtcTimestamp (Get-CatalogProperty $unit 'last_modified')
            } else {
                $null
            }
            durationInMinutes = [int](Get-CatalogProperty $unit 'duration_in_minutes' 0)
            moduleUids = @($moduleIdsByUnit[$unitId] | Sort-Object -Unique)
        }
    }
)

$snapshot = [ordered]@{
    version = 1
    source = [ordered]@{
        provider = 'Microsoft Learn'
        catalogUri = if ($PSCmdlet.ParameterSetName -eq 'Remote') { [string]$CatalogUri } else { $null }
        locale = 'en-us'
        filters = [ordered]@{
            product = $product
            role = $role
        }
        catalogLastModified = Get-LatestTimestamp @(
            @($moduleRecords | ForEach-Object lastModified) +
            @($unitRecords | ForEach-Object lastModified) +
            @($pathRecords | ForEach-Object lastModified)
        )
    }
    counts = [ordered]@{
        learningPaths = $pathRecords.Count
        modules = $moduleRecords.Count
        units = $unitRecords.Count
    }
    learningPaths = $pathRecords
    modules = $moduleRecords
    units = $unitRecords
}

$outputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}
$snapshot | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
Write-Host "Microsoft Learn developer catalog: $($pathRecords.Count) paths, $($moduleRecords.Count) modules, $($unitRecords.Count) units."
Write-Host "Catalog: $OutputPath"
