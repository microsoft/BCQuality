<#
.SYNOPSIS
    Smoke test for the authoring-assist feature: tools/Suggest-ArticleSignals.ps1
    (suggestion engine + JSON contract) and tools/New-AuthoringAssistComment.ps1
    (advisory comment renderer). Runs against this repository's own corpus.

.DESCRIPTION
    Ships in BCQuality next to the tool so the feature is regression-guarded in
    its own repo (wired into CI via .github/workflows/authoring-assist-selftest.yml).
    Asserts stable, high-value behavior plus the feedback contract the automated
    PR advisory and the BC-ALAgentsInternal harvester depend on:
      * schemaVersion / toolVersion present
      * per-proposal suggestionId present, deterministic, and effect-sensitive
      * -ChangedFiles exact-match scoping
      * renderer emits the anchor + aa:meta + aa:article markers and a
        paste-ready signals block (raise bare-token / suppress mapping form)

.PARAMETER BCQualityRoot
    Content root to scan. Defaults to the repo root (parent of tools/).
#>
[CmdletBinding()]
param(
    [string] $BCQualityRoot,
    [string] $SeedPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $BCQualityRoot) { $BCQualityRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path }
$tool     = Join-Path $PSScriptRoot 'Suggest-ArticleSignals.ps1'
$renderer = Join-Path $PSScriptRoot 'New-AuthoringAssistComment.ps1'

# The routing seed is OPTIONAL (owned by the routing-index tuning thread). Detect
# whether one is available so the seed-only features (domain-mismatch, catalog
# de-dup) are exercised when present and asserted dormant when absent.
if (-not $SeedPath) {
    $defaultSeed = Join-Path $PSScriptRoot 'routing-seed.json'
    if (Test-Path -LiteralPath $defaultSeed) { $SeedPath = $defaultSeed }
}
$seedPresent = [bool]$SeedPath
$seedArgs = if ($seedPresent) { @('-SeedPath', $SeedPath) } else { @() }

$pass = 0; $fail = 0
function Check($name, [bool]$cond) {
    if ($cond) { Write-Host "  PASS  $name" -ForegroundColor Green; $script:pass++ }
    else       { Write-Host "  FAIL  $name" -ForegroundColor Red;   $script:fail++ }
}

Write-Host 'Test-SuggestArticleSignals' -ForegroundColor Cyan
Check 'tool exists' (Test-Path $tool)
Check 'renderer exists' (Test-Path $renderer)

# 1) Known keyword-backed anti-pattern construct is proposed as a raise trigger.
$j = & $tool -BCQualityRoot $BCQualityRoot -Path 'avoid-commit-inside-loops' -AsJson | ConvertFrom-Json
$commit = $j.reports | Where-Object { $_.path -like '*avoid-commit-inside-loops*' }
Check 'commit-in-loops article reported' ($null -ne $commit)
Check 'proposes Commit signal' (@($commit.proposals | Where-Object token -eq 'Commit').Count -eq 1)

# 2) JSON contract: schema + tool version present.
Check 'json carries schemaVersion' (-not [string]::IsNullOrWhiteSpace($j.schemaVersion))
Check 'json carries toolVersion' (-not [string]::IsNullOrWhiteSpace($j.toolVersion))

# 3) suggestionId present + deterministic across runs.
$firstId = @($commit.proposals)[0].suggestionId
Check 'proposal carries suggestionId' (-not [string]::IsNullOrWhiteSpace($firstId))
$j2 = & $tool -BCQualityRoot $BCQualityRoot -Path 'avoid-commit-inside-loops' -AsJson | ConvertFrom-Json
$firstId2 = @(($j2.reports | Where-Object { $_.path -like '*avoid-commit-inside-loops*' }).proposals)[0].suggestionId
Check 'suggestionId is deterministic' ($firstId -eq $firstId2)

# 4) Zero-signal Style domain yields a real property signal.
$style = & $tool -BCQualityRoot $BCQualityRoot -Path 'api-page-version-format' -AsJson | ConvertFrom-Json
$sr = $style.reports | Where-Object { $_.path -like '*api-page-version-format*' }
Check 'style article marked zero-signal domain' ($sr.domainHasSeed -eq $false)
Check 'proposes APIVersion signal' (@($sr.proposals | Where-Object token -eq 'APIVersion').Count -ge 1)

