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

$licenseSlug = 'triage-posted-table-license-failures-against-baseline'
$fixtureManifest = Get-Content -LiteralPath (Join-Path $Root 'evaluation/review-fixtures.json') -Raw | ConvertFrom-Json
$licenseContext = $fixtureManifest.overrides.testing.articleOverrides.$licenseSlug.context
$testing = Get-Content -LiteralPath (Join-Path $prepared 'request-testing.json') -Raw | ConvertFrom-Json
$licenseIds = @('bad', 'good' | ForEach-Object { Get-OpaqueId "testing-$licenseSlug-$_" })
foreach ($id in $licenseIds) {
    $single = Get-Content -LiteralPath (Join-Path $prepared "request-$id.json") -Raw | ConvertFrom-Json
    foreach ($request in $all, $testing, $single) {
        $case = @($request.cases | Where-Object id -eq $id)
        Assert-True ($case.Count -eq 1) 'The posted-table license case must occur once in each request format.'
        Assert-True ($case[0].context -ceq $licenseContext) 'The posted-table license case lost its deployment context.'
        $keys = @($case[0].PSObject.Properties.Name | Sort-Object) -join ','
        Assert-True ($keys -ceq 'context,file,id') 'The posted-table license case reveals internal fixture metadata.'
    }
}
foreach ($case in @($testing.cases | Where-Object id -notin $licenseIds)) {
    Assert-True ($case.PSObject.Properties.Name -notcontains 'context') 'License-specific context leaked to another testing article.'
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
# BDD tag lines: exact standalone tags survive preparation; everything else is
# stripped exactly as before.
. (Join-Path $Root 'tools/Review-FixtureText.ps1')
function ConvertTo-PreviousFixtureText {
    param([string] $Text)
    $previous = [regex]::Replace($Text, '(?m)^\s*//.*(?:\r?\n|$)', '')
    return [regex]::Replace($previous, '\b(?:Good|Bad)\b', 'Eval')
}
foreach ($newline in "`n", "`r`n") {
    $kept = @(
        '// [FEATURE] Sales pricing',
        '        // [SCENARIO] A customer price applies to the order line',
        "`t// [GIVEN] a customer",
        '    //[WHEN] the line is created',
        '    //   [THEN] the unit price is taken from the price list',
        "    // [THEN]`tthe line amount is recalculated",
        '    // [THEN]'
    )
    $stripped = @(
        '    // [Given] a customer', '    // [given] a customer', '    // [WHENEVER] the line is created',
        '    // [WHEN]: the line is created', '    // [WHEN]the line is created', '    // [WHEN]-the line is created',
        '    /// [WHEN] the line is created', '    // [ WHEN ] the line is created', '    // - [WHEN] the line is created',
        '    // Note: [WHEN] the line is created', '    // // [WHEN] the line is created', '    // [STEP] the line is created',
        '    // Ordinary comment'
    )
    foreach ($line in $kept) {
        $text = "begin$newline$line${newline}end;$newline"
        Assert-True ((ConvertTo-ReviewFixtureText -Text $text) -ceq $text) "Exact BDD tag line was not kept: '$line'"
        Assert-True (@(Get-BddTagLine -Text $text).Count -eq 1) "Exact BDD tag line was not recognized: '$line'"
    }
    foreach ($line in $stripped) {
        $text = "begin$newline$line${newline}end;$newline"
        Assert-True ((ConvertTo-ReviewFixtureText -Text $text) -ceq "begin${newline}end;$newline") "Near-miss tag or ordinary comment was not stripped: '$line'"
        Assert-True (@(Get-BddTagLine -Text $text).Count -eq 0) "Near-miss tag was recognized as a BDD tag: '$line'"
    }
    $inline = "    Customer.Insert(); // [WHEN] inline after code$newline"
    Assert-True ((ConvertTo-ReviewFixtureText -Text $inline) -ceq $inline) 'Inline comments after code must stay unchanged.'
    Assert-True (@(Get-BddTagLine -Text $inline).Count -eq 0) 'A tag after code is not a standalone tag line.'
    $untagged = "codeunit 1 Good${newline}{$newline$newline    // Bad: ordinary comment$newline    // [Given] near miss${newline}    x := 1; // inline Bad$newline}$newline// trailing comment at end of file"
    Assert-True ((ConvertTo-ReviewFixtureText -Text $untagged) -ceq (ConvertTo-PreviousFixtureText -Text $untagged)) 'Text without BDD tags must prepare exactly as before.'
    $keptComments = "// [GIVEN] a Good customer$newline// Ordinary Bad comment$newline"
    Assert-True ((ConvertTo-ReviewFixtureText -Text $keptComments -KeepComments) -ceq "// [GIVEN] a Eval customer$newline// Ordinary Eval comment$newline") 'keepComments must still keep every comment and neutralize Good/Bad.'
}
foreach ($label in '// [THEN] a Good result', '// [GIVEN] the bad customer', '// [WHEN] the Anti-pattern runs', '// [WHEN] the antipattern runs', '// [WHEN] an anti pattern runs') {
    Assert-True (Test-BddTagLineLabel -TagLineText $label) "Outcome label was not detected: '$label'"
}
foreach ($neutral in '// [THEN] the badge number is shown', '// [GIVEN] a goodwill entry', '// [WHEN] the sales line is created') {
    Assert-True (-not (Test-BddTagLineLabel -TagLineText $neutral)) "Neutral tag line was reported as an outcome label: '$neutral'"
}

# Corpus. Cases are mapped to their sources through the manifest IDs, not
# through the preparer: the first selected article of a domain is
# '<domain>-<kind>', every other one '<domain>-<slug>-<kind>'.
function Get-SelectedArticleSlugs {
    param([object] $DomainOverride)
    if (-not $DomainOverride) { return @() }
    if ($DomainOverride.PSObject.Properties.Name -contains 'articles') { return @($DomainOverride.articles | ForEach-Object { [string]$_ }) }
    if ($DomainOverride.PSObject.Properties.Name -contains 'article') { return @([string]$DomainOverride.article) }
    return @()
}
$fixtureManifest = Get-Content -LiteralPath (Join-Path $Root 'evaluation/review-fixtures.json') -Raw | ConvertFrom-Json
$keepCommentsIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($entry in @($fixtureManifest.keepComments)) {
    $parts = ([string]$entry.article) -split '/'
    $keepDomain = $parts[2]
    $keepSlug = [IO.Path]::GetFileNameWithoutExtension($parts[3])
    $slugs = @(Get-SelectedArticleSlugs $fixtureManifest.overrides.$keepDomain)
    foreach ($kind in 'bad', 'good') {
        $manifestId = if ($slugs.Count -and $slugs[0] -ceq $keepSlug) { "$keepDomain-$kind" } else { "$keepDomain-$keepSlug-$kind" }
        $keepCommentsIds.Add((Get-OpaqueId $manifestId)) | Out-Null
    }
}
# Outside keepComments, no ordinary full-line comment and no near-miss tag survives anywhere.
foreach ($caseFile in Get-ChildItem -LiteralPath $prepared -Filter 'case-*.al' -File) {
    $caseId = [IO.Path]::GetFileNameWithoutExtension($caseFile.Name)
    if ($keepCommentsIds.Contains($caseId)) { continue }
    $tagLineNumbers = @(Get-BddTagLine -Text (Get-Content -LiteralPath $caseFile.FullName -Raw) | ForEach-Object Line)
    $lineNumber = 0
    foreach ($line in Get-Content -LiteralPath $caseFile.FullName) {
        $lineNumber++
        if ($line -match '^\s*//' -and $lineNumber -notin $tagLineNumbers) {
            throw "Prepared case $caseId kept a full-line comment that is not a BDD tag line: $line"
        }
    }
}
# Testing: each prepared input keeps exactly its source tag lines, removing
# them gives exactly the previous preparation, and the same file serves all
# three request formats.
$testingRequest = Get-Content -LiteralPath (Join-Path $prepared 'request-testing.json') -Raw | ConvertFrom-Json
$testingSlugs = @(Get-SelectedArticleSlugs $fixtureManifest.overrides.testing)
Assert-True ($testingSlugs.Count -gt 0) 'The testing domain must select articles explicitly.'
$tagInputCount = 0
for ($index = 0; $index -lt $testingSlugs.Count; $index++) {
    $slug = $testingSlugs[$index]
    foreach ($kind in 'bad', 'good') {
        $manifestId = if ($index -eq 0) { "testing-$kind" } else { "testing-$slug-$kind" }
        $caseId = Get-OpaqueId $manifestId
        $sourceText = Get-Content -LiteralPath (Join-Path $Root "microsoft/knowledge/testing/$slug.$kind.al") -Raw
        $preparedPath = Join-Path $prepared "$caseId.al"
        Assert-True (Test-Path -LiteralPath $preparedPath) "Missing prepared testing case $manifestId."
        $preparedText = Get-Content -LiteralPath $preparedPath -Raw
        # Set-Content appended one platform newline to the prepared text.
        if ($preparedText.EndsWith([Environment]::NewLine)) {
            $preparedText = $preparedText.Substring(0, $preparedText.Length - [Environment]::NewLine.Length)
        }
        $sourceTags = @(Get-BddTagLine -Text $sourceText | ForEach-Object Text)
        $preparedTags = @(Get-BddTagLine -Text $preparedText | ForEach-Object Text)
        Assert-True (($sourceTags -join "`n") -ceq ($preparedTags -join "`n")) "Prepared $manifestId does not keep exactly its source tag lines."
        Assert-True ((ConvertTo-PreviousFixtureText -Text $preparedText) -ceq (ConvertTo-PreviousFixtureText -Text $sourceText)) "Prepared $manifestId differs from the previous preparation by more than its tag lines."
        foreach ($tag in $preparedTags) {
            Assert-True ($tag -notmatch '\bEval\b') "A kept tag line in $manifestId carried a neutralized Good/Bad label: $tag"
        }
        $hasTests = $sourceText -match '\[Test\]'
        if ($slug -ceq 'test-feature-scenario-tags' -and $kind -eq 'bad') {
            Assert-True ($preparedTags.Count -eq 0) 'The test-feature-scenario-tags positive must stay untagged.'
        } elseif ($hasTests) {
            Assert-True ($preparedTags.Count -gt 0) "Selected testing sample $slug.$kind.al has [Test] procedures but no BDD tag lines."
        }
        if ($preparedTags.Count) { $tagInputCount++ }
        $single = Get-Content -LiteralPath (Join-Path $prepared "request-$caseId.json") -Raw | ConvertFrom-Json
        foreach ($request in $all, $testingRequest, $single) {
            $case = @($request.cases | Where-Object id -eq $caseId)
            Assert-True ($case.Count -eq 1 -and $case[0].file -ceq "$caseId.al") "Testing case $manifestId must occur once in each request format and point to its prepared file."
        }
    }
}
Assert-True ($tagInputCount -gt 0) 'No prepared testing case kept a BDD tag line.'

# The harness rejects an outcome label in a retained tag line before
# neutralization. It runs on a scratch copy of the inputs it reads.
$labelRoot = Join-Path $WorkDirectory 'label-root'
try {
    New-Item -ItemType Directory -Path $labelRoot | Out-Null
    foreach ($item in 'community', 'custom', 'docs', 'evaluation', 'microsoft', 'schemas', 'skills', 'tools') {
        $source = Join-Path $Root $item
        if (Test-Path -LiteralPath $source) { Copy-Item -LiteralPath $source -Destination $labelRoot -Recurse }
    }
    $labelSample = Join-Path $labelRoot 'microsoft/knowledge/testing/test-one-when-per-test.good.al'
    $labelText = "// [FEATURE] Good pricing`n" + (Get-Content -LiteralPath $labelSample -Raw)
    Set-Content -LiteralPath $labelSample -Value $labelText -Encoding utf8NoBOM -NoNewline
    $validation = @(& $runner -NoProfile -File (Join-Path $labelRoot 'tools/Test-ReviewFixtures.ps1') -Root $labelRoot 2>&1) -join "`n"
    Assert-True ($LASTEXITCODE -eq 1 -and $validation.Contains('microsoft/knowledge/testing/test-one-when-per-test.good.al:1: retained BDD tag line names an outcome')) "An outcome label in a retained tag line was not diagnosed: $validation"
}
finally {
    Remove-Item -LiteralPath $labelRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Review fixture context regression checks PASSED: request formats, isolation, neutralization, clean-control scoring, invalid overrides, and BDD tag retention ($tagInputCount tagged inputs)." -ForegroundColor Green
# Expected negative subprocesses must not determine a successful CI step exit.
exit 0
