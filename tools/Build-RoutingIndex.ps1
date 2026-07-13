<#
.SYNOPSIS
    Builds the BCQuality routing index — the orchestrator-facing companion to
    knowledge-index.json that maps PR-diff detection signals to review domains
    and the knowledge articles that back them.

.DESCRIPTION
    The PR-review orchestrator used to carry a hand-written ~28-token regex
    catalog ($BcqSignalCatalog) INSIDE its code (Invoke-CopilotPRReview.ps1).
    That shadow catalog never read the domain/keywords front-matter the articles
    already declare, so its blind spots were exactly where findings got missed.

    This generator retires that shadow catalog by compiling a routing index from
    CONTENT: it ingests the content-owned seed (tools/routing-seed.json, the
    migrated legacy catalog, so recall >= today) and then attaches to every
    signal the articles that back it, plus any article-declared `signals:`
    front-matter. The result — routing-index.json — is consumed by the
    orchestrator's Build-ReviewManifest behind the BCQ_INDEX_V2 flag to score
    per-domain suspicion and shortlist candidate articles.

    This is NOT the lean, agent-replayed knowledge-index.json. The routing index
    is orchestrator-side only and is never fed into the CLI prompt, so it can be
    richer without inflating the token-paid path. It is regenerated
    deterministically at authoring/CI time.

    Recall is complete-by-construction: every article whose (normalized) domain
    matches a signal's domain is attached to that signal, so a new community
    article becomes routable the moment it lands — no orchestrator edit required.

