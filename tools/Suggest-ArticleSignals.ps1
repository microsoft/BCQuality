<#
.SYNOPSIS
    Authoring-assist (PROTOTYPE): reviews the routing-relevant front-matter of
    BCQuality knowledge articles. It proposes `signals:` (trigger AND suppressor),
    flags declared-`domain` vs sample-content mismatches, cross-checks
    `technologies`, and suggests `keywords` — all suggestion-only.

.DESCRIPTION
    Routing quality is capped by how well each article's front-matter describes
    the code it catches. Today most articles declare no explicit `signals:` block
    and several review domains have zero detection signals, so a large slice of
    knowledge is only reachable via the catch-all pass. This tool lowers the
    authoring cost of closing that gap. For each article it reads the co-located
    `good`/`bad` `.al` samples AND the article prose (inline code + fenced `al`
    blocks), extracts candidate AL constructs, and emits:

      * A proposed `signals:` block. For a normal article these are RAISE
        triggers. For a "this-is-not-a-violation" article (detected from the
        title/prose) they are `effect: suppress` entries, which DAMPEN the
        domain score instead of raising it.
      * A domain-mismatch flag when the samples look like another domain.
      * An applicability note when the samples use a technology (e.g. JavaScript
        control add-ins) not declared in `technologies`.
      * Keyword suggestions for strong constructs missing from `keywords`.

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
    domain, are a suppressor candidate, or trigger a domain-mismatch/applicability
    flag — i.e. where the suggestion adds the most value. Off = report every
    article that yields a suggestion.

.PARAMETER NoProse
    Ignore article prose; use only the `.al` samples as the construct source.

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
    [switch] $NoProse,
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
    if (-not $Lines -or @($Lines).Count -lt 1 -or $Lines[0].Trim() -ne '---') { return $null }
    $fmEnd = -1
    for ($i = 1; $i -lt $Lines.Count; $i++) { if ($Lines[$i].Trim() -eq '---') { $fmEnd = $i; break } }
    if ($fmEnd -lt 0) { return $null }
    $domain = ''; $keywords = @(); $technologies = @(); $hasSignals = $false
    for ($i = 1; $i -lt $fmEnd; $i++) {
        if ($Lines[$i] -match '^\s*domain\s*:\s*(.+?)\s*$') { $domain = $Matches[1].Trim() }
        elseif ($Lines[$i] -match '^\s*keywords\s*:\s*\[(.*)\]\s*$') {
            $inner = $Matches[1].Trim()
            if ($inner) { $keywords = @($inner -split '\s*,\s*' | ForEach-Object { $_.Trim() }) }
        }
        elseif ($Lines[$i] -match '^\s*technologies\s*:\s*\[(.*)\]\s*$') {
            $inner = $Matches[1].Trim()
            if ($inner) { $technologies = @($inner -split '\s*,\s*' | ForEach-Object { $_.Trim().ToLowerInvariant() }) }
        }
        elseif ($Lines[$i] -match '^\s*signals\s*:') { $hasSignals = $true }
    }
    return [pscustomobject]@{ domain = $domain; keywords = $keywords; technologies = $technologies; hasSignals = $hasSignals; fmEnd = $fmEnd }
}

# A "suppressor" article exists to say a construct is NOT a violation of its
# domain (e.g. page-display-is-not-a-privacy-concern). Its constructs should be
# proposed as effect: suppress, not raise. Detected from the title/basename and
# prose — but NOT prohibitions ("do-not-add-X" means X *is* a violation).
function Test-SuppressorArticle {
    param([string] $BaseName, [string] $Body)
    $bn = $BaseName.ToLowerInvariant()
    if ($bn -match '^(do-not|dont|do-nt|avoid|never|no-inline|prevent|disallow|must-not)') { return $false }
    $suppressName = $bn -match '(is-not-a|is-not-an|not-a-violation|not-a-[a-z-]*concern|not-an-[a-z-]*issue|need-no|need-not|-allowed(-|$)|allowed-on|is-fine|is-acceptable|no-[a-z-]*concern|exempt)'
    if ($suppressName) { return $true }
    # Prose phrasing as a weaker secondary signal (first ~40 lines of body).
    $head = ($Body -split "`n" | Select-Object -First 40) -join "`n"
    if ($head -match '(?i)\b(is not a (violation|concern|problem|privacy)|not a violation|no .{0,20}concern|need no |perfectly (fine|acceptable)|is acceptable here|not flagged)\b') {
        # Guard against prohibition prose.
        if ($head -notmatch '(?i)\b(do not|don''t|avoid|never|must not|should not)\b') { return $true }
    }
    return $false
}

