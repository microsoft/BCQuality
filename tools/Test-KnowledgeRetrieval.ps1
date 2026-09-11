<#
.SYNOPSIS
    Validates lossless bounded catalog and exact-body retrieval.
#>
#requires -Version 7.2
[CmdletBinding()]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..'))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path -LiteralPath $Root).Path

$generator = Join-Path $Root 'tools/Build-KnowledgeIndex.ps1'
$search = Join-Path $Root 'tools/Search-Knowledge.ps1'
$getArticles = Join-Path $Root 'tools/Get-KnowledgeArticles.ps1'
$utf8 = [Text.UTF8Encoding]::new($false, $true)

function Assert-True {
    param([bool] $Condition, [string] $Message)
    if (-not $Condition) {
        throw "Assertion failed: $Message"
    }
}

function Assert-Equal {
    param($Actual, $Expected, [string] $Message)
    if ($Actual -cne $Expected) {
        throw "Assertion failed: $Message. Expected '$Expected', got '$Actual'."
    }
}

function Assert-Sequence {
    param($Actual, $Expected, [string] $Message)
    $actualJson = ConvertTo-Json -InputObject @($Actual) -Compress
    $expectedJson = ConvertTo-Json -InputObject @($Expected) -Compress
    if ($actualJson -cne $expectedJson) {
        throw "Assertion failed: $Message. Expected $expectedJson, got $actualJson."
    }
}

function Assert-Throws {
    param([scriptblock] $Action, [string] $Pattern, [string] $Message)
    try {
        & $Action
    }
    catch {
        if ($_.Exception.Message -notmatch $Pattern) {
            throw "Assertion failed: $Message. Wrong error: $($_.Exception.Message)"
        }
        return
    }
    throw "Assertion failed: $Message. No error was thrown."
}

function Get-OutputByteCount {
    param([string] $Text)
    return [Text.Encoding]::UTF8.GetByteCount($Text) +
        [Text.Encoding]::UTF8.GetByteCount([Environment]::NewLine)
}

function Invoke-CatalogPages {
    param(
        [hashtable] $Arguments,
        [int] $MaxBytes = 4096
    )

    $allCandidates = [Collections.Generic.List[object]]::new()
    $allExcluded = [Collections.Generic.List[object]]::new()
    $offset = 0
    $snapshot = ''
    $shared = ''
    $pageCount = 0
    $lastPage = $null
    do {
        $pageArguments = @{} + $Arguments
        $pageArguments.MaxBytes = $MaxBytes
        $pageArguments.Offset = $offset
        if ($snapshot) {
            $pageArguments.Snapshot = $snapshot
        }
        $raw = & $search @pageArguments
        Assert-True ($raw -is [string]) 'catalog helper emitted exactly one JSON string'
        Assert-True ((Get-OutputByteCount -Text $raw) -le $MaxBytes) 'catalog page includes its newline in MaxBytes'
        $page = $raw | ConvertFrom-Json
        $pageCount++
        Assert-True ($pageCount -le 1000) 'catalog continuation terminates'
        Assert-Equal $page.offset $offset 'catalog offset is exact'
        Assert-Equal $page.returnedCount (@($page.candidates).Count + @($page.excludedByConfiguration).Count) 'page returnedCount matches rows'
        Assert-Equal $page.remainingCount ($page.totalCount - $offset - $page.returnedCount) 'page remainingCount is exact'

        $currentShared = [ordered]@{
            version = $page.version
            domain = $page.domain
            context = $page.context
            enabledLayers = $page.enabledLayers
            indexedLayers = $page.indexedLayers
            excludeConditional = $page.excludeConditional
            defaults = $page.defaults
            candidateCount = $page.candidateCount
            excludedByConfigurationCount = $page.excludedByConfigurationCount
            snapshot = $page.snapshot
            totalCount = $page.totalCount
        } | ConvertTo-Json -Depth 8 -Compress
        if (-not $shared) {
            $shared = $currentShared
            $snapshot = $page.snapshot
        }
        else {
            Assert-Equal $currentShared $shared 'catalog pages repeat shared context, defaults, totals, and snapshot'
        }

        foreach ($row in @($page.candidates)) {
            $allCandidates.Add($row)
        }
        foreach ($row in @($page.excludedByConfiguration)) {
            $allExcluded.Add($row)
        }
        if (-not $page.complete) {
            Assert-True ($null -ne $page.continuation) 'incomplete page has continuation'
            Assert-Equal $page.continuation.snapshot $snapshot 'continuation is snapshot-bound'
            Assert-True ($page.continuation.offset -gt $offset) 'continuation makes progress'
            $offset = $page.continuation.offset
        }
        $lastPage = $page
    } while (-not $page.complete)

    Assert-True ($null -eq $lastPage.continuation) 'final page has no continuation'
    Assert-Equal $allCandidates.Count $lastPage.candidateCount 'candidate total survives paging'
    Assert-Equal $allExcluded.Count $lastPage.excludedByConfigurationCount 'excluded total survives paging'
    return [pscustomobject]@{
        candidates = @($allCandidates)
        excluded = @($allExcluded)
        pages = $pageCount
        snapshot = $snapshot
        lastPage = $lastPage
    }
}

