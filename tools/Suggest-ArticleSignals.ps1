<#
.SYNOPSIS
    Authoring-assist (PROTOTYPE): suggests routing `signals:` front-matter for
    BCQuality knowledge articles, and flags articles whose declared `domain`
    disagrees with what their code samples actually contain.

.DESCRIPTION
    Routing quality is capped by how well each article's front-matter describes
    the code it catches. Today 0 of ~207 articles declare an explicit `signals:`
    block and 5 review domains have zero detection signals, so ~22% of knowledge
    is only reachable via the catch-all pass. This tool lowers the authoring cost
    of closing that gap: it reads an article's own `good`/`bad` `.al` samples plus
    its prose, extracts candidate AL constructs, and proposes a `signals:` block —
    then leaves the decision to a human.

    It is OFFLINE and OPEN: no feedback data, deterministic, ships in the repo so
    the community can run it. It SUGGESTS ONLY — it never edits an article. The
    output is a review report (Markdown by default, JSON with -AsJson) an author
    or maintainer eyeballs; the front-matter validator (R24), CI, and CODEOWNERS
    review remain the gate. This is the on-demand prototype the team agreed to
    before formalizing an automated advisory PR check.

.PARAMETER BCQualityRoot
    Content root to scan. Defaults to the clone root (parent of tools/).

.PARAMETER Path
    Optional filter: only articles whose repo-relative path CONTAINS this string
    (e.g. 'knowledge/style' or a single article file name). Enables on-demand,
    per-PR-style scoping. Omit to scan every article.

.PARAMETER Top
    Max suggested signals per article (default 3).

.PARAMETER OnlyGaps
    Only report articles that either have NO existing signal coverage for their
    domain or trigger a domain-mismatch flag — i.e. where the suggestion adds the
    most value. Off = report every article that yields a suggestion.

.PARAMETER AsJson
    Emit a machine-readable JSON report instead of Markdown (for a future
    automated PR check to consume).

.PARAMETER SeedPath
    Routing seed (for domain normalization + the existing catalog to de-dupe
    against). Defaults to tools/routing-seed.json next to this script.

.OUTPUTS
    Writes the report to stdout. Returns nothing.
#>
[CmdletBinding()]
param(
    [string] $BCQualityRoot,
    [string] $Path,
    [int]    $Top = 3,
    [switch] $OnlyGaps,
    [switch] $AsJson,
    [string] $SeedPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $BCQualityRoot) { $BCQualityRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path }
$BCQualityRoot = (Resolve-Path -LiteralPath $BCQualityRoot).Path
if (-not $SeedPath) { $SeedPath = Join-Path $PSScriptRoot 'routing-seed.json' }
if (-not (Test-Path $SeedPath)) { throw "Routing seed not found: $SeedPath" }

$seed = Get-Content -LiteralPath $SeedPath -Raw | ConvertFrom-Json
$domainNorm = @{}
foreach ($p in $seed.'domain-normalization'.PSObject.Properties) { $domainNorm[$p.Name] = $p.Value }

# Existing seed tokens by canonical domain, so we only propose NEW value.
$seedByToken = @{}   # lowercased construct -> canonical domain it already routes
foreach ($s in $seed.signals) {
    # Derive the bare words a seed pattern is likely to match (best effort) so a
    # candidate construct already covered by the catalog is recognised.
    foreach ($w in ([regex]::Matches($s.pattern, '[A-Za-z][A-Za-z0-9]{2,}') | ForEach-Object { $_.Value })) {
        $lw = $w.ToLowerInvariant()
        if (-not $seedByToken.ContainsKey($lw)) { $seedByToken[$lw] = $s.domain }
    }
    $seedByToken[$s.token.ToLowerInvariant()] = $s.domain
}

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

# Structural / common AL vocabulary that carries no routing signal — never
# propose these. Object kinds, primitive types, control-flow, and the sample
# scaffolding tables/fields we see repeatedly.
$stop = @{}
@(
    'record','codeunit','page','report','query','xmlport','enum','interface','table','profile',
    'tableextension','pageextension','reportextension','enumextension','permissionset','entitlement',
    'procedure','trigger','begin','end','var','local','internal','protected','exit','then','else','repeat','until','case',
    'text','integer','boolean','decimal','code','date','datetime','time','guid','option','biginteger','duration','char','byte','label',
    'customer','item','vendor','salesheader','salesline','glentry','username','name','value','field','fields',
    'uppercase','lowercase','format','copystr','strsubstno','strlen','maxstrlen','abs','round','power',
    'get','next','insert','modify','delete','init','sourcetable','pagetype','list','card','document','worksheet',
    'true','false','array','temporary','count','isempty','testfield','fieldno','recordid','tabledata',
    'action','group','field','part','area','layout','actions','usercontrol','cuegroup','repeater'
) | ForEach-Object { $stop[$_] = $true }

