<#
.SYNOPSIS
    Builds the machine-readable BCQuality action-skill index.

.DESCRIPTION
    Action-skill frontmatter remains the source of truth. This script emits the
    versioned JSON contract orchestrators consume so they do not need to parse
    Markdown or duplicate composition rules.

.PARAMETER BCQualityRoot
    BCQuality repository or filtered content root.

.PARAMETER IndexPath
    Output path. Defaults to <BCQualityRoot>/skill-index.json.

.OUTPUTS
    Returns the number of indexed action skills.
#>
[CmdletBinding()]
param(
    [string] $BCQualityRoot,
    [string] $IndexPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $BCQualityRoot) {
    $BCQualityRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}
if (-not (Test-Path -LiteralPath $BCQualityRoot -PathType Container)) {
    throw "BCQuality root not found: $BCQualityRoot"
}
$BCQualityRoot = (Resolve-Path -LiteralPath $BCQualityRoot).Path
if (-not $IndexPath) {
    $IndexPath = Join-Path $BCQualityRoot 'skill-index.json'
}

function Get-RelativePath {
    param([string] $Root, [string] $Full)

    return ($Full.Substring($Root.Length).TrimStart([char]'/', [char]'\') -replace '\\', '/')
}

function Get-Sha256 {
    param([byte[]] $Bytes)

    $sha = [Security.Cryptography.SHA256]::Create()
    try {
        return ([BitConverter]::ToString($sha.ComputeHash($Bytes)) -replace '-', '').ToLowerInvariant()
    }
    finally {
        $sha.Dispose()
    }
}

function Get-ValueSha256 {
    param([Parameter(Mandatory)] $Value)

    return Get-Sha256 -Bytes ([Text.Encoding]::UTF8.GetBytes(
        (ConvertTo-Json -InputObject $Value -Depth 12 -Compress)
    ))
}

function ConvertFrom-SkillFrontmatter {
    param(
        [string] $Path,
        [string] $Text
    )

    $lines = [regex]::Split($Text.TrimStart([char]0xfeff), '\r\n|\n|\r')
    if ($lines.Count -lt 3 -or $lines[0].Trim() -ne '---') {
        throw [IO.InvalidDataException]::new("Missing frontmatter in '$Path'.")
    }

    $end = -1
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq '---') {
            $end = $i
            break
        }
    }
    if ($end -lt 0) {
        throw [IO.InvalidDataException]::new("Unterminated frontmatter in '$Path'.")
    }

    $frontmatter = [ordered]@{}
    for ($i = 1; $i -lt $end; $i++) {
        $line = $lines[$i]
        if ($line -notmatch '^([a-zA-Z][\w-]*)\s*:\s*(.*)$') {
            continue
        }

        $key = $Matches[1]
        $value = $Matches[2].Trim()
        if ($value -eq '') {
            $items = [System.Collections.Generic.List[string]]::new()
            while ($i + 1 -lt $end -and $lines[$i + 1] -match '^\s+-\s+(.+?)\s*$') {
                $i++
                $items.Add($Matches[1].Trim().Trim('"', "'")) | Out-Null
            }
            $frontmatter[$key] = @($items)
            continue
        }

        if ($value -match '^\[(.*)\]$') {
            $inner = $Matches[1].Trim()
            $values = [System.Collections.Generic.List[object]]::new()
            if ($inner) {
                foreach ($item in $inner -split '\s*,\s*') {
                    $normalized = $item.Trim().Trim('"', "'")
                    $number = 0
                    if ($key -eq 'bc-version' -and [int]::TryParse($normalized, [ref]$number)) {
                        $values.Add($number) | Out-Null
                    }
                    else {
                        $values.Add($normalized) | Out-Null
                    }
                }
            }
            $frontmatter[$key] = [object[]]@($values)
            continue
        }

        $frontmatter[$key] = $value.Trim('"', "'")
    }

    return $frontmatter
}

$records = [System.Collections.Generic.List[object]]::new()
$recordsByPath = [Collections.Generic.Dictionary[string, object]]::new([StringComparer]::Ordinal)
$sourceManifest = [System.Collections.Generic.List[object]]::new()