function Test-BodyRoundTrip {
    param(
        [string[]] $Paths,
        [string] $IndexPath,
        [switch] $Samples
    )

    $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    for ($start = 0; $start -lt $Paths.Count; $start += 8) {
        $end = [Math]::Min($start + 7, $Paths.Count - 1)
        $remaining = @($Paths[$start..$end])
        $snapshot = ''
        do {
            $arguments = @{
                BCQualityRoot = $Root
                IndexPath = $IndexPath
                Paths = $remaining
                MaxArticles = 8
                MaxBytes = 16000
            }
            if ($Samples) {
                $arguments.Samples = $true
            }
            if ($snapshot) {
                $arguments.Snapshot = $snapshot
            }
            $raw = & $getArticles @arguments
            Assert-True ($raw -is [string]) 'article helper emitted exactly one JSON string'
            Assert-True ((Get-OutputByteCount -Text $raw) -le 16000) 'article batch includes its newline in MaxBytes'
            $batch = $raw | ConvertFrom-Json
            Assert-True ($batch.returnedCount -gt 0) 'article batching makes progress'
            Assert-Equal $batch.returnedCount @($batch.articles).Count 'article returnedCount matches rows'
            Assert-Equal $batch.complete (@($batch.remainingPaths).Count -eq 0) 'article completion matches remaining paths'
            if ($batch.complete) {
                Assert-True ($null -eq $batch.continuation) 'complete article batch has no continuation'
            }
            else {
                Assert-True ($batch.continuation.snapshot -match '^[a-f0-9]{64}$') 'article continuation is snapshot-bound'
            }

            foreach ($article in @($batch.articles)) {
                Assert-True ($seen.Add($article.path)) "body returned once: $($article.path)"
                $fullPath = Join-Path $Root ($article.path.Replace('/', [IO.Path]::DirectorySeparatorChar))
                $bytes = [IO.File]::ReadAllBytes($fullPath)
                $text = $utf8.GetString($bytes)
                $hash = [Convert]::ToHexString(
                    [Security.Cryptography.SHA256]::HashData($bytes)
                ).ToLowerInvariant()
                Assert-Equal $article.bytes $bytes.Length "byte count round-trips: $($article.path)"
                Assert-Equal $article.sha256 $hash "SHA-256 round-trips: $($article.path)"
                Assert-Equal $article.body $text "body round-trips: $($article.path)"
            }
            $remaining = @($batch.remainingPaths)
            $snapshot = if ($batch.complete) { '' } else { $batch.continuation.snapshot }
        } while ($remaining.Count)
    }
    Assert-Equal $seen.Count $Paths.Count 'every requested body round-trips without loss'
}

function New-NeutralArticle {
    param(
        [string] $FixtureRoot,
        [string] $Layer,
        [string] $Slug,
        [string] $Version = 'all',
        [string] $Technology = 'al',
        [string] $Country = 'w1',
        [string] $Area = 'all',
        [string] $Title = 'Neutral retrieval example',
        [string] $Description = 'Neutral retrieval metadata for deterministic tests.'
    )

    $directory = Join-Path $FixtureRoot "$Layer\knowledge\neutral"
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    $content = @"
---
bc-version: [$Version]
domain: neutral
keywords: [neutral, retrieval, deterministic]
technologies: [$Technology]
countries: [$Country]
application-area: [$Area]
---

# $Title

## Description

$Description
"@
    Set-Content -LiteralPath (Join-Path $directory "$Slug.md") -Value $content -Encoding utf8NoBOM
}

function Test-InvalidSourceIndexing {
    param(
        [string] $FixtureRoot,
        [string] $Field,
        [string] $ValidValue,
        [string] $InvalidValue
    )

    New-NeutralArticle -FixtureRoot $FixtureRoot -Layer microsoft -Slug valid-source
    New-NeutralArticle -FixtureRoot $FixtureRoot -Layer community -Slug invalid-source
    $articlePath = Join-Path $FixtureRoot 'community\knowledge\neutral\invalid-source.md'
    $text = [IO.File]::ReadAllText($articlePath, $utf8)
    $text = $text.Replace("$Field`: $ValidValue", "$Field`: $InvalidValue")
    [IO.File]::WriteAllText($articlePath, $text, $utf8)

    $indexPath = Join-Path (Split-Path $FixtureRoot -Parent) ("$Field-index.json")
    $generation = @(& $generator -BCQualityRoot $FixtureRoot -IndexPath $indexPath 3>&1)
    $warnings = @($generation | Where-Object { $_ -is [Management.Automation.WarningRecord] })
    Assert-Equal $warnings.Count 1 "scalar $Field source emits one omission warning"
    Assert-True (
        $warnings[0].Message -match
            "Skipping invalid knowledge article 'community/knowledge/neutral/invalid-source\.md': frontmatter field '$([regex]::Escape($Field))' must use non-empty bracket-array syntax\."
    ) "scalar $Field warning identifies the exact path and reason"
    $prepared = Get-Content -LiteralPath $indexPath -Raw -Encoding utf8 | ConvertFrom-Json
    Assert-Equal $prepared.articleCount 1 "scalar $Field source is omitted while its valid sibling is indexed"
    Assert-Sequence $prepared.articles.path @('microsoft/knowledge/neutral/valid-source.md') "scalar $Field index contains only the valid sibling"
    $catalog = & $search -BCQualityRoot $FixtureRoot -IndexPath $indexPath -Domain neutral |
        ConvertFrom-Json
    Assert-Sequence $catalog.candidates.path @('microsoft/knowledge/neutral/valid-source.md') "scalar $Field catalog retrieves the valid sibling"
    $valid = & $getArticles -BCQualityRoot $FixtureRoot -IndexPath $indexPath `
        -Paths 'microsoft/knowledge/neutral/valid-source.md' |
        ConvertFrom-Json
    Assert-True $valid.complete "scalar $Field valid sibling body retrieves completely"
    Assert-Throws {
        & $getArticles -BCQualityRoot $FixtureRoot -IndexPath $indexPath `
            -Paths 'community/knowledge/neutral/invalid-source.md'
    } 'Selected article is absent from the prepared index' "scalar $Field omitted source cannot be retrieved"
}