function Get-ArticleFrontmatter {
    param([string[]] $Lines)
    if ($Lines.Count -lt 1 -or $Lines[0].Trim() -ne '---') { return $null }
    $fmEnd = -1
    for ($i = 1; $i -lt $Lines.Count; $i++) { if ($Lines[$i].Trim() -eq '---') { $fmEnd = $i; break } }
    if ($fmEnd -lt 0) { return $null }
    $domain = ''; $keywords = @(); $hasSignals = $false
    for ($i = 1; $i -lt $fmEnd; $i++) {
        if ($Lines[$i] -match '^\s*domain\s*:\s*(.+?)\s*$') { $domain = $Matches[1].Trim() }
        elseif ($Lines[$i] -match '^\s*keywords\s*:\s*\[(.*)\]\s*$') {
            $inner = $Matches[1].Trim()
            if ($inner) { $keywords = @($inner -split '\s*,\s*' | ForEach-Object { $_.Trim() }) }
        }
        elseif ($Lines[$i] -match '^\s*signals\s*:') { $hasSignals = $true }
    }
    return [pscustomobject]@{ domain = $domain; keywords = $keywords; hasSignals = $hasSignals; fmEnd = $fmEnd }
}

# Extract candidate AL constructs from sample text: method calls (Foo(),
# property assignments (Foo =), and attributes ([Foo]). Returns a hashtable of
# construct -> @{ count; inBad } so anti-pattern (bad-sample) constructs rank up.
function Get-SampleConstructs {
    param([string] $Text, [bool] $IsBad)
    $out = @{}
    if (-not $Text) { return $out }
    # Identifiers the sample itself DECLARES (object name, procedures, triggers)
    # are sample-local scaffolding, not reusable routing constructs — exclude.
    $defined = @{}
    foreach ($dm in [regex]::Matches($Text, '(?im)^\s*(?:procedure|trigger)\s+([A-Za-z][A-Za-z0-9]*)')) {
        $defined[$dm.Groups[1].Value.ToLowerInvariant()] = $true
    }
    foreach ($dm in [regex]::Matches($Text, '(?im)^\s*(?:codeunit|page|report|query|table|xmlport|enum|interface|codeunit)\s+\d+\s+"?([A-Za-z][A-Za-z0-9 ]*)')) {
        foreach ($w in ($dm.Groups[1].Value -split '\s+')) { if ($w) { $defined[$w.ToLowerInvariant()] = $true } }
    }
    $patterns = @(
        '\b([A-Z][A-Za-z0-9]{2,})\s*\(',        # method call
        '(?m)^\s*([A-Z][A-Za-z0-9]{2,})\s*=',    # property assignment
        '\[([A-Z][A-Za-z0-9]{2,})'               # attribute
    )
    foreach ($pat in $patterns) {
        foreach ($m in [regex]::Matches($Text, $pat)) {
            $tok = $m.Groups[1].Value
            if ($stop.ContainsKey($tok.ToLowerInvariant())) { continue }
            if ($defined.ContainsKey($tok.ToLowerInvariant())) { continue }
            if (-not $out.ContainsKey($tok)) { $out[$tok] = @{ count = 0; inBad = $false } }
            $out[$tok].count++
            if ($IsBad) { $out[$tok].inBad = $true }
        }
    }
    return $out
}