foreach ($layer in 'microsoft', 'community', 'custom') {
    $skillsRoot = Join-Path $BCQualityRoot (Join-Path $layer 'skills')
    if (-not (Test-Path -LiteralPath $skillsRoot -PathType Container)) {
        continue
    }

    foreach ($file in Get-ChildItem -LiteralPath $skillsRoot -Recurse -File -Filter '*.md' | Sort-Object FullName) {
        $bytes = [IO.File]::ReadAllBytes($file.FullName)
        try {
            $text = [Text.UTF8Encoding]::new($false, $true).GetString($bytes)
        }
        catch [Text.DecoderFallbackException] {
            throw [IO.InvalidDataException]::new("Invalid UTF-8 in '$($file.FullName)'.", $_.Exception)
        }

        $frontmatter = ConvertFrom-SkillFrontmatter -Path $file.FullName -Text $text
        if ($frontmatter['kind'] -ne 'action-skill') {
            continue
        }

        foreach ($required in 'id', 'version', 'title', 'description', 'inputs', 'outputs') {
            if (-not $frontmatter.Contains($required) -or $null -eq $frontmatter[$required] -or
                ([string]$frontmatter[$required]).Trim() -eq '') {
                throw [IO.InvalidDataException]::new(
                    "Action skill '$($file.FullName)' is missing required frontmatter '$required'."
                )
            }
        }

        $path = Get-RelativePath -Root $BCQualityRoot -Full $file.FullName
        $sourceSha256 = Get-Sha256 -Bytes $bytes
        $version = 0
        if (-not [int]::TryParse([string]$frontmatter['version'], [ref]$version) -or $version -le 0) {
            throw [IO.InvalidDataException]::new("Action skill '$path' has an invalid version.")
        }

        $subSkills = @()
        if ($frontmatter.Contains('sub-skills')) {
            $subSkills = @($frontmatter['sub-skills'])
            if (-not $subSkills.Count) {
                throw [IO.InvalidDataException]::new("Super-skill '$path' has an empty sub-skills list.")
            }
        }

        $record = [pscustomobject][ordered]@{
            path         = $path
            layer        = $layer
            id           = [string]$frontmatter['id']
            version      = $version
            title        = [string]$frontmatter['title']
            description  = [string]$frontmatter['description']
            inputs       = [string[]]@($frontmatter['inputs'])
            outputs      = [string[]]@($frontmatter['outputs'])
            filters      = [ordered]@{
                'bc-version'       = [object[]]$(if ($frontmatter.Contains('bc-version')) { $frontmatter['bc-version'] })
                technologies       = [string[]]$(if ($frontmatter.Contains('technologies')) { $frontmatter['technologies'] })
                countries          = [string[]]$(if ($frontmatter.Contains('countries')) { $frontmatter['countries'] })
                'application-area' = [string[]]$(if ($frontmatter.Contains('application-area')) { $frontmatter['application-area'] })
            }
            subSkills    = [string[]]$subSkills
            sourceSha256 = $sourceSha256
        }

        if (-not $recordsByPath.TryAdd($path, $record)) {
            throw "Duplicate action-skill path: $path"
        }
        $records.Add($record) | Out-Null
        $sourceManifest.Add([ordered]@{ path = $path; sha256 = $sourceSha256 }) | Out-Null
    }
}

$ids = @($records | Group-Object id | Where-Object Count -gt 1)
if ($ids.Count) {
    throw "Duplicate action-skill IDs: $($ids.Name -join ', ')"
}

foreach ($record in $records) {
    $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($subSkillPath in @($record.subSkills)) {
        if (-not $seen.Add($subSkillPath)) {
            throw "Super-skill '$($record.path)' declares duplicate sub-skill '$subSkillPath'."
        }
        if (-not $recordsByPath.ContainsKey($subSkillPath)) {
            throw "Super-skill '$($record.path)' references missing action skill '$subSkillPath'."
        }

        $leaf = $recordsByPath[$subSkillPath]
        if (@($leaf.subSkills).Count) {
            throw "Nested super-skills are not supported: '$($record.path)' references '$subSkillPath'."
        }
        if (@($leaf.outputs).Count -ne 1 -or $leaf.outputs[0] -ne 'findings-report') {
            throw "Sub-skill '$subSkillPath' must produce findings-report."
        }
    }
}

$index = [ordered]@{
    version        = 1
    generatedAt    = (Get-Date).ToUniversalTime().ToString('o')
    skillCount     = $records.Count
    sourceSnapshot = Get-ValueSha256 -Value @($sourceManifest)
    skills         = @($records)
}

$parent = Split-Path -Parent $IndexPath
if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}
Set-Content -LiteralPath $IndexPath -Value (
    ConvertTo-Json -InputObject $index -Depth 12 -Compress
) -Encoding utf8NoBOM

return $records.Count