# 5) Suppressor detection: effect suppress + suggestionId differs from a raise id
#    for the same token (effect participates in the id).
$supp = & $tool -BCQualityRoot $BCQualityRoot -Path 'page-display-is-not-a-privacy-concern' -AsJson | ConvertFrom-Json
$sp = $supp.reports | Where-Object { $_.path -like '*page-display-is-not-a-privacy-concern*' }
Check 'suppressor article detected' ($sp.suppressor -eq $true)
Check 'suppressor effect is suppress' ($sp.effect -eq 'suppress')
Check 'suppressor proposals carry effect suppress' (@($sp.proposals | Where-Object { $_.effect -eq 'suppress' }).Count -ge 1)

# 6) Prohibition is NOT mis-classified as a suppressor.
$prohib = & $tool -BCQualityRoot $BCQualityRoot -Path 'do-not-add-ishandled-to-an-existing-event' -AsJson | ConvertFrom-Json
$pr = $prohib.reports | Where-Object { $_.path -like '*do-not-add-ishandled*' }
Check 'prohibition article is not a suppressor' ($null -eq $pr -or $pr.suppressor -eq $false)

# 7) Domain-mismatch is a seed-only enrichment. With a seed present it must fire
#    on a known cross-domain article; seed-free it must stay dormant (null) while
#    the corpus scan still succeeds — proving graceful degradation.
$full = & $tool -BCQualityRoot $BCQualityRoot @seedArgs -AsJson | ConvertFrom-Json
Check 'reports >100 articles corpus-wide' ($full.articleCount -gt 100)
$mm = $full.reports | Where-Object { $_.path -like '*avoid-raising-events-inside-try-functions*' -and $_.mismatch }
if ($seedPresent) {
    Check 'events/try-function article flagged as domain-mismatch (seeded)' ($null -ne $mm)
} else {
    Check 'domain-mismatch dormant without a seed' ($null -eq $mm)
    Check 'seed-free corpus still marks every domain zero-signal' (@($full.reports | Where-Object { $_.domainHasSeed }).Count -eq 0)
}

# 8) -ChangedFiles exact-match scoping: only the listed knowledge md is reported;
#    non-md and non-existent entries are ignored.
$target = $commit.path
$cf = & $tool -BCQualityRoot $BCQualityRoot -ChangedFiles @($target, 'README.md', 'microsoft/knowledge/does-not-exist.md') -AsJson | ConvertFrom-Json
Check 'ChangedFiles reports exactly the one changed article' ($cf.articleCount -eq 1 -and $cf.reports[0].path -eq $target)

# 9) Renderer: emits anchor + markers + a paste-ready signals block.
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('aa-selftest-' + [guid]::NewGuid().ToString('N') + '.json')
try {
    & $tool -BCQualityRoot $BCQualityRoot -ChangedFiles @($target) -AsJson | Set-Content -LiteralPath $tmp -Encoding UTF8
    $md = & $renderer -JsonPath $tmp
    Check 'renderer emits advisory anchor' ($md -match '<!-- authoring-assist-advisory -->')
    Check 'renderer emits aa:meta marker' ($md -match '<!-- aa:meta ')
    Check 'renderer emits aa:article marker with suggestions' ($md -match '<!-- aa:article .*suggestions="[0-9a-f]')
    Check 'renderer emits raise signals block' ($md -match '(?m)^\s*-\s+Commit\s*$')
} finally {
    if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force }
}

# 10) Renderer: empty report renders the "no suggestions" comment, still anchored.
$emptyTmp = Join-Path ([System.IO.Path]::GetTempPath()) ('aa-empty-' + [guid]::NewGuid().ToString('N') + '.json')
try {
    '{ "schemaVersion":"1.0","toolVersion":"1.0.0","generatedAt":"x","articleCount":0,"reports":[] }' | Set-Content -LiteralPath $emptyTmp -Encoding UTF8
    $mdEmpty = & $renderer -JsonPath $emptyTmp
    Check 'empty renders anchored no-suggestions comment' (($mdEmpty -match '<!-- authoring-assist-advisory -->') -and ($mdEmpty -match 'No routing head-matter suggestions'))
} finally {
    if (Test-Path -LiteralPath $emptyTmp) { Remove-Item -LiteralPath $emptyTmp -Force }
}

Write-Host ''
Write-Host ("Result: {0} passed, {1} failed" -f $pass, $fail) -ForegroundColor $(if ($fail) { 'Red' } else { 'Green' })
if ($fail) { exit 1 }