# ---- Scan articles ---------------------------------------------------------
$reports = [System.Collections.Generic.List[object]]::new()
foreach ($layerDir in @('microsoft', 'community', 'custom')) {
    $kbRoot = Join-Path $BCQualityRoot (Join-Path $layerDir 'knowledge')
    if (-not (Test-Path $kbRoot)) { continue }
    Get-ChildItem -LiteralPath $kbRoot -Recurse -File -Filter '*.md' -ErrorAction SilentlyContinue |
        Sort-Object FullName |
        ForEach-Object {
            $rel = Get-RelativePath -Root $BCQualityRoot -Full $_.FullName
            if ($Path -and ($rel -notlike "*$Path*")) { return }

            $lines = Get-Content -LiteralPath $_.FullName -ErrorAction SilentlyContinue
            $fm = Get-ArticleFrontmatter -Lines $lines
            if (-not $fm) { return }
            $canonDomain = ConvertTo-CanonicalDomain $fm.domain

            # Collect constructs from co-located samples (good + bad).
            $constructs = @{}
            foreach ($sample in Get-ChildItem -LiteralPath $_.DirectoryName -Filter "$($_.BaseName)*.al" -ErrorAction SilentlyContinue) {
                $isBad = $sample.Name -match '\.bad\.al$'
                $text = Get-Content -LiteralPath $sample.FullName -Raw -ErrorAction SilentlyContinue
                foreach ($kv in (Get-SampleConstructs -Text $text -IsBad:$isBad).GetEnumerator()) {
                    if (-not $constructs.ContainsKey($kv.Key)) { $constructs[$kv.Key] = @{ count = 0; inBad = $false } }
                    $constructs[$kv.Key].count += $kv.Value.count
                    if ($kv.Value.inBad) { $constructs[$kv.Key].inBad = $true }
                }
            }

            # Keyword set (normalized) for relatedness scoring.
            $kwset = @{}
            foreach ($k in $fm.keywords) { $kwset[($k -replace '-', '').ToLowerInvariant()] = $true }

            # Score + classify candidates.
            $cands = foreach ($c in $constructs.Keys) {
                $lc = $c.ToLowerInvariant()
                $seedDomain = if ($seedByToken.ContainsKey($lc)) { $seedByToken[$lc] } else { $null }
                $score = [double]$constructs[$c].count
                if ($constructs[$c].inBad) { $score += 2 }                       # anti-pattern construct
                if ($kwset.ContainsKey($lc)) { $score += 3 }                     # backed by a declared keyword
                [pscustomobject]@{
                    token = $c; score = $score; inBad = $constructs[$c].inBad
                    keywordBacked = $kwset.ContainsKey($lc)
                    seedDomain = $seedDomain
                    alreadyRoutes = ($seedDomain -eq $canonDomain)
                }
            }
            $cands = @($cands | Sort-Object -Property @{ Expression = 'score'; Descending = $true }, @{ Expression = 'token'; Descending = $false })

            # Domain-mismatch flag: among candidates already known to the seed,
            # what domain dominates? If it disagrees with the declared domain,
            # the article's code looks like it belongs elsewhere.
            $seedMatched = @($cands | Where-Object { $_.seedDomain })
            $mismatch = $null
            if ($seedMatched.Count -ge 2) {
                $byDom = $seedMatched | Group-Object seedDomain | Sort-Object Count -Descending
                $dominant = $byDom[0]
                if ($dominant.Name -ne $canonDomain -and $dominant.Count -ge 2) {
                    $mismatch = "declared domain '$canonDomain' but $($dominant.Count) sample construct(s) route to '$($dominant.Name)' ($([string]::Join(', ', ($dominant.Group | ForEach-Object { $_.token } | Select-Object -First 4))))"
                }
            }

            # Proposals: the highest-value NEW triggers = not already routed to
            # this domain by the seed. Prefer keyword-backed / anti-pattern ones.
            $proposals = @($cands | Where-Object { -not $_.alreadyRoutes } | Select-Object -First $Top)

            $domainHasSeed = ($seedByToken.Values -contains $canonDomain)
            $isGap = (-not $domainHasSeed) -or ($mismatch) -or (-not $fm.hasSignals -and $proposals.Count -gt 0)

            if ($proposals.Count -eq 0 -and -not $mismatch) { return }
            if ($OnlyGaps -and -not $isGap) { return }

            $reports.Add([pscustomobject]@{
                path = $rel; layer = $layerDir; domain = $canonDomain; rawDomain = $fm.domain
                hasSignals = $fm.hasSignals; domainHasSeed = $domainHasSeed
                mismatch = $mismatch
                proposals = @($proposals | ForEach-Object {
                    [pscustomobject]@{
                        token = $_.token
                        pattern = '\b' + [regex]::Escape($_.token) + '\b'
                        keywordBacked = $_.keywordBacked
                        inBad = $_.inBad
                        note = if ($_.seedDomain) { "also seen in seed domain '$($_.seedDomain)'" } else { 'new construct' }
                    }
                })
            }) | Out-Null
        }
}

# ---- Emit ------------------------------------------------------------------
if ($AsJson) {
    [pscustomobject]@{
        generatedAt = (Get-Date).ToUniversalTime().ToString('o')
        root = $BCQualityRoot
        filter = $Path
        articleCount = $reports.Count
        reports = @($reports)
    } | ConvertTo-Json -Depth 8
    return
}

$flagged = @($reports | Where-Object { $_.mismatch }).Count
$zeroDomain = @($reports | Where-Object { -not $_.domainHasSeed }).Count
Write-Host ""
Write-Host "BCQuality authoring-assist (prototype) — SUGGESTIONS ONLY, nothing written." -ForegroundColor Cyan
Write-Host ("Articles with suggestions: {0}   Domain-mismatch flags: {1}   In zero-signal domains: {2}" -f $reports.Count, $flagged, $zeroDomain)
if ($Path) { Write-Host ("Filter: *{0}*" -f $Path) }
Write-Host ("-" * 78)

foreach ($r in ($reports | Sort-Object domain, path)) {
    Write-Host ""
    Write-Host $r.path -ForegroundColor White
    $domNote = if (-not $r.domainHasSeed) { " [zero-signal domain]" } else { "" }
    Write-Host ("  domain: {0}{1}   existing signals: {2}" -f $r.domain, $domNote, $(if ($r.hasSignals) { 'yes' } else { 'none' }))
    if ($r.mismatch) { Write-Host ("  ⚠ domain check: {0}" -f $r.mismatch) -ForegroundColor Yellow }
    if ($r.proposals.Count -gt 0) {
        Write-Host "  proposed signals: front-matter block ->" -ForegroundColor Green
        Write-Host "      signals:"
        foreach ($p in $r.proposals) {
            $why = @(); if ($p.keywordBacked) { $why += 'keyword-backed' }; if ($p.inBad) { $why += 'anti-pattern sample' }
            $whyStr = if ($why) { "   # " + ($why -join ', ') } else { "" }
            Write-Host ("        - {0}{1}" -f $p.token, $whyStr)
        }
    }
}
Write-Host ""
Write-Host "Review each suggestion; add the ones that fit via a normal PR. R24 + CI validate the shape." -ForegroundColor DarkGray
