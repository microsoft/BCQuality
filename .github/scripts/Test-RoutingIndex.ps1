<#
.SYNOPSIS
    CI guard for the routing-index generator (tools/Build-RoutingIndex.ps1).

.DESCRIPTION
    BCQuality owns the routing index — the orchestrator-facing companion to the
    knowledge index that maps PR-diff signals to review domains and the articles
    that back them. Like the knowledge index, no committed artifact is trusted at
    runtime (a consumer rebuilds it over its pruned clone); this script proves the
    GENERATOR is healthy:

      1. Determinism — building twice yields byte-identical output once the
         volatile `generatedAt` header is normalized.
      2. Recall floor — every seed signal (tools/routing-seed.json) survives into
         the compiled index, so routing recall is never below the legacy catalog
         it replaced.
      3. No orphaned seed signals — a seed signal whose domain has at least one
         indexed article MUST have that article attached (catches domain
         normalization drift, e.g. Web Services vs web-services).
      4. Structural integrity — every signal carries token/pattern/domain/source/
         weight/articles; every attached article path exists on disk; every
         signal pattern is a valid regex.
      5. Normalization coverage — every front-matter domain present on disk either
         normalizes to a canonical orchestrator domain or is a documented
         pass-through, so no article silently falls out of routing.

    Exit code 0 = healthy; non-zero = a problem CI must block on.
#>
[CmdletBinding()]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..' '..'))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path -LiteralPath $Root).Path

$generator = Join-Path $Root 'tools/Build-RoutingIndex.ps1'
$seedPath  = Join-Path $Root 'tools/routing-seed.json'
if (-not (Test-Path $generator)) { throw "Generator not found: $generator" }
if (-not (Test-Path $seedPath))  { throw "Seed not found: $seedPath" }

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("routeindex_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
$idxA = Join-Path $tmp 'a.json'
$idxB = Join-Path $tmp 'b.json'

$problems = [System.Collections.Generic.List[string]]::new()

& $generator -BCQualityRoot $Root -IndexPath $idxA | Out-Null
& $generator -BCQualityRoot $Root -IndexPath $idxB | Out-Null

# 1. Determinism (ignoring the volatile generatedAt timestamp).
$norm = { param($p) ((Get-Content -LiteralPath $p -Raw) -replace '"generatedAt":"[^"]*"', '"generatedAt":"<n>"') }
if ((& $norm $idxA) -ne (& $norm $idxB)) {
    $problems.Add('Non-deterministic: two builds differ beyond generatedAt.') | Out-Null
}

$index = Get-Content -LiteralPath $idxA -Raw | ConvertFrom-Json
$signals = @($index.signals)
$seed = Get-Content -LiteralPath $seedPath -Raw | ConvertFrom-Json

# 2. Recall floor: every seed signal token present in the compiled index.
$indexTokens = @($signals | ForEach-Object { $_.token })
$missingSeed = @($seed.signals | Where-Object { $indexTokens -notcontains $_.token } | ForEach-Object { $_.token })
if ($missingSeed.Count) { $problems.Add("Seed signals dropped from index: $($missingSeed -join ', ')") | Out-Null }

# 3. No orphaned seed signals when the domain is populated.
$domainArticleCount = @{}
foreach ($p in $index.domains.PSObject.Properties) { $domainArticleCount[$p.Name] = [int]$p.Value.articleCount }
foreach ($s in $signals) {
    if ($s.source -eq 'seed' -and @($s.articles).Count -eq 0) {
        $ac = if ($domainArticleCount.ContainsKey($s.domain)) { $domainArticleCount[$s.domain] } else { 0 }
        if ($ac -gt 0) {
            $problems.Add("Orphaned seed signal '$($s.token)': domain '$($s.domain)' has $ac article(s) but none attached (normalization drift?).") | Out-Null
        }
    }
}

# 4. Structural integrity.
foreach ($s in $signals) {
    foreach ($f in 'token','pattern','domain','source','weight') {
        if ($null -eq $s.$f -or ("$($s.$f)").Trim() -eq '') { $problems.Add("Signal missing '$f': $($s.token)") | Out-Null }
    }
    try { [void][regex]::new([string]$s.pattern) } catch { $problems.Add("Invalid regex for signal '$($s.token)': $($s.pattern)") | Out-Null }
    foreach ($ap in @($s.articles)) {
        if (-not (Test-Path (Join-Path $Root $ap))) { $problems.Add("Signal '$($s.token)' attaches missing article: $ap") | Out-Null }
    }
}

# 5. Normalization coverage: every on-disk front-matter domain resolves to a
#    canonical orchestrator domain or is a known pass-through. A NEW front-matter
#    domain that is not TitleCase and not in the map is flagged so the seed's
#    domain-normalization stays complete as content grows.
$norm2 = @{}
foreach ($p in $index.domainNormalization.PSObject.Properties) { $norm2[$p.Name] = $p.Value }
$passThrough = @('appsource')   # indexed domains with no leaf skill (route via super-skill)
$diskDomains = @{}
foreach ($layer in 'microsoft','community','custom') {
    $kb = Join-Path $Root (Join-Path $layer 'knowledge')
    if (-not (Test-Path $kb)) { continue }
    Get-ChildItem -LiteralPath $kb -Recurse -File -Filter '*.md' | ForEach-Object {
        $l = Get-Content -LiteralPath $_.FullName -TotalCount 12
        $d = ($l | Where-Object { $_ -match '^\s*domain\s*:\s*(.+?)\s*$' } | Select-Object -First 1)
        if ($d -and $d -match '^\s*domain\s*:\s*(.+?)\s*$') { $diskDomains[$Matches[1].Trim()] = $true }
    }
}
foreach ($d in $diskDomains.Keys) {
    $isCanonical = ($d -cmatch '[A-Z]' -or $d -eq 'appsource')   # already TitleCase or pass-through
    if (-not $norm2.ContainsKey($d) -and -not ($passThrough -contains $d) -and -not $isCanonical) {
        $problems.Add("Front-matter domain '$d' is not in domain-normalization and not a pass-through; add it to routing-seed.json.") | Out-Null
    }
}

Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue

if ($problems.Count) {
    Write-Host "Routing-index check FAILED ($($problems.Count) problem(s)):" -ForegroundColor Red
    $problems | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}
Write-Host "Routing-index check PASSED: $($signals.Count) signals, $($index.articleCount) articles, deterministic, seed recall floor held, normalization complete." -ForegroundColor Green
exit 0
