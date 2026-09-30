<#
.SYNOPSIS
    Resolves a super-skill's ordered leaf worklist across enabled layers.
#>
[CmdletBinding()]
param(
    [string] $BCQualityRoot,
    [string] $IndexPath,
    [Parameter(Mandatory)]
    [string] $SuperSkillPath,
    [string[]] $EnabledLayers = @('microsoft', 'community', 'custom'),
    [string[]] $DisabledSkills = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $BCQualityRoot) {
    $BCQualityRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}
$BCQualityRoot = (Resolve-Path -LiteralPath $BCQualityRoot).Path
if (-not $IndexPath) {
    $IndexPath = Join-Path $BCQualityRoot 'skill-index.json'
}
if (-not (Test-Path -LiteralPath $IndexPath -PathType Leaf)) {
    & (Join-Path $PSScriptRoot 'Build-SkillIndex.ps1') -BCQualityRoot $BCQualityRoot -IndexPath $IndexPath | Out-Null
}

$knownLayers = @('microsoft', 'community', 'custom')
$unknownLayers = @($EnabledLayers | Where-Object { $_ -cnotin $knownLayers })
if ($unknownLayers.Count) {
    throw "Unknown enabled layers: $($unknownLayers -join ', ')"
}

$index = Get-Content -LiteralPath $IndexPath -Raw | ConvertFrom-Json
$skills = @($index.skills)
$superSkills = @($skills | Where-Object path -CEQ $SuperSkillPath)
if ($superSkills.Count -ne 1) {
    throw "Expected one indexed super-skill at '$SuperSkillPath', found $($superSkills.Count)."
}
$superSkill = $superSkills[0]
if (-not @($superSkill.subSkills).Count) {
    throw "Action skill '$SuperSkillPath' is not a super-skill."
}

$precedence = @{ microsoft = 0; community = 1; custom = 2 }
$resolved = [Collections.Generic.List[object]]::new()
$skipped = [Collections.Generic.List[object]]::new()
foreach ($declaredPath in @($superSkill.subSkills)) {
    $declared = @($skills | Where-Object path -CEQ $declaredPath)
    if ($declared.Count -ne 1) {
        throw "Declared sub-skill '$declaredPath' is not uniquely indexed."
    }

    $candidates = @(
        $skills |
            Where-Object {
                $_.id -CEQ $declared[0].id -and
                $_.layer -cin $EnabledLayers -and
                $_.path -cnotin $DisabledSkills -and
                -not @($_.subSkills).Count
            } |
            Sort-Object @{ Expression = { $precedence[$_.layer] }; Descending = $true }, path
    )
    if (-not $candidates.Count) {
        $skipped.Add([pscustomobject][ordered]@{
            id           = $declared[0].id
            declaredPath = $declaredPath
            reason       = 'configuration'
        }) | Out-Null
        continue
    }

    $winner = $candidates[0]
    $resolved.Add([pscustomobject][ordered]@{
        id           = $winner.id
        path         = $winner.path
        version      = $winner.version
        layer        = $winner.layer
        declaredPath = $declaredPath
    }) | Out-Null
}

return [pscustomobject][ordered]@{
    superSkill = [pscustomobject][ordered]@{
        id      = $superSkill.id
        path    = $superSkill.path
        version = $superSkill.version
    }
    subSkills = @($resolved)
    skipped   = @($skipped)
}