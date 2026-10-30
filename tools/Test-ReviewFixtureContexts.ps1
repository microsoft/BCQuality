<#
.SYNOPSIS
    Regression checks for context-dependent review fixtures after neutral preparation.
#>
[CmdletBinding()]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..')),
    [string] $WorkDirectory = (Join-Path ([IO.Path]::GetTempPath()) "bcquality-context-tests-$([guid]::NewGuid().ToString('N'))")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path -LiteralPath $Root).Path
New-Item -ItemType Directory -Path $WorkDirectory -ErrorAction Stop | Out-Null
$runner = (Get-Process -Id $PID).Path
$harness = Join-Path $Root 'tools/Test-ReviewFixtures.ps1'
$prepared = Join-Path $WorkDirectory 'prepared'
$log = @(& $runner -NoProfile -File $harness -Root $Root -PrepareDirectory $prepared 2>&1)
if ($LASTEXITCODE -ne 0) { throw "Fixture preparation failed: $($log -join [Environment]::NewLine)" }

function Assert-True {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) { throw $Message }
}

function Get-OpaqueId {
    param([string] $ManifestId)
    $hash = [Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($ManifestId))
    return 'case-' + [Convert]::ToHexString($hash).Substring(0, 8).ToLowerInvariant()
}

$slug = 'describe-api-pages-for-mcp-with-abouttext'
$prefix = "web-services-$slug"
$mcpContext = "Target Business Central online version 28. The API page and API query in this input are exposed as tools through Business Central's built-in MCP server."
$restContext = 'Target Business Central online version 28. The API page and API query in this input serve a REST integration only and are not exposed through MCP.'
$ids = @{
    bad = Get-OpaqueId "$prefix-bad"
    good = Get-OpaqueId "$prefix-good"
    rest = Get-OpaqueId "$prefix-clean-non-mcp"
}
$all = Get-Content -LiteralPath (Join-Path $prepared 'review-request.json') -Raw | ConvertFrom-Json
$domain = Get-Content -LiteralPath (Join-Path $prepared 'request-web-services.json') -Raw | ConvertFrom-Json
foreach ($kind in 'bad', 'good', 'rest') {
    $id = $ids[$kind]
    $expectedContext = if ($kind -eq 'rest') { $restContext } else { $mcpContext }
    $singlePath = Join-Path $prepared "request-$id.json"
    Assert-True (Test-Path -LiteralPath $singlePath) "Missing prepared context case: $kind"
    $single = Get-Content -LiteralPath $singlePath -Raw | ConvertFrom-Json
    foreach ($request in $all, $domain, $single) {
        $case = @($request.cases | Where-Object id -eq $id)
        Assert-True ($case.Count -eq 1) "Context case $kind must occur once in each request format."
        Assert-True ($case[0].PSObject.Properties.Name -contains 'context') "Prepared $kind case lost its deployment context."
        Assert-True ($case[0].context -ceq $expectedContext) "Prepared $kind case has the wrong context."
        $keys = @($case[0].PSObject.Properties.Name | Sort-Object) -join ','
        Assert-True ($keys -ceq 'context,file,id') "Prepared $kind case reveals internal fixture metadata."
    }
}
$badCode = Get-Content -LiteralPath (Join-Path $prepared "$($ids.bad).al") -Raw
$restCode = Get-Content -LiteralPath (Join-Path $prepared "$($ids.rest).al") -Raw
Assert-True ($badCode -ceq $restCode) 'The non-MCP control must use exactly the positive case code; only deployment context changes.'
Assert-True ($badCode -notmatch '(?m)^\s*//') 'Full-line comments must still be removed.'
foreach ($case in @($domain.cases | Where-Object { $_.id -notin @($ids.Values) })) {
    Assert-True ($case.PSObject.Properties.Name -notcontains 'context') 'MCP context leaked to another web-services article.'
}
$finance = Get-Content -LiteralPath (Join-Path $prepared 'request-finance.json') -Raw | ConvertFrom-Json
foreach ($case in $finance.cases) {
    Assert-True ($case.context -ceq 'Target Business Central 28, worldwide standard application (w1). Review each file as an independent source input.') 'Existing domain-wide context changed.'
}

# Exercise scoring through the public CLI. Other positive cases intentionally
# have no findings; only the context control's specific diagnostics are asserted.
$results = [pscustomobject]@{ cases = @($all.cases | ForEach-Object { [pscustomobject]@{ id = $_.id; findings = @() } }) }
$resultsPath = Join-Path $WorkDirectory 'results.json'
$results | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $resultsPath -Encoding utf8
$score = @(& $runner -NoProfile -File $harness -Root $Root -ResultsPath $resultsPath 2>&1) -join "`n"
Assert-True ($LASTEXITCODE -eq 1) 'Empty findings must fail the positive cases.'
Assert-True (-not $score.Contains("${prefix}-clean-non-mcp:")) 'An empty non-MCP control should be accepted.'
($results.cases | Where-Object id -eq $ids.rest).findings = @('microsoft/knowledge/web-services/describe-api-pages-for-mcp-with-abouttext.md')
$results | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $resultsPath -Encoding utf8
$score = @(& $runner -NoProfile -File $harness -Root $Root -ResultsPath $resultsPath 2>&1) -join "`n"
Assert-True ($LASTEXITCODE -eq 1 -and $score.Contains("${prefix}-clean-non-mcp: clean control produced finding(s):")) 'Scoring must reject a finding on the non-MCP control.'
$results.cases = @($results.cases | Where-Object id -ne $ids.rest)
$results | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $resultsPath -Encoding utf8
$score = @(& $runner -NoProfile -File $harness -Root $Root -ResultsPath $resultsPath 2>&1) -join "`n"
Assert-True ($LASTEXITCODE -eq 1 -and $score.Contains("Results missing case: ${prefix}-clean-non-mcp")) 'Scoring must require the non-MCP control.'

foreach ($invalid in 'unselected-article', 'empty-context', 'empty-clean-context', 'invalid-control-name') {
    $manifest = Get-Content -LiteralPath (Join-Path $Root 'evaluation/review-fixtures.json') -Raw | ConvertFrom-Json
    $entry = $manifest.overrides.'web-services'.articleOverrides.$slug
    switch ($invalid) {
        'unselected-article' { $manifest.overrides.'web-services'.articleOverrides | Add-Member -NotePropertyName 'not-selected' -NotePropertyValue $entry }
        'empty-context' { $entry.context = ' ' }
        'empty-clean-context' { $entry.cleanContexts.'non-mcp' = ' ' }
        'invalid-control-name' { $entry.cleanContexts | Add-Member -NotePropertyName '../escape' -NotePropertyValue $restContext }
    }
    $manifestPath = Join-Path $WorkDirectory "$invalid.json"
    $manifest | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $manifestPath -Encoding utf8
    $validation = @(& $runner -NoProfile -File $harness -Root $Root -ManifestPath $manifestPath 2>&1) -join "`n"
    Assert-True ($LASTEXITCODE -eq 1 -and $validation.Contains('articleOverrides')) "Invalid article override was not diagnosed: $invalid"
}
Write-Host 'Review fixture context regression checks PASSED: request formats, isolation, neutralization, clean-control scoring, and invalid overrides.' -ForegroundColor Green
