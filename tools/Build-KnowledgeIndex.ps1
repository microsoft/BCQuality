<#
.SYNOPSIS
    Builds the BCQuality knowledge index — the discovery artifact the review
    skills' §Source step consumes.

.DESCRIPTION
    BCQuality owns the knowledge-index contract: the index schema is part of
    the Source step that the action skills (e.g. al-*-review.md) declare, so
    the generator lives here, next to the skills and knowledge it derives from.
    Consumers (orchestrators such as the BCAppsBCQuality PR-review filter) call
    this script instead of re-implementing the parser, so every consumer gets
    the same faithful index for free and the index stays in lockstep with the
    skill contract.

    The index lets the agent enumerate candidate articles and compute the
    keyword/topic worklist overlap by reading ONE file, instead of opening
    every file under `*/knowledge/<domain>/**` just to read its frontmatter.
    The worklist SELECTION predicate is unchanged: the index carries the same
    inputs the predicate already reads (keywords + frontmatter dimensions +
    domain + path + title), and the agent still opens each worklisted article
    in full for its `## Best Practice` / `## Anti Pattern` rule bodies.

    The index is LEAN by default: the verbatim Description is trimmed to a
    one-line hint and the JSON is emitted compact, so the index prefix the
    agent replays across passes stays small. The selection inputs remain
    lossless. Pass -FullIndex for the verbatim, pretty-printed variant.

    This script does NOT apply layer/allow-deny policy by reading config — it
    indexes whatever knowledge files are present on disk (a consumer is
    expected to prune its clone to policy first). For provenance and to
    reproduce a consumer's exact view, pass -EnabledLayers to restrict the walk
    to those layers and to record the policy in the index header.

.PARAMETER BCQualityRoot
    Path to the BCQuality content root to index (typically a filtered clone).
    Defaults to the clone root (the parent of this script's `tools/` folder), so
    the agent can run `pwsh ./tools/Build-KnowledgeIndex.ps1` from the clone root
    with no arguments.

.PARAMETER IndexPath
    Where to write the index JSON. Defaults to `<BCQualityRoot>/knowledge-index.json`.

.PARAMETER EnabledLayers
    Optional layer allowlist (e.g. microsoft, community, custom). When provided,
    only those layers are walked and the value is recorded in the index header.
    Omit to index every layer present on disk.

.PARAMETER KnowledgeAllow
    Optional allow globs to record in the index header (provenance only).

.PARAMETER KnowledgeDeny
    Optional deny globs to record in the index header (provenance only).

.PARAMETER FullIndex
    Emit the verbatim-Description, pretty-printed index instead of the lean one.

.OUTPUTS
    Returns the number of articles written to the index.
#>
[CmdletBinding()]
param(
    [string] $BCQualityRoot,
    [string] $IndexPath,
    [string[]] $EnabledLayers,
    [string[]] $KnowledgeAllow = @(),
    [string[]] $KnowledgeDeny = @(),
    [switch] $FullIndex
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Default to the clone root (parent of this script's tools/ folder) so the
# agent's Entry preparation step can invoke this with no arguments from the
# checkout root. A consumer/orchestrator may still pass -BCQualityRoot.
if (-not $BCQualityRoot) {
    $BCQualityRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}
if (-not (Test-Path $BCQualityRoot)) {
    throw "BCQuality root not found: $BCQualityRoot"
}
if (-not $IndexPath) {
    $IndexPath = Join-Path $BCQualityRoot 'knowledge-index.json'
}

function Get-RelativePath {
    param([string] $Root, [string] $Full)
    $rel = $Full.Substring($Root.Length).TrimStart([char]'/', [char]'\')
    return ($rel -replace '\\', '/')
}

# Trims a Description to a single short line (<= $Max chars) for the lean
# index. Takes the first sentence; truncates on a word boundary if still long.
function Get-LeanDescription {
    param([string] $Text, [int] $Max = 120)
    if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
    $t = ($Text -replace '\s+', ' ').Trim()
    $m = [regex]::Match($t, '^(.*?[\.!?])(\s|$)')
    if ($m.Success) { $t = $m.Groups[1].Value.Trim() }
    if ($t.Length -le $Max) { return $t }
    $cut = $t.Substring(0, $Max)
    $sp = $cut.LastIndexOf(' ')
    if ($sp -gt 40) { $cut = $cut.Substring(0, $sp) }
    return ($cut.TrimEnd() + '…')
}

function ConvertFrom-ArticleFrontmatter {
    # Parses a knowledge file into the fields the knowledge index needs.
    # Captures the verbatim frontmatter dimensions/keywords, the H1 title,
    # and the full Description section (the article's primary retrieval
    # target per READ). No rule-body content (## Best Practice / ## Anti
    # Pattern) is included; the index is a lossless substitute for the
    # frontmatter + Description the worklist predicate reads, not a
    # substitute for the article's normative guidance.
    param([string] $Path)

    $lines = Get-Content -LiteralPath $Path -ErrorAction Stop

    # Frontmatter is the first '---'-delimited block.
    if ($lines.Count -lt 1 -or $lines[0].Trim() -ne '---') { return $null }
    $fmEnd = -1
    for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i].Trim() -eq '---') { $fmEnd = $i; break }
    }
    if ($fmEnd -lt 0) { return $null }

    $fm = @{}
    for ($i = 1; $i -lt $fmEnd; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s*([a-zA-Z][\w-]*)\s*:\s*(.*)$') {
            $key = $Matches[1]
            $val = $Matches[2].Trim()
            if ($val -match '^\[(.*)\]$') {
                $inner = $Matches[1].Trim()
                if ($inner -eq '') { $fm[$key] = @() }
                else { $fm[$key] = @($inner -split '\s*,\s*' | ForEach-Object { $_.Trim() }) }
            }
            elseif ($val -ne '') { $fm[$key] = $val }
        }
    }

    # Body parsing: H1 title and the full Description section. The Description
    # is the article's primary retrieval target per READ and is captured
    # verbatim (it carries no rule-body guidance and no fenced code per the
    # schema), so the index is a lossless substitute for the frontmatter +
    # Description that the worklist predicate reads. Normative rule bodies
    # (## Best Practice / ## Anti Pattern) are deliberately NOT included.
    $title = ''
    $description = ''
    $inDescription = $false
    $descBuffer = [System.Collections.Generic.List[string]]::new()
    for ($i = $fmEnd + 1; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        if (-not $title -and $line -match '^\#\s+(.+?)\s*$') { $title = $Matches[1].Trim(); continue }
        if ($line -match '^\#\#\s+Description\s*$') { $inDescription = $true; continue }
        if ($inDescription) {
            if ($line -match '^\#\#\s') { break }   # next section ends Description
            if ($line.Trim() -ne '') { $descBuffer.Add($line.Trim()) | Out-Null }
        }
    }
    if ($descBuffer.Count -gt 0) { $description = ($descBuffer -join ' ').Trim() }

    return [pscustomobject]@{
        domain            = if ($fm.ContainsKey('domain')) { [string]$fm['domain'] } else { '' }
        'bc-version'      = @($fm['bc-version'])
        technologies      = @($fm['technologies'])
        countries         = @($fm['countries'])
        'application-area'= @($fm['application-area'])
        keywords          = @($fm['keywords'])
        title             = $title
        description       = $description
    }
}