function Test-InvalidSemanticIndexing {
    param(
        [string] $FixtureRoot,
        [string] $CaseName,
        [string] $Field,
        [string] $ValidValue,
        [string] $InvalidValue,
        [string] $ExpectedReason
    )

    New-NeutralArticle -FixtureRoot $FixtureRoot -Layer microsoft -Slug valid-source
    New-NeutralArticle -FixtureRoot $FixtureRoot -Layer community -Slug invalid-source
    $articlePath = Join-Path $FixtureRoot 'community\knowledge\neutral\invalid-source.md'
    $text = [IO.File]::ReadAllText($articlePath, $utf8)
    $text = $text.Replace("$Field`: $ValidValue", "$Field`: $InvalidValue")
    [IO.File]::WriteAllText($articlePath, $text, $utf8)

    $indexPath = Join-Path (Split-Path $FixtureRoot -Parent) ("$CaseName-index.json")
    $generation = @(& $generator -BCQualityRoot $FixtureRoot -IndexPath $indexPath 3>&1)
    $warnings = @($generation | Where-Object { $_ -is [Management.Automation.WarningRecord] })
    Assert-Equal $warnings.Count 1 "$CaseName emits one omission warning"
    Assert-Equal $warnings[0].Message "Skipping invalid knowledge article 'community/knowledge/neutral/invalid-source.md': $ExpectedReason." "$CaseName warning identifies exact path and reason"

    $prepared = Get-Content -LiteralPath $indexPath -Raw -Encoding utf8 | ConvertFrom-Json
    Assert-Equal $prepared.articleCount 1 "$CaseName omits invalid source and retains valid sibling"
    Assert-Sequence $prepared.articles.path @('microsoft/knowledge/neutral/valid-source.md') "$CaseName index contains only valid sibling"
    Assert-True ($prepared.sourceSnapshot -match '^[a-f0-9]{64}$') "$CaseName source snapshot remains valid"
    $validRow = $prepared.articles[0]
    $manifest = @(
        [ordered]@{ path = $validRow.path; sha256 = $validRow.sourceSha256 }
    )
    $manifestBytes = [Text.Encoding]::UTF8.GetBytes(
        (ConvertTo-Json -InputObject $manifest -Depth 8 -Compress)
    )
    $expectedSnapshot = [Convert]::ToHexString(
        [Security.Cryptography.SHA256]::HashData($manifestBytes)
    ).ToLowerInvariant()
    Assert-Equal $prepared.sourceSnapshot $expectedSnapshot "$CaseName source snapshot covers only retained rows"

    $catalog = & $search -BCQualityRoot $FixtureRoot -IndexPath $indexPath -Domain neutral |
        ConvertFrom-Json
    Assert-Sequence $catalog.candidates.path @('microsoft/knowledge/neutral/valid-source.md') "$CaseName catalog retains valid sibling"
    $valid = & $getArticles -BCQualityRoot $FixtureRoot -IndexPath $indexPath `
        -Paths 'microsoft/knowledge/neutral/valid-source.md' |
        ConvertFrom-Json
    Assert-True $valid.complete "$CaseName valid sibling body retrieves"
    Assert-Throws {
        & $getArticles -BCQualityRoot $FixtureRoot -IndexPath $indexPath `
            -Paths 'community/knowledge/neutral/invalid-source.md'
    } 'Selected article is absent from the prepared index' "$CaseName invalid source cannot be retrieved"
}

function Test-InvalidEnabledLayers {
    param(
        [string] $FixtureRoot,
        [string] $CaseName,
        $Layers,
        [string] $ExpectedPattern
    )

    $indexPath = Join-Path (Split-Path $FixtureRoot -Parent) ("layers-$CaseName.json")
    $arguments = @{
        BCQualityRoot = $FixtureRoot
        IndexPath = $indexPath
        EnabledLayers = $Layers
    }
    Assert-Throws {
        & $generator @arguments
    } $ExpectedPattern "$CaseName EnabledLayers fails"
    Assert-True (-not (Test-Path -LiteralPath $indexPath)) "$CaseName fails before index creation"
}

