<#
.SYNOPSIS
    CI guard for the knowledge-index generator (tools/Build-KnowledgeIndex.ps1).

.DESCRIPTION
    BCQuality owns the knowledge index, so BCQuality CI — not each consumer —
    proves the generator is healthy. This script does NOT ship a committed
    index that consumers trust at runtime (the index is rebuilt over each
    consumer's already-pruned clone by Entry's preparation step, which keeps it
    exact for any policy). Instead it asserts the generator itself is sound:

      1. Determinism — building twice yields byte-identical output once the
         volatile `generatedAt` header is normalized.
      2. Coverage — every `*/knowledge/**/*.md` article appears exactly once;
         every indexed path exists; no duplicates; no article is dropped.
      3. Selection-input integrity — every parsed article row carries the
         non-empty `domain` + `keywords` the worklist predicate selects on, and
         every article parses (an unparseable article is an invalid file).

    Exit code 0 = healthy; non-zero = a problem CI must block on.
#>
[CmdletBinding()]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..' '..'))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$generator = Join-Path $Root 'tools/Build-KnowledgeIndex.ps1'
if (-not (Test-Path $generator)) { throw "Generator not found: $generator" }

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("kbindex_" + [guid]::NewGuid().ToString('N'))
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
$rows = @($index.articles)

# 2. Coverage: one row per knowledge .md, every path real, no duplicates.
$onDisk = @(
    foreach ($layer in 'microsoft', 'community', 'custom') {
        $kb = Join-Path $Root (Join-Path $layer 'knowledge')
        if (Test-Path $kb) {
            Get-ChildItem -LiteralPath $kb -Recurse -File -Filter '*.md' |
                ForEach-Object { ($_.FullName.Substring($Root.Length).TrimStart([char]'/', [char]'\') -replace '\\', '/') }
        }
    }
)
if ($rows.Count -ne $onDisk.Count) {
    $problems.Add("Coverage mismatch: index has $($rows.Count) rows, disk has $($onDisk.Count) knowledge .md files.") | Out-Null
}
$rowPaths = @($rows | ForEach-Object { $_.path })
$dupes = @($rowPaths | Group-Object | Where-Object Count -gt 1 | ForEach-Object { $_.Name })
if ($dupes.Count) { $problems.Add("Duplicate index rows: $($dupes -join ', ')") | Out-Null }
$missingOnDisk = @($rowPaths | Where-Object { -not (Test-Path (Join-Path $Root $_)) })
if ($missingOnDisk.Count) { $problems.Add("Indexed paths absent on disk: $($missingOnDisk -join ', ')") | Out-Null }
$missingInIndex = @($onDisk | Where-Object { $rowPaths -notcontains $_ })
if ($missingInIndex.Count) { $problems.Add("Articles missing from index: $($missingInIndex -join ', ')") | Out-Null }

# 3. Selection-input integrity: parsed rows must carry domain + keywords.
$unparsed = @($rows | Where-Object { -not $_.parsed } | ForEach-Object { $_.path })
if ($unparsed.Count) { $problems.Add("Unparseable (invalid) articles: $($unparsed -join ', ')") | Out-Null }
foreach ($r in $rows | Where-Object { $_.parsed }) {
    if ([string]::IsNullOrWhiteSpace([string]$r.domain)) { $problems.Add("Empty domain: $($r.path)") | Out-Null }
    if (-not @($r.keywords).Where({ "$_".Trim() }).Count) { $problems.Add("Empty keywords: $($r.path)") | Out-Null }
}

Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue

if ($problems.Count) {
    Write-Host "Knowledge-index check FAILED ($($problems.Count) problem(s)):" -ForegroundColor Red
    $problems | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}
Write-Host "Knowledge-index check PASSED: $($rows.Count) articles, deterministic, full coverage, selection inputs intact." -ForegroundColor Green
exit 0