.PARAMETER BCQualityRoot
    Path to the BCQuality content root to index. Defaults to the clone root
    (parent of this script's tools/ folder).

.PARAMETER SeedPath
    Path to the routing seed. Defaults to <this script folder>/routing-seed.json.

.PARAMETER IndexPath
    Where to write the routing index JSON. Defaults to
    <BCQualityRoot>/routing-index.json.

.PARAMETER EnabledLayers
    Optional layer allowlist (microsoft, community, custom). When provided only
    those layers are walked and the value is recorded in the index header.

.PARAMETER IncludeKeywordSignals
    ALSO derive soft signals from article keywords (weight 0.5, source
    'keyword'). OFF by default: keywords are lowercase-kebab and match noisily,
    and the feedback data warns the agent already over-fires (precision 0.246).
    Seed + explicit front-matter `signals:` are the precision path.

.PARAMETER Pretty
    Emit pretty-printed JSON instead of compact.

.OUTPUTS
    Returns the number of signals written to the index.
#>
[CmdletBinding()]
param(
    [string]   $BCQualityRoot,
    [string]   $SeedPath,
    [string]   $IndexPath,
    [string[]] $EnabledLayers,
    [switch]   $IncludeKeywordSignals,
    [switch]   $Pretty
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $BCQualityRoot) {
    $BCQualityRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}
if (-not (Test-Path $BCQualityRoot)) { throw "BCQuality root not found: $BCQualityRoot" }
$BCQualityRoot = (Resolve-Path -LiteralPath $BCQualityRoot).Path
if (-not $SeedPath)  { $SeedPath  = Join-Path $PSScriptRoot 'routing-seed.json' }
if (-not (Test-Path $SeedPath)) { throw "Routing seed not found: $SeedPath" }
if (-not $IndexPath) { $IndexPath = Join-Path $BCQualityRoot 'routing-index.json' }

$seed = Get-Content -LiteralPath $SeedPath -Raw | ConvertFrom-Json
$domainNorm = @{}
foreach ($p in $seed.'domain-normalization'.PSObject.Properties) { $domainNorm[$p.Name] = $p.Value }

# Normalize a front-matter domain (lowercase-hyphen) to the orchestrator's
# TitleCase taxonomy. Unknown domains pass through unchanged so nothing is lost.
function ConvertTo-CanonicalDomain {
    param([string] $Domain)
    if ([string]::IsNullOrWhiteSpace($Domain)) { return '' }
    $d = $Domain.Trim()
    if ($domainNorm.ContainsKey($d)) { return $domainNorm[$d] }
    return $d
}

function Get-RelativePath {
    param([string] $Root, [string] $Full)
    return (($Full.Substring($Root.Length).TrimStart([char]'/', [char]'\')) -replace '\\', '/')
}

# Minimal front-matter reader for routing needs: domain (scalar), keywords
# (inline array), and the OPTIONAL signals block (inline string array, or a
# block list of `- token`/`- token: X` items). Deliberately narrow — the lean
# knowledge index owns the full parse; here we only need routing inputs.
function Read-RoutingFrontmatter {
    param([string] $Path)
    $lines = Get-Content -LiteralPath $Path -ErrorAction Stop
    if ($lines.Count -lt 1 -or $lines[0].Trim() -ne '---') { return $null }
    $fmEnd = -1
    for ($i = 1; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim() -eq '---') { $fmEnd = $i; break } }
    if ($fmEnd -lt 0) { return $null }

    $domain = ''
    $keywords = @()
    $signals = [System.Collections.Generic.List[object]]::new()

    for ($i = 1; $i -lt $fmEnd; $i++) {
        $line = $lines[$i]
        if ($line -match '^\s*domain\s*:\s*(.+?)\s*$') { $domain = $Matches[1].Trim(); continue }
        if ($line -match '^\s*keywords\s*:\s*\[(.*)\]\s*$') {
            $inner = $Matches[1].Trim()
            if ($inner -ne '') { $keywords = @($inner -split '\s*,\s*' | ForEach-Object { $_.Trim() }) }
            continue
        }
        if ($line -match '^\s*signals\s*:\s*(.*)$') {
            $rest = $Matches[1].Trim()
            if ($rest -match '^\[(.*)\]$') {
                # inline: signals: [tokenA, tokenB]
                $inner = $Matches[1].Trim()
                if ($inner -ne '') {
                    foreach ($tok in ($inner -split '\s*,\s*')) {
                        $t = $tok.Trim().Trim('"',"'")
                        if ($t) { $signals.Add($t) | Out-Null }
                    }
                }
            } else {
                # block list following the key: `- token` or `- token: X` / mapping
                for ($j = $i + 1; $j -lt $fmEnd; $j++) {
                    $bl = $lines[$j]
                    if ($bl -match '^\s*-\s*(.+?)\s*$') {
                        $item = $Matches[1].Trim()
                        if ($item -match '^token\s*:\s*(.+)$') {
                            $signals.Add(@{ token = ($Matches[1].Trim().Trim('"',"'")) }) | Out-Null
                        } elseif ($item -notmatch ':') {
                            $signals.Add(($item.Trim('"',"'"))) | Out-Null
                        } else {
                            # inline-mapping `- {token: X, pattern: Y}` — best effort
                            $m = [regex]::Match($item, 'token\s*:\s*([^,}\s]+)')
                            if ($m.Success) { $signals.Add(@{ token = $m.Groups[1].Value.Trim().Trim('"',"'") }) | Out-Null }
                        }
                    } elseif ($bl -match '^\s+\w') {
                        # continuation of a mapping entry (pattern:/domain:) — attach to last mapping
                        if ($signals.Count -gt 0 -and ($signals[$signals.Count - 1] -is [hashtable])) {
                            if ($bl -match '^\s*pattern\s*:\s*(.+)$') { $signals[$signals.Count - 1]['pattern'] = $Matches[1].Trim().Trim('"',"'") }
                            elseif ($bl -match '^\s*domain\s*:\s*(.+)$') { $signals[$signals.Count - 1]['domain'] = $Matches[1].Trim().Trim('"',"'") }
                        }
                    } else { break }
                }
            }
            continue
        }
    }
    return [pscustomobject]@{ domain = $domain; keywords = $keywords; signals = @($signals) }
}

# ---- Walk articles ---------------------------------------------------------
$articles = [System.Collections.Generic.List[object]]::new()
foreach ($layerDir in @('microsoft', 'community', 'custom')) {
    if ($EnabledLayers -and ($EnabledLayers -notcontains $layerDir)) { continue }
    $kbRoot = Join-Path $BCQualityRoot (Join-Path $layerDir 'knowledge')
    if (-not (Test-Path $kbRoot)) { continue }
    Get-ChildItem -LiteralPath $kbRoot -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue |
        Sort-Object FullName |
        ForEach-Object {
            $rel = Get-RelativePath -Root $BCQualityRoot -Full $_.FullName
            $fm = $null
            try { $fm = Read-RoutingFrontmatter -Path $_.FullName } catch { $fm = $null }
            $rawDomain = if ($fm) { $fm.domain } elseif ($rel -match '/knowledge/([^/]+)/') { $Matches[1] } else { '' }
            $articles.Add([pscustomobject]@{
                path      = $rel
                layer     = $layerDir
                rawDomain = $rawDomain
                domain    = (ConvertTo-CanonicalDomain $rawDomain)
                keywords  = if ($fm) { @($fm.keywords) } else { @() }
                signals   = if ($fm) { @($fm.signals) } else { @() }
            }) | Out-Null
        }
}

# ---- Build the domain -> article index (for attaching backing articles) ----
$articlesByDomain = @{}
foreach ($a in $articles) {
    if (-not $a.domain) { continue }
    if (-not $articlesByDomain.ContainsKey($a.domain)) { $articlesByDomain[$a.domain] = [System.Collections.Generic.List[string]]::new() }
    $articlesByDomain[$a.domain].Add($a.path) | Out-Null
}

# Signal registry keyed by token so seed + article-declared signals merge and
# never duplicate; articles accumulate onto the matching token.
$signalReg = [ordered]@{}
function Add-Signal {
    param([string] $Token, [string] $Pattern, [string] $Domain, [string] $Source, [double] $Weight)
    if (-not $signalReg.Contains($Token)) {
        $signalReg[$Token] = [ordered]@{
            token = $Token; pattern = $Pattern; domain = $Domain; source = $Source; weight = $Weight
            articles = [System.Collections.Generic.List[string]]::new()
        }
    }
    return $signalReg[$Token]
}

# 1) Seed signals: guarantee recall >= legacy catalog. Attach every article
#    whose canonical domain matches the seed signal's domain.
foreach ($s in $seed.signals) {
    $sig = Add-Signal -Token $s.token -Pattern $s.pattern -Domain $s.domain -Source 'seed' -Weight 1.0
    if ($articlesByDomain.ContainsKey($s.domain)) {
        foreach ($p in $articlesByDomain[$s.domain]) { if (-not $sig.articles.Contains($p)) { $sig.articles.Add($p) | Out-Null } }
    }
}

# 2) Article-declared signals (front-matter `signals:`): highest-precision,
#    authored. Default pattern = \b<token>\b; default domain = article domain.
foreach ($a in $articles) {
    foreach ($decl in $a.signals) {
        $token = $null; $pattern = $null; $domain = $null
        if ($decl -is [string]) { $token = $decl }
        elseif ($decl -is [hashtable]) { $token = $decl['token']; $pattern = $decl['pattern']; $domain = $decl['domain'] }
        if (-not $token) { continue }
        if (-not $pattern) { $pattern = '\b' + [regex]::Escape($token) + '\b' }
        $domain = if ($domain) { ConvertTo-CanonicalDomain $domain } else { $a.domain }
        $sig = Add-Signal -Token $token -Pattern $pattern -Domain $domain -Source 'frontmatter-signal' -Weight 1.0
        # Promote a seed placeholder to authored if the article overrode it.
        if ($sig.source -eq 'seed' -and $decl -isnot [string]) { $sig.source = 'frontmatter-signal'; $sig.pattern = $pattern; $sig.domain = $domain }
        if (-not $sig.articles.Contains($a.path)) { $sig.articles.Add($a.path) | Out-Null }
    }
}

# 3) OPTIONAL soft keyword signals (off by default).
if ($IncludeKeywordSignals) {
    $stop = @{ 'al' = $true; 'bc' = $true; 'all' = $true; 'w1' = $true; 'data' = $true; 'field' = $true; 'table' = $true; 'page' = $true; 'record' = $true; 'value' = $true }
    foreach ($a in $articles) {
        foreach ($kw in $a.keywords) {
            $k = ($kw + '').Trim().ToLowerInvariant()
            if (-not $k -or $stop.ContainsKey($k) -or $k.Length -lt 4) { continue }
            $token = 'kw:' + $k
            $pattern = '(?i)\b' + [regex]::Escape($k) + '\b'
            $sig = Add-Signal -Token $token -Pattern $pattern -Domain $a.domain -Source 'keyword' -Weight 0.5
            if (-not $sig.articles.Contains($a.path)) { $sig.articles.Add($a.path) | Out-Null }
        }
    }
}

# ---- Assemble output -------------------------------------------------------
$signalsOut = @($signalReg.Values | ForEach-Object {
    [ordered]@{
        token = $_.token; pattern = $_.pattern; domain = $_.domain
        source = $_.source; weight = $_.weight; articles = @($_.articles)
    }
})

$domainsOut = [ordered]@{}
foreach ($d in ($articlesByDomain.Keys | Sort-Object)) {
    $domainsOut[$d] = [ordered]@{
        articleCount = $articlesByDomain[$d].Count
        signalCount  = @($signalsOut | Where-Object { $_.domain -eq $d }).Count
    }
}

$objKind = [ordered]@{}
foreach ($p in $seed.'object-kind-domain'.PSObject.Properties) { $objKind[$p.Name] = $p.Value }
$domNormOut = [ordered]@{}
foreach ($k in ($domainNorm.Keys | Sort-Object)) { $domNormOut[$k] = $domainNorm[$k] }

$index = [ordered]@{
    '$schema-note'      = 'BCQuality routing index. signal-token -> domain + backing articles. Consumed by the PR-review orchestrator manifest (BCQ_INDEX_V2). Regenerated at CI time by tools/Build-RoutingIndex.ps1; NOT the lean agent-replayed knowledge index. Schema: tools/routing-index.schema.json.'
    version             = 1
    generatedAt         = (Get-Date).ToUniversalTime().ToString('o')
    generator           = 'Build-RoutingIndex.ps1'
    enabledLayers       = @($EnabledLayers)
    articleCount        = $articles.Count
    signalCount         = $signalsOut.Count
    domainNormalization = $domNormOut
    objectKindDomain    = $objKind
    signals             = $signalsOut
    domains             = $domainsOut
}

$indexDir = Split-Path -Parent $IndexPath
if ($indexDir -and -not (Test-Path $indexDir)) { New-Item -ItemType Directory -Force -Path $indexDir | Out-Null }
if ($Pretty) {
    $index | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $IndexPath -Encoding UTF8
} else {
    $index | ConvertTo-Json -Depth 12 -Compress | Set-Content -LiteralPath $IndexPath -Encoding UTF8
}

Write-Host "BCQuality routing index: $($signalsOut.Count) signal(s), $($articles.Count) article(s). Index: $IndexPath"
return $signalsOut.Count