# Extract candidate AL constructs from ARTICLE PROSE: fenced ```al code blocks
# (same shape as samples) and inline `code` spans that look like AL constructs.
# Prose is a weaker source than a .al sample — used to reach the articles that
# ship no samples, and to corroborate sample constructs.
function Get-ProseConstructs {
    param([string] $Body)
    $out = @{}
    if (-not $Body) { return $out }
    # Fenced al/pascal code blocks.
    foreach ($m in [regex]::Matches($Body, '(?s)```(?:al|pascal)?\s*(.*?)```')) {
        foreach ($kv in (Get-SampleConstructs -Text $m.Groups[1].Value -IsBad:$false).GetEnumerator()) {
            if (-not $out.ContainsKey($kv.Key)) { $out[$kv.Key] = 0 }
            $out[$kv.Key] += $kv.Value.count
        }
    }
    # Inline code spans that are a single AL-construct-shaped token.
    foreach ($m in [regex]::Matches($Body, '`([A-Za-z][A-Za-z0-9]*)\s*(?:\(\))?`')) {
        $tok = $m.Groups[1].Value
        if ($tok -notmatch '^[A-Z][A-Za-z0-9]{2,}$') { continue }
        if ($stop.ContainsKey($tok.ToLowerInvariant())) { continue }
        if (-not $out.ContainsKey($tok)) { $out[$tok] = 0 }
        $out[$tok] += 1
    }
    return $out
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
            $body = ($lines | Select-Object -Skip ($fm.fmEnd + 1)) -join "`n"
            $isSuppressor = Test-SuppressorArticle -BaseName $_.BaseName -Body $body

            # Collect constructs from co-located samples (good + bad).
            $constructs = @{}
            $sampleCount = 0
            foreach ($sample in Get-ChildItem -LiteralPath $_.DirectoryName -Filter "$($_.BaseName)*.al" -ErrorAction SilentlyContinue) {
                $sampleCount++
                $isBad = $sample.Name -match '\.bad\.al$'
                $text = Get-Content -LiteralPath $sample.FullName -Raw -ErrorAction SilentlyContinue
                foreach ($kv in (Get-SampleConstructs -Text $text -IsBad:$isBad).GetEnumerator()) {
                    if (-not $constructs.ContainsKey($kv.Key)) { $constructs[$kv.Key] = @{ count = 0; inBad = $false; prose = $false; sample = $false } }
                    $constructs[$kv.Key].count += $kv.Value.count
                    $constructs[$kv.Key].sample = $true
                    if ($kv.Value.inBad) { $constructs[$kv.Key].inBad = $true }
                }
            }

            # Corroborate / fill gaps from prose (fenced al + inline code spans).
            if (-not $NoProse) {
                foreach ($kv in (Get-ProseConstructs -Body $body).GetEnumerator()) {
                    if (-not $constructs.ContainsKey($kv.Key)) { $constructs[$kv.Key] = @{ count = 0; inBad = $false; prose = $false; sample = $false } }
                    $constructs[$kv.Key].count += $kv.Value
                    $constructs[$kv.Key].prose = $true
                }
            }

            # Applicability cross-check: samples/prose that use JavaScript / control
            # add-ins but `technologies` omits javascript (small but concrete).
            $applicability = $null
            $jsUse = @($constructs.Keys | Where-Object { $_ -in @('ControlAddIn','StartupScript','RecreateControls','Scripts') }).Count -gt 0
            if (-not $jsUse -and ($body -match '(?i)\bcontrol\s*add-?in\b|\.js\b|javascript')) { $jsUse = $true }
            if ($jsUse -and ($fm.technologies -notcontains 'javascript')) {
                $applicability = "samples/prose reference a JavaScript control add-in but 'technologies' does not list 'javascript'"
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
                if ($constructs[$c].sample) { $score += 1 }                      # seen in an actual sample
                [pscustomobject]@{
                    token = $c; score = $score; inBad = $constructs[$c].inBad
                    keywordBacked = $kwset.ContainsKey($lc)
                    proseOnly = ($constructs[$c].prose -and -not $constructs[$c].sample)
                    seedDomain = $seedDomain
                    alreadyRoutes = ($seedDomain -eq $canonDomain)
                }
            }
            $cands = @($cands | Sort-Object -Property @{ Expression = 'score'; Descending = $true }, @{ Expression = 'token'; Descending = $false })

            # Domain-mismatch flag: among candidates already known to the seed,
            # what domain dominates? If it disagrees with the declared domain,
            # the article's code looks like it belongs elsewhere. Skipped for
            # suppressor articles, which deliberately reference other domains.
            $seedMatched = @($cands | Where-Object { $_.seedDomain })
            $mismatch = $null
            if (-not $isSuppressor -and $seedMatched.Count -ge 2) {
                $byDom = $seedMatched | Group-Object seedDomain | Sort-Object Count -Descending
                $dominant = $byDom[0]
                if ($dominant.Name -ne $canonDomain -and $dominant.Count -ge 2) {
                    $mismatch = "declared domain '$canonDomain' but $($dominant.Count) sample construct(s) route to '$($dominant.Name)' ($([string]::Join(', ', ($dominant.Group | ForEach-Object { $_.token } | Select-Object -First 4))))"
                }
            }

            # Proposals: for a suppressor, the highest-value constructs (they say
            # "seeing this here is fine") become effect: suppress. For a normal
            # article, the highest-value NEW triggers = not already routed here.
            $effect = if ($isSuppressor) { 'suppress' } else { 'raise' }
            $proposals = @(if ($isSuppressor) {
                @($cands | Select-Object -First $Top)
            } else {
                @($cands | Where-Object { -not $_.alreadyRoutes } | Select-Object -First $Top)
            })

            # Keyword suggestions: strong proposed tokens not already a keyword.
            $keywordSuggestions = @($proposals | Where-Object { -not $_.keywordBacked } | ForEach-Object { $_.token } | Select-Object -First 3)

            $domainHasSeed = ($seedByToken.Values -contains $canonDomain)
            $isGap = (-not $domainHasSeed) -or ($mismatch) -or ($applicability) -or ($isSuppressor) -or (-not $fm.hasSignals -and $proposals.Count -gt 0)

            if ($proposals.Count -eq 0 -and -not $mismatch -and -not $applicability) { return }
            if ($OnlyGaps -and -not $isGap) { return }

            $reports.Add([pscustomobject]@{
                path = $rel; layer = $layerDir; domain = $canonDomain; rawDomain = $fm.domain
                hasSignals = $fm.hasSignals; domainHasSeed = $domainHasSeed
                suppressor = $isSuppressor; effect = $effect
                sampleCount = $sampleCount
                mismatch = $mismatch
                applicability = $applicability
                keywordSuggestions = $keywordSuggestions
                proposals = @($proposals | ForEach-Object {
                    [pscustomobject]@{
                        token = $_.token
                        pattern = '\b' + [regex]::Escape($_.token) + '\b'
                        effect = $effect
                        keywordBacked = $_.keywordBacked
                        inBad = $_.inBad
                        proseOnly = $_.proseOnly
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
$suppressors = @($reports | Where-Object { $_.suppressor }).Count
$applic = @($reports | Where-Object { $_.applicability }).Count
Write-Host ""
Write-Host "BCQuality authoring-assist (prototype) — SUGGESTIONS ONLY, nothing written." -ForegroundColor Cyan
Write-Host ("Articles with suggestions: {0}   Suppressor articles: {1}   Domain-mismatch: {2}   Applicability: {3}   Zero-signal domain: {4}" -f $reports.Count, $suppressors, $flagged, $applic, $zeroDomain)
if ($Path) { Write-Host ("Filter: *{0}*" -f $Path) }
Write-Host ("-" * 78)

foreach ($r in ($reports | Sort-Object domain, path)) {
    Write-Host ""
    $title = if ($r.suppressor) { "$($r.path)  [SUPPRESSOR]" } else { $r.path }
    Write-Host $title -ForegroundColor White
    $domNote = if (-not $r.domainHasSeed) { " [zero-signal domain]" } else { "" }
    Write-Host ("  domain: {0}{1}   existing signals: {2}   samples: {3}" -f $r.domain, $domNote, $(if ($r.hasSignals) { 'yes' } else { 'none' }), $r.sampleCount)
    if ($r.mismatch) { Write-Host ("  ⚠ domain check: {0}" -f $r.mismatch) -ForegroundColor Yellow }
    if ($r.applicability) { Write-Host ("  ⚠ applicability: {0}" -f $r.applicability) -ForegroundColor Yellow }
    if ($r.proposals.Count -gt 0) {
        $kind = if ($r.suppressor) { "SUPPRESS (this construct is NOT a violation here)" } else { "RAISE" }
        Write-Host ("  proposed signals [{0}]: front-matter block ->" -f $kind) -ForegroundColor Green
        Write-Host "      signals:"
        foreach ($p in $r.proposals) {
            $why = @()
            if ($p.keywordBacked) { $why += 'keyword-backed' }
            if ($p.inBad) { $why += 'anti-pattern sample' }
            if ($p.proseOnly) { $why += 'from prose' }
            $whyStr = if ($why) { "   # " + ($why -join ', ') } else { "" }
            if ($r.suppressor) {
                Write-Host ("        - token: {0}{1}" -f $p.token, $whyStr)
                Write-Host  "          effect: suppress"
            } else {
                Write-Host ("        - {0}{1}" -f $p.token, $whyStr)
            }
        }
    }
    if ($r.keywordSuggestions.Count -gt 0) {
        Write-Host ("  keyword idea: consider adding to 'keywords': {0}" -f ([string]::Join(', ', @($r.keywordSuggestions | ForEach-Object { ($_ -creplace '(?<!^)(?=[A-Z])', '-').ToLowerInvariant() })))) -ForegroundColor DarkCyan
    }
}
Write-Host ""
Write-Host "Review each suggestion; add the ones that fit via a normal PR. R24 + CI validate the shape." -ForegroundColor DarkGray