# Walk the knowledge files and emit a single compact discovery artifact so
# consumers can enumerate candidate articles and compute keyword/topic worklist
# overlap without opening every file. When -EnabledLayers is supplied the walk
# is restricted to those layers (a consumer reproduces its filtered view); the
# article set otherwise reflects whatever is present on disk.
$indexArticles = [System.Collections.Generic.List[object]]::new()
foreach ($layerDir in @('microsoft', 'community', 'custom')) {
    $kbRoot = Join-Path $BCQualityRoot (Join-Path $layerDir 'knowledge')
    if (-not (Test-Path $kbRoot)) { continue }
    if ($EnabledLayers -and ($EnabledLayers -notcontains $layerDir)) { continue }

    Get-ChildItem -LiteralPath $kbRoot -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue |
        Sort-Object FullName |
        ForEach-Object {
            $rel = Get-RelativePath -Root $BCQualityRoot -Full $_.FullName
            $parsed = $null
            try { $parsed = ConvertFrom-ArticleFrontmatter -Path $_.FullName } catch { $parsed = $null }
            if (-not $parsed) {
                # Invalid/unparseable file: list path + domain-from-path so it
                # is never silently dropped from discovery. Consumers fall back
                # to reading it in full.
                $domainFromPath = if ($rel -match '/knowledge/([^/]+)/') { $Matches[1] } else { '' }
                $indexArticles.Add([pscustomobject]@{
                    path = $rel; layer = $layerDir; domain = $domainFromPath
                    'bc-version' = @(); technologies = @(); countries = @(); 'application-area' = @()
                    keywords = @(); title = ''; description = ''; parsed = $false
                }) | Out-Null
                return
            }
            $indexArticles.Add([pscustomobject]@{
                path               = $rel
                layer              = $layerDir
                domain             = $parsed.domain
                'bc-version'       = @($parsed.'bc-version')
                technologies       = @($parsed.technologies)
                countries          = @($parsed.countries)
                'application-area' = @($parsed.'application-area')
                keywords           = @($parsed.keywords)
                title              = $parsed.title
                description        = if ($FullIndex) { $parsed.description } else { Get-LeanDescription -Text $parsed.description }
                parsed             = $true
            }) | Out-Null
        }
}

$index = [pscustomobject]@{
    version       = 1
    generatedAt   = (Get-Date).ToUniversalTime().ToString('o')
    enabledLayers = @($EnabledLayers)
    knowledgeAllow= @($KnowledgeAllow)
    knowledgeDeny = @($KnowledgeDeny)
    articleCount  = $indexArticles.Count
    articles      = @($indexArticles)
}

$indexDir = Split-Path -Parent $IndexPath
if ($indexDir -and -not (Test-Path $indexDir)) {
    New-Item -ItemType Directory -Force -Path $indexDir | Out-Null
}
if ($FullIndex) {
    $index | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $IndexPath -Encoding UTF8
} else {
    $index | ConvertTo-Json -Depth 8 -Compress | Set-Content -LiteralPath $IndexPath -Encoding UTF8
}

Write-Host "BCQuality index: $($indexArticles.Count) article(s). Index: $IndexPath"
return $indexArticles.Count