$tmp = Join-Path ([IO.Path]::GetTempPath()) ("bcquality_retrieval_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
try {
    $indexPath = Join-Path $tmp 'knowledge-index.json'
    & $generator -BCQualityRoot $Root -IndexPath $indexPath | Out-Null
    $index = Get-Content -LiteralPath $indexPath -Raw -Encoding utf8 | ConvertFrom-Json
    $diskArticlePaths = @(
        foreach ($layer in 'microsoft', 'community', 'custom') {
            $knowledge = Join-Path $Root "$layer\knowledge"
            if (Test-Path -LiteralPath $knowledge) {
                Get-ChildItem -LiteralPath $knowledge -Recurse -File -Filter '*.md' |
                    ForEach-Object {
                        [IO.Path]::GetRelativePath($Root, $_.FullName).Replace('\', '/')
                    }
            }
        }
    ) | Sort-Object
    Assert-Equal $index.articleCount $diskArticlePaths.Count 'index covers every current article'
    Assert-True ($index.sourceSnapshot -match '^[a-f0-9]{64}$') 'index carries an exact source snapshot'

    $allCatalogRows = [Collections.Generic.List[object]]::new()
    $domains = @($index.articles.domain | Sort-Object -Unique)
    foreach ($domain in $domains) {
        $catalog = Invoke-CatalogPages -Arguments @{
            BCQualityRoot = $Root
            IndexPath = $indexPath
            Domain = $domain
        }
        Assert-Equal $catalog.excluded.Count 0 "all layers enabled for $domain"
        foreach ($row in $catalog.candidates) {
            $allCatalogRows.Add($row)
        }
    }

    $expectedRows = @($index.articles | Sort-Object path)
    $actualRows = @($allCatalogRows | Sort-Object path)
    Assert-Equal $actualRows.Count $expectedRows.Count 'paged union has no top-k or query-based loss'
    Assert-Sequence ($actualRows.path) ($expectedRows.path) 'paged union equals all READ-filtered candidates'
    Assert-Equal @($actualRows.path | Sort-Object -Unique).Count $actualRows.Count 'catalog does not deduplicate distinct paths'

    $defaults = [ordered]@{
        'bc-version' = @('all')
        technologies = @('al')
        countries = @('w1')
        'application-area' = @('all')
    }
    for ($i = 0; $i -lt $actualRows.Count; $i++) {
        $actual = $actualRows[$i]
        $expected = $expectedRows[$i]
        Assert-Equal $actual.path $expected.path 'catalog preserves exact path'
        Assert-Equal $actual.layer $expected.layer 'catalog preserves layer'
        Assert-Sequence $actual.keywords $expected.keywords 'catalog preserves full keywords'
        Assert-Equal $actual.title $expected.title 'catalog preserves title'
        Assert-Equal $actual.description $expected.description 'catalog preserves one-line description'

        $unknown = [Collections.Generic.List[string]]::new()
        foreach ($field in $defaults.Keys) {
            $expectedValues = @($expected.$field)
            $sentinel = switch ($field) {
                'bc-version' { 'all' }
                'countries' { 'w1' }
                'application-area' { 'all' }
                default { '' }
            }
            if (-not $sentinel -or $expectedValues -notcontains $sentinel) {
                $unknown.Add($field)
            }
            $hasField = $actual.PSObject.Properties.Name -ccontains $field
            if (($expectedValues -join "`0") -ceq (@($defaults[$field]) -join "`0")) {
                Assert-True (-not $hasField) "default field is inherited from page: $field"
            }
            else {
                Assert-True $hasField "non-default field survives paging: $field"
                Assert-Sequence $actual.$field $expectedValues "non-default field is exact: $field"
            }
        }
        Assert-Equal $actual.applicability ($(if ($unknown.Count) { 'conditional' } else { 'applicable' })) 'applicability verdict is explicit'
        Assert-Sequence $actual.unknownDimensions @($unknown) 'unknown dimensions are explicit'
    }

    $performanceFirst = & $search -BCQualityRoot $Root -IndexPath $indexPath -Domain performance -MaxBytes 4096 |
        ConvertFrom-Json
    Assert-True (-not $performanceFirst.complete) 'large domain produces deterministic continuation'
    Assert-Throws {
        & $search -BCQualityRoot $Root -IndexPath $indexPath -Domain performance -MaxBytes 4096 -Offset $performanceFirst.continuation.offset
    } 'Continuation requires Snapshot' 'continuation without snapshot fails'
    Assert-Throws {
        & $search -BCQualityRoot $Root -IndexPath $indexPath -Domain performance -Offset $performanceFirst.totalCount
    } 'Invalid Offset' 'offset at total fails'
    Assert-Throws {
        & $search -BCQualityRoot $Root -IndexPath $indexPath -Domain performance -Offset 1 -Snapshot ('0' * 64)
    } 'Snapshot changed' 'wrong snapshot fails'

    $changedRawIndex = Join-Path $tmp 'changed-raw-index.json'
    $changedRaw = Get-Content -LiteralPath $indexPath -Raw -Encoding utf8 | ConvertFrom-Json
    $changedRaw.generatedAt = [DateTimeOffset]::UtcNow.ToString('O')
    $changedRaw | ConvertTo-Json -Depth 8 -Compress |
        Set-Content -LiteralPath $changedRawIndex -Encoding utf8NoBOM -NoNewline
    Assert-Throws {
        & $search -BCQualityRoot $Root -IndexPath $changedRawIndex -Domain performance `
            -MaxBytes 4096 -Offset $performanceFirst.continuation.offset `
            -Snapshot $performanceFirst.continuation.snapshot
    } 'Snapshot changed' 'continuation is bound to the exact prepared index bytes'

    $malformedIndex = Join-Path $tmp 'malformed.json'
    Set-Content -LiteralPath $malformedIndex -Value '{not-json' -Encoding utf8NoBOM
    Assert-Throws {
        & $search -BCQualityRoot $Root -IndexPath $malformedIndex -Domain performance
    } 'Malformed knowledge index JSON' 'malformed JSON fails'

    $unsafeIndex = Join-Path $tmp 'unsafe.json'
    $unsafe = Get-Content -LiteralPath $indexPath -Raw -Encoding utf8 | ConvertFrom-Json
    $unsafe.articles[0].path = '../outside.md'
    $unsafe | ConvertTo-Json -Depth 8 -Compress |
        Set-Content -LiteralPath $unsafeIndex -Encoding utf8NoBOM
    Assert-Throws {
        & $search -BCQualityRoot $Root -IndexPath $unsafeIndex -Domain performance
    } 'Invalid knowledge path' 'unsafe indexed path fails'

    $invalidRowIndex = Join-Path $tmp 'invalid-row.json'
    $invalidRow = Get-Content -LiteralPath $indexPath -Raw -Encoding utf8 | ConvertFrom-Json
    $invalidRow.articles[0].keywords = @()
    $invalidRow | ConvertTo-Json -Depth 8 -Compress |
        Set-Content -LiteralPath $invalidRowIndex -Encoding utf8NoBOM
    Assert-Throws {
        & $search -BCQualityRoot $Root -IndexPath $invalidRowIndex -Domain performance
    } 'Malformed knowledge index row' 'malformed index row fails'

    $semanticCorruptIndex = Join-Path $tmp 'semantic-corrupt-row.json'
    $semanticCorrupt = Get-Content -LiteralPath $indexPath -Raw -Encoding utf8 | ConvertFrom-Json
    $semanticCorrupt.articles[0].countries = @('usa')
    $semanticCorrupt | ConvertTo-Json -Depth 8 -Compress |
        Set-Content -LiteralPath $semanticCorruptIndex -Encoding utf8NoBOM
    Assert-Throws {
        & $search -BCQualityRoot $Root -IndexPath $semanticCorruptIndex -Domain performance
    } 'Malformed knowledge index row.*invalid countries' 'search rejects semantically invalid external index rows'

    $corruptSemanticCases = @(
        @{ name = 'uppercase-all'; field = 'bc-version'; value = @('ALL'); reason = 'invalid bc-version' },
        @{ name = 'uppercase-w1'; field = 'countries'; value = @('W1'); reason = 'invalid countries' },
        @{ name = 'zero-open-range'; field = 'bc-version'; value = @('"0.."'); reason = 'invalid bc-version range bound' },
        @{ name = 'zero-closed-range'; field = 'bc-version'; value = @('"0..0"'); reason = 'invalid bc-version range bound' }
    )
    foreach ($case in $corruptSemanticCases) {
        $corruptPath = Join-Path $tmp ("corrupt-$($case.name).json")
        $corrupt = Get-Content -LiteralPath $indexPath -Raw -Encoding utf8 | ConvertFrom-Json
        $corrupt.articles[0].PSObject.Properties[$case.field].Value = $case.value
        $corrupt | ConvertTo-Json -Depth 8 -Compress |
            Set-Content -LiteralPath $corruptPath -Encoding utf8NoBOM
        Assert-Throws {
            & $search -BCQualityRoot $Root -IndexPath $corruptPath -Domain performance
        } "Malformed knowledge index row.*$([regex]::Escape($case.reason))" "search rejects $($case.name) in an external index"
    }

    $invalidUtf8Root = Join-Path $tmp 'invalid-utf8-source'
    New-NeutralArticle -FixtureRoot $invalidUtf8Root -Layer microsoft -Slug valid-catalog
    New-NeutralArticle -FixtureRoot $invalidUtf8Root -Layer community -Slug invalid-utf8-source
    $invalidUtf8Article = Join-Path $invalidUtf8Root 'community\knowledge\neutral\invalid-utf8-source.md'
    $validBytes = [IO.File]::ReadAllBytes($invalidUtf8Article)
    [IO.File]::WriteAllBytes($invalidUtf8Article, [byte[]]@($validBytes + @(0xc3, 0x28)))
    $invalidUtf8Index = Join-Path $tmp 'invalid-utf8-index.json'
    $generation = @(& $generator -BCQualityRoot $invalidUtf8Root -IndexPath $invalidUtf8Index 3>&1)
    $warnings = @($generation | Where-Object { $_ -is [Management.Automation.WarningRecord] })
    Assert-Equal $warnings.Count 1 'malformed UTF-8 source emits one omission warning'
    Assert-Equal $warnings[0].Message "Skipping invalid knowledge article 'community/knowledge/neutral/invalid-utf8-source.md': invalid UTF-8." 'malformed UTF-8 warning identifies the exact path and reason'
    $invalidUtf8Prepared = Get-Content -LiteralPath $invalidUtf8Index -Raw -Encoding utf8 |
        ConvertFrom-Json
    Assert-Equal $invalidUtf8Prepared.articleCount 1 'malformed UTF-8 source is omitted while its valid sibling is indexed'
    Assert-Sequence $invalidUtf8Prepared.articles.path @('microsoft/knowledge/neutral/valid-catalog.md') 'malformed UTF-8 index contains only the valid sibling'
    $validCatalog = & $search -BCQualityRoot $invalidUtf8Root -IndexPath $invalidUtf8Index -Domain neutral |
        ConvertFrom-Json
    Assert-Sequence $validCatalog.candidates.path @('microsoft/knowledge/neutral/valid-catalog.md') 'catalog retrieves the valid sibling after malformed UTF-8 omission'
    $validBody = & $getArticles -BCQualityRoot $invalidUtf8Root -IndexPath $invalidUtf8Index `
        -Paths 'microsoft/knowledge/neutral/valid-catalog.md' |
        ConvertFrom-Json
    Assert-True $validBody.complete 'valid sibling body retrieves after malformed UTF-8 omission'
    Assert-Throws {
        & $getArticles -BCQualityRoot $invalidUtf8Root -IndexPath $invalidUtf8Index `
            -Paths 'community/knowledge/neutral/invalid-utf8-source.md'
    } 'Selected article is absent from the prepared index' 'omitted malformed UTF-8 source cannot be retrieved'

    $scalarCases = @(
        @{ field = 'bc-version'; valid = '[all]'; invalid = 'all' },
        @{ field = 'keywords'; valid = '[neutral, retrieval, deterministic]'; invalid = 'neutral' },
        @{ field = 'technologies'; valid = '[al]'; invalid = 'al' },
        @{ field = 'countries'; valid = '[w1]'; invalid = 'w1' },
        @{ field = 'application-area'; valid = '[all]'; invalid = 'all' }
    )
    foreach ($case in $scalarCases) {
        Test-InvalidSourceIndexing -FixtureRoot (Join-Path $tmp "scalar-$($case.field)") `
            -Field $case.field -ValidValue $case.valid -InvalidValue $case.invalid
    }

    $semanticCases = @(
        @{ name = 'mixed-version-sentinel'; field = 'bc-version'; valid = '[all]'; invalid = '[all, 27]'; reason = 'mixed bc-version sentinel' },
        @{ name = 'invalid-country'; field = 'countries'; valid = '[w1]'; invalid = '[usa]'; reason = 'invalid countries' },
        @{ name = 'descending-version-range'; field = 'bc-version'; valid = '[all]'; invalid = '["28..27"]'; reason = 'descending bc-version range' },
        @{ name = 'malformed-version-range'; field = 'bc-version'; valid = '[all]'; invalid = '[twenty-seven]'; reason = 'invalid bc-version' },
        @{ name = 'malformed-keyword'; field = 'keywords'; valid = '[neutral, retrieval, deterministic]'; invalid = '[neutral, Bad_Token, deterministic]'; reason = 'invalid keywords' },
        @{ name = 'malformed-technology'; field = 'technologies'; valid = '[al]'; invalid = '[AL]'; reason = 'invalid technologies' },
        @{ name = 'malformed-application-area'; field = 'application-area'; valid = '[all]'; invalid = '[finance_]'; reason = 'invalid application-area' },
        @{ name = 'uppercase-version-sentinel'; field = 'bc-version'; valid = '[all]'; invalid = '[ALL]'; reason = 'invalid bc-version' },
        @{ name = 'uppercase-country-sentinel'; field = 'countries'; valid = '[w1]'; invalid = '[W1]'; reason = 'invalid countries' },
        @{ name = 'zero-open-version-range'; field = 'bc-version'; valid = '[all]'; invalid = '["0.."]'; reason = 'invalid bc-version range bound' },
        @{ name = 'zero-closed-version-range'; field = 'bc-version'; valid = '[all]'; invalid = '["0..0"]'; reason = 'invalid bc-version range bound' }
    )
    foreach ($case in $semanticCases) {
        Test-InvalidSemanticIndexing -FixtureRoot (Join-Path $tmp "semantic-$($case.name)") `
            -CaseName $case.name -Field $case.field -ValidValue $case.valid `
            -InvalidValue $case.invalid -ExpectedReason $case.reason
    }

    Assert-Throws {
        & $search -BCQualityRoot $Root -IndexPath $indexPath -Domain ('x' * 2000) -MaxBytes 1024
    } 'Page envelope exceeds' 'oversized page envelope fails'

    $articlePaths = @($index.articles.path | Sort-Object)
    Assert-Sequence $articlePaths $diskArticlePaths 'exact article path union matches disk'
    Assert-Throws {
        & $getArticles -BCQualityRoot $Root -IndexPath $indexPath -Paths @($articlePaths[0..8])
    } 'exceeds MaxArticles=8' 'exact retrieval rejects path batches larger than eight'
    $samplePaths = @(
        foreach ($layer in 'microsoft', 'community', 'custom') {
            $knowledge = Join-Path $Root "$layer\knowledge"
            if (Test-Path -LiteralPath $knowledge) {
                Get-ChildItem -LiteralPath $knowledge -Recurse -File |
                    Where-Object Name -Match '\.(good|bad)\.[a-z0-9]+$' |
                    ForEach-Object {
                        [IO.Path]::GetRelativePath($Root, $_.FullName).Replace('\', '/')
                    }
            }
        }
    ) | Sort-Object
    Test-BodyRoundTrip -Paths $articlePaths -IndexPath $indexPath
    Test-BodyRoundTrip -Paths $samplePaths -IndexPath $indexPath -Samples

    $fixtureRoot = Join-Path $tmp 'neutral'
    New-NeutralArticle -FixtureRoot $fixtureRoot -Layer microsoft -Slug default
    New-NeutralArticle -FixtureRoot $fixtureRoot -Layer community -Slug versioned -Version '"27.."' -Technology javascript -Country dk -Area finance -Title 'Versioned neutral example'
    New-NeutralArticle -FixtureRoot $fixtureRoot -Layer custom -Slug localized -Version 28 -Technology al -Country de -Area service -Title 'Localized neutral example'
    $fixtureIndex = Join-Path $tmp 'neutral-index.json'
    & $generator -BCQualityRoot $fixtureRoot -IndexPath $fixtureIndex | Out-Null

    foreach ($case in @(
        @{ name = 'uppercase'; layers = @('Microsoft'); pattern = 'unique canonical lowercase layer names' },
        @{ name = 'duplicate'; layers = @('microsoft', 'microsoft'); pattern = 'unique canonical lowercase layer names' },
        @{ name = 'unknown'; layers = @('partner'); pattern = 'unique canonical lowercase layer names' },
        @{ name = 'null'; layers = $null; pattern = 'must be an array' }
    )) {
        Test-InvalidEnabledLayers -FixtureRoot $fixtureRoot -CaseName $case.name `
            -Layers $case.layers -ExpectedPattern $case.pattern
    }
    $subsetIndex = Join-Path $tmp 'community-only-index.json'
    & $generator -BCQualityRoot $fixtureRoot -IndexPath $subsetIndex `
        -EnabledLayers @('community') | Out-Null
    $subset = & $search -BCQualityRoot $fixtureRoot -IndexPath $subsetIndex `
        -Domain neutral -EnabledLayers @('community') |
        ConvertFrom-Json
    Assert-Equal $subset.candidateCount 1 'valid EnabledLayers subset builds and is consumable'
    Assert-Sequence $subset.candidates.path @('community/knowledge/neutral/versioned.md') 'valid subset contains only its exact layer'

    $applicable = Invoke-CatalogPages -Arguments @{
        BCQualityRoot = $fixtureRoot
        IndexPath = $fixtureIndex
        Domain = 'neutral'
        BCVersion = 28
        Technologies = @('al', 'javascript')
        Countries = @('dk', 'de')
        ApplicationAreas = @('finance', 'service')
    } -MaxBytes 16000
    Assert-Equal $applicable.candidates.Count 3 'neutral layer/version rows all survive matching context'
    Assert-True (@($applicable.candidates | Where-Object applicability -CEQ applicable).Count -eq 3) 'matching rows are applicable'
    $versioned = $applicable.candidates | Where-Object path -CEQ 'community/knowledge/neutral/versioned.md'
    Assert-Equal $versioned.layer community 'non-default layer survives'
    Assert-Sequence $versioned.'bc-version' @('"27.."') 'original version metadata survives'
    Assert-Equal $versioned.applicability applicable 'lowercase sentinels and positive open range remain applicable'
    Assert-Sequence $versioned.technologies @('javascript') 'non-default technology survives'
    Assert-Sequence $versioned.countries @('dk') 'non-default country survives'
    Assert-Sequence $versioned.'application-area' @('finance') 'non-default application area survives'

    # Metadata validation accepts range bounds wider than Int32, so version
    # matching must compare as bigint rather than coercing the bound down.
    $wideRoot = Join-Path $tmp 'wide-version'
    New-NeutralArticle -FixtureRoot $wideRoot -Layer microsoft -Slug wide-closed -Version '"1..99999999999"'
    New-NeutralArticle -FixtureRoot $wideRoot -Layer microsoft -Slug wide-open -Version '"99999999999.."'
    $wideIndex = Join-Path $tmp 'wide-version-index.json'
    & $generator -BCQualityRoot $wideRoot -IndexPath $wideIndex | Out-Null
    $wide = Invoke-CatalogPages -Arguments @{
        BCQualityRoot = $wideRoot
        IndexPath = $wideIndex
        Domain = 'neutral'
        BCVersion = 28
    } -MaxBytes 16000
    Assert-Sequence $wide.candidates.path @('microsoft/knowledge/neutral/wide-closed.md') 'bc-version bounds beyond Int32 compare without overflow'

    $conditional = Invoke-CatalogPages -Arguments @{
        BCQualityRoot = $fixtureRoot
        IndexPath = $fixtureIndex
        Domain = 'neutral'
        BCVersion = 28
        Technologies = @('al', 'javascript')
    } -MaxBytes 16000
    $conditionalVersioned = $conditional.candidates |
        Where-Object path -CEQ 'community/knowledge/neutral/versioned.md'
    Assert-Equal $conditionalVersioned.applicability conditional 'unknown context produces conditional verdict'
    Assert-Sequence $conditionalVersioned.unknownDimensions @('countries', 'application-area') 'unknown dimensions survive'

    $layerFiltered = Invoke-CatalogPages -Arguments @{
        BCQualityRoot = $fixtureRoot
        IndexPath = $fixtureIndex
        Domain = 'neutral'
        EnabledLayers = @('microsoft')
    } -MaxBytes 16000
    Assert-Equal $layerFiltered.candidates.Count 1 'enabled layer remains a candidate'
    Assert-Equal $layerFiltered.excluded.Count 2 'disabled layers remain explicit'
    Assert-Sequence ($layerFiltered.excluded.layer | Sort-Object) @('community', 'custom') 'excluded rows preserve layer'

    $oldSnapshot = $conditional.snapshot
    Add-Content -LiteralPath (Join-Path $fixtureRoot 'community\knowledge\neutral\versioned.md') -Value ' ' -Encoding utf8NoBOM
    $preparedCatalog = & $search -BCQualityRoot $fixtureRoot -IndexPath $fixtureIndex -Domain neutral |
        ConvertFrom-Json
    Assert-Equal $preparedCatalog.candidateCount 3 'catalog uses the prepared index without rehashing article bodies'
    Assert-Throws {
        & $getArticles -BCQualityRoot $fixtureRoot -IndexPath $fixtureIndex `
            -Paths 'community/knowledge/neutral/versioned.md'
    } 'Selected article hash does not match the prepared index' 'exact retrieval detects selected article changes'
    & $generator -BCQualityRoot $fixtureRoot -IndexPath $fixtureIndex | Out-Null
    Assert-Throws {
        & $search -BCQualityRoot $fixtureRoot -IndexPath $fixtureIndex -Domain neutral -Offset 1 -Snapshot $oldSnapshot
    } 'Snapshot changed' 'continuation cannot cross rebuilt snapshots'

    $largeRoot = Join-Path $tmp 'large-catalog'
    New-NeutralArticle -FixtureRoot $largeRoot -Layer microsoft -Slug huge-title -Title ('T' * 3000)
    $largeIndex = Join-Path $tmp 'large-index.json'
    & $generator -BCQualityRoot $largeRoot -IndexPath $largeIndex | Out-Null
    Assert-Throws {
        & $search -BCQualityRoot $largeRoot -IndexPath $largeIndex -Domain neutral -MaxBytes 1024
    } 'One complete candidates row|Page envelope exceeds' 'oversized catalog row fails without clipping'

    # The shared pager reports the oversized row's identity for any row shape;
    # a row without a path must still reach its explicit offset-based failure.
    . (Join-Path $Root 'tools/Bounded-Results.ps1')
    $pagerHeader = [ordered]@{ version = 2; snapshot = ('0' * 64) }
    foreach ($shape in @(
        @{ name = 'dictionary'; row = [ordered]@{ blob = ('x' * 3000) } },
        @{ name = 'object'; row = [pscustomobject]@{ blob = ('x' * 3000) } }
    )) {
        Assert-Throws {
            ConvertTo-BoundedPage -Header $pagerHeader `
                -Groups ([ordered]@{ rows = @($shape.row) }) -MaxBytes 1024
        } 'One complete rows row plus envelope exceeds MaxBytes=1024 at Offset=0' "oversized pathless $($shape.name) row fails with its offset identity"
    }

    $bodyRoot = Join-Path $tmp 'body-failures'
    New-NeutralArticle -FixtureRoot $bodyRoot -Layer microsoft -Slug huge-body -Description ('x' * 3000)
    New-NeutralArticle -FixtureRoot $bodyRoot -Layer microsoft -Slug broken-link
    New-NeutralArticle -FixtureRoot $bodyRoot -Layer microsoft -Slug continuation-one -Description ('a' * 300)
    New-NeutralArticle -FixtureRoot $bodyRoot -Layer microsoft -Slug continuation-two -Description ('b' * 300)
    New-NeutralArticle -FixtureRoot $bodyRoot -Layer microsoft -Slug invalid-utf8
    New-NeutralArticle -FixtureRoot $bodyRoot -Layer microsoft -Slug sample-one
    New-NeutralArticle -FixtureRoot $bodyRoot -Layer microsoft -Slug sample-two
    Add-Content -LiteralPath (Join-Path $bodyRoot 'microsoft\knowledge\neutral\sample-one.md') `
        -Value '[`sample-one.good.al`](sample-one.good.al)' -Encoding utf8NoBOM
    Add-Content -LiteralPath (Join-Path $bodyRoot 'microsoft\knowledge\neutral\sample-two.md') `
        -Value '[`sample-two.good.al`](sample-two.good.al)' -Encoding utf8NoBOM
    Set-Content -LiteralPath (Join-Path $bodyRoot 'microsoft\knowledge\neutral\sample-one.good.al') `
        -Value ('a' * 900) -Encoding utf8NoBOM
    Set-Content -LiteralPath (Join-Path $bodyRoot 'microsoft\knowledge\neutral\sample-two.good.al') `
        -Value ('b' * 900) -Encoding utf8NoBOM
    $bodyIndex = Join-Path $tmp 'body-index.json'
    & $generator -BCQualityRoot $bodyRoot -IndexPath $bodyIndex | Out-Null
    Assert-Throws {
        & $getArticles -BCQualityRoot $bodyRoot -IndexPath $bodyIndex `
            -Paths 'microsoft/knowledge/neutral/huge-body.md' -MaxBytes 1024
    } 'No complete body plus continuation fits' 'oversized body fails without truncation'
    Assert-Throws {
        & $getArticles -BCQualityRoot $bodyRoot -IndexPath $bodyIndex -Paths '../outside.md'
    } 'Invalid knowledge path' 'unsafe requested path fails'
    Assert-Throws {
        & $getArticles -BCQualityRoot $bodyRoot -IndexPath $bodyIndex `
            -Paths 'microsoft/knowledge/neutral/huge-body.md' -EnabledLayers community
    } 'Layer disabled' 'disabled article layer fails'
    Assert-Throws {
        & $getArticles -BCQualityRoot $bodyRoot -IndexPath $bodyIndex -Paths @(
            'microsoft/knowledge/neutral/huge-body.md',
            'microsoft/knowledge/neutral/huge-body.md'
        )
    } 'Duplicate requested path' 'duplicate exact paths fail'

    $brokenSample = Join-Path $bodyRoot 'microsoft\knowledge\neutral\broken-link.good.al'
    Set-Content -LiteralPath $brokenSample -Value 'codeunit 1 Neutral { }' -Encoding utf8NoBOM
    Assert-Throws {
        & $getArticles -BCQualityRoot $bodyRoot -IndexPath $bodyIndex `
            -Paths 'microsoft/knowledge/neutral/broken-link.good.al' -Samples
    } 'Sample is not linked' 'unlinked sample fails'

    $sampleContinuationPaths = @(
        'microsoft/knowledge/neutral/sample-one.good.al',
        'microsoft/knowledge/neutral/sample-two.good.al'
    )
    $firstSamplePage = & $getArticles -BCQualityRoot $bodyRoot -IndexPath $bodyIndex `
        -Paths $sampleContinuationPaths -Samples -MaxBytes 1600 |
        ConvertFrom-Json
    Assert-True (-not $firstSamplePage.complete) 'bounded sample batch produces continuation'
    Assert-Sequence $firstSamplePage.remainingPaths @('microsoft/knowledge/neutral/sample-two.good.al') 'sample continuation preserves pending path'
    Add-Content -LiteralPath (Join-Path $bodyRoot 'microsoft\knowledge\neutral\sample-two.good.al') `
        -Value 'changed' -Encoding utf8NoBOM
    Assert-Throws {
        & $getArticles -BCQualityRoot $bodyRoot -IndexPath $bodyIndex `
            -Paths @($firstSamplePage.remainingPaths) -Samples `
            -Snapshot $firstSamplePage.continuation.snapshot
    } 'Article snapshot changed' 'sample continuation rejects a changed pending sample'

    $continuationPaths = @(
        'microsoft/knowledge/neutral/continuation-one.md',
        'microsoft/knowledge/neutral/continuation-two.md'
    )
    $firstBodyPage = & $getArticles -BCQualityRoot $bodyRoot -IndexPath $bodyIndex `
        -Paths $continuationPaths -MaxBytes 1300 |
        ConvertFrom-Json
    Assert-True (-not $firstBodyPage.complete) 'bounded article batch produces continuation'
    Assert-Throws {
        & $getArticles -BCQualityRoot $bodyRoot -IndexPath $bodyIndex `
            -Paths @($firstBodyPage.remainingPaths) -Snapshot ('0' * 64)
    } 'Article snapshot changed' 'wrong article continuation snapshot fails'
    Add-Content -LiteralPath (Join-Path $bodyRoot 'microsoft\knowledge\neutral\continuation-two.md') -Value 'changed' -Encoding utf8NoBOM
    Assert-Throws {
        & $getArticles -BCQualityRoot $bodyRoot -IndexPath $bodyIndex `
            -Paths @($firstBodyPage.remainingPaths) -Snapshot $firstBodyPage.continuation.snapshot
    } 'Selected article hash does not match the prepared index' 'article continuation rejects a changed remaining body'

    $invalidUtf8 = Join-Path $bodyRoot 'microsoft\knowledge\neutral\invalid-utf8.md'
    $indexedBytes = [IO.File]::ReadAllBytes($invalidUtf8)
    [IO.File]::WriteAllBytes($invalidUtf8, [byte[]]@($indexedBytes + @(0xc3, 0x28)))
    Assert-Throws {
        & $getArticles -BCQualityRoot $bodyRoot -IndexPath $bodyIndex `
            -Paths 'microsoft/knowledge/neutral/invalid-utf8.md'
    } 'Knowledge file is not valid strict UTF-8' 'invalid UTF-8 fails'

    Write-Host "Knowledge retrieval check PASSED: $($articlePaths.Count) articles and $($samplePaths.Count) samples round-tripped; catalog union was lossless and bounded." -ForegroundColor Green
}
finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
