<#
.SYNOPSIS
    Validates and prepares the BCQuality AL review evaluation corpus.

.DESCRIPTION
    CI uses the static validation path to prove every registered AL review leaf
    has one positive and one clean control, every fixture/reference exists, and
    the manifest remains internally consistent.

    For an actual model run, -PrepareDirectory copies inputs to neutral names and
    emits review-request.json without expected answers. After the model writes a
    result matching evaluation/README.md, -ResultsPath scores exact knowledge-ID
    recall, clean-control rate, and unexpected findings.
#>
[CmdletBinding()]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..')),
    [string] $ManifestPath,
    [string] $PrepareDirectory,
    [string] $ResultsPath,
    [string] $ResultsDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path -LiteralPath $Root).Path
if ($ResultsPath -and $ResultsDirectory) {
    throw 'Specify either ResultsPath or ResultsDirectory, not both.'
}
if (-not $ManifestPath) {
    $ManifestPath = Join-Path $Root 'evaluation/review-fixtures.json'
}
if (-not (Test-Path -LiteralPath $ManifestPath)) {
    throw "Review fixture manifest not found: $ManifestPath"
}

$manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
$problems = [System.Collections.Generic.List[string]]::new()

function Get-ModelCaseId {
    param([string] $ManifestId)

    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($ManifestId)
        $hash = $sha.ComputeHash($bytes)
        $token = ([System.BitConverter]::ToString($hash) -replace '-', '').Substring(0, 8).ToLowerInvariant()
        return "case-$token"
    } finally {
        $sha.Dispose()
    }
}

function Get-RankedArticles {
    param(
        [object[]] $Articles,
        [string] $CaseText,
        [int] $Limit = 10
    )

    if ($Articles.Count -le $Limit) {
        return @($Articles)
    }

    $normalized = (($CaseText.ToLowerInvariant() -replace '[^a-z0-9]+', ' ') -replace '\s+', ' ').Trim()
    $compact = $normalized -replace ' ', ''
    $ranked = foreach ($article in $Articles) {
        $score = 0
        foreach ($keyword in @($article.keywords)) {
            $keywordText = ([string]$keyword).ToLowerInvariant()
            $keywordCompact = $keywordText -replace '[^a-z0-9]+', ''
            if ($keywordCompact -and $compact.Contains($keywordCompact)) {
                $score += 8
            }
            foreach ($part in @($keywordText -split '[^a-z0-9]+')) {
                if (($part.Length -ge 4) -and ($normalized -match "(^| )$([regex]::Escape($part))( |$)")) {
                    $score += 1
                }
            }
        }
        $topicText = "$($article.title) $($article.description) $($article.path)".ToLowerInvariant()
        foreach ($term in @($normalized -split ' ' | Where-Object Length -ge 5 | Sort-Object -Unique)) {
            if ($topicText.Contains($term)) {
                $score += 0.25
            }
        }
        [pscustomobject]@{ score = $score; path = [string]$article.path; article = $article }
    }

    return @(
        $ranked |
            Sort-Object @{ Expression = 'score'; Descending = $true }, @{ Expression = 'path'; Descending = $false } |
            Select-Object -First $Limit |
            ForEach-Object article
    )
}

if ($manifest.version -ne 2) {
    $problems.Add("Unsupported manifest version: $($manifest.version)") | Out-Null
}
if ($manifest.selection -ne 'first-paired-al-article') {
    $problems.Add("Unsupported selection strategy: $($manifest.selection)") | Out-Null
}
if (([double]$manifest.minimumExpectedRecall -lt 0) -or ([double]$manifest.minimumExpectedRecall -gt 1)) {
    $problems.Add('minimumExpectedRecall must be between 0 and 1.') | Out-Null
}
if (([double]$manifest.minimumCleanRate -lt 0) -or ([double]$manifest.minimumCleanRate -gt 1)) {
    $problems.Add('minimumCleanRate must be between 0 and 1.') | Out-Null
}

$leafDomains = @(
    Get-ChildItem -LiteralPath (Join-Path $Root 'microsoft/skills/review') -File -Filter 'al-*-review.md' |
        Where-Object Name -ne 'al-code-review.md' |
        ForEach-Object { $_.BaseName -replace '^al-', '' -replace '-review$', '' } |
        Sort-Object -Unique
)

$overrides = @{}
if ($manifest.PSObject.Properties.Name -contains 'overrides') {
    foreach ($property in $manifest.overrides.PSObject.Properties) {
        $overrides[$property.Name] = $property.Value
    }
}
foreach ($overrideDomain in $overrides.Keys) {
    if ($leafDomains -notcontains $overrideDomain) {
        $problems.Add("Override domain '$overrideDomain' has no registered al-$overrideDomain-review leaf.") | Out-Null
    }
}

$caseList = [System.Collections.Generic.List[object]]::new()
foreach ($domain in $leafDomains) {
    $knowledgeDirectory = Join-Path $Root "microsoft/knowledge/$domain"
    if (-not (Test-Path -LiteralPath $knowledgeDirectory -PathType Container)) {
        $problems.Add("${domain}: no Microsoft knowledge directory exists.") | Out-Null
        continue
    }

    $override = if ($overrides.ContainsKey($domain)) { $overrides[$domain] } else { $null }
    $selectedArticle = $null
    if ($override -and ($override.PSObject.Properties.Name -contains 'article')) {
        $articleName = [string]$override.article
        if ($articleName.EndsWith('.md')) {
            $articleName = [System.IO.Path]::GetFileNameWithoutExtension($articleName)
        }
        $candidate = Join-Path $knowledgeDirectory "$articleName.md"
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            $selectedArticle = Get-Item -LiteralPath $candidate
        } else {
            $problems.Add("${domain}: override article does not exist: $articleName.md") | Out-Null
        }
    } else {
        $selectedArticle = Get-ChildItem -LiteralPath $knowledgeDirectory -File -Filter '*.md' |
            Sort-Object Name |
            Where-Object {
                (Test-Path -LiteralPath (Join-Path $knowledgeDirectory "$($_.BaseName).good.al") -PathType Leaf) -and
                (Test-Path -LiteralPath (Join-Path $knowledgeDirectory "$($_.BaseName).bad.al") -PathType Leaf)
            } |
            Select-Object -First 1
    }
    if (-not $selectedArticle) {
        $problems.Add("${domain}: no article has both .good.al and .bad.al companion samples.") | Out-Null
        continue
    }

    $articlePath = "microsoft/knowledge/$domain/$($selectedArticle.Name)"
    $context = if ($override -and ($override.PSObject.Properties.Name -contains 'context')) {
        [string]$override.context
    } else {
        $null
    }
    foreach ($kind in 'bad', 'good') {
        $case = [pscustomobject]@{
            id = "$domain-$kind"
            domain = $domain
            input = "microsoft/knowledge/$domain/$($selectedArticle.BaseName).$kind.al"
            expected = if ($kind -eq 'bad') { @($articlePath) } else { @() }
        }
        if ($context) {
            $case | Add-Member -NotePropertyName context -NotePropertyValue $context
        }
        $caseList.Add($case) | Out-Null
    }
}
$cases = @($caseList)

$seenIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
foreach ($case in $cases) {
    $id = [string]$case.id
    $domain = [string]$case.domain
    $input = [string]$case.input
    $expected = @($case.expected)

    if ([string]::IsNullOrWhiteSpace($id)) {
        $problems.Add('Case with empty id.') | Out-Null
    } elseif (-not $seenIds.Add($id)) {
        $problems.Add("Duplicate case id: $id") | Out-Null
    }
    if ($leafDomains -notcontains $domain) {
        $problems.Add("${id}: domain '$domain' has no registered al-$domain-review leaf.") | Out-Null
    }

    $inputPath = Join-Path $Root $input
    if (-not (Test-Path -LiteralPath $inputPath -PathType Leaf)) {
        $problems.Add("${id}: input does not exist: $input") | Out-Null
    }
    if ($expected.Count -and $input -notmatch '\.bad\.[^.]+$') {
        $problems.Add("${id}: positive case must use a .bad sample: $input") | Out-Null
    }
    if (-not $expected.Count -and $input -notmatch '\.good\.[^.]+$') {
        $problems.Add("${id}: clean case must use a .good sample: $input") | Out-Null
    }

    foreach ($reference in $expected) {
        $referencePath = Join-Path $Root ([string]$reference)
        if (-not (Test-Path -LiteralPath $referencePath -PathType Leaf)) {
            $problems.Add("${id}: referenced article does not exist: $reference") | Out-Null
        }
    }
    if ($expected.Count) {
        $sampleSlug = ([System.IO.Path]::GetFileName($input) -replace '\.(?:good|bad)\.[^.]+$', '')
        $primarySlug = [System.IO.Path]::GetFileNameWithoutExtension([string]$expected[0])
        if ($sampleSlug -ne $primarySlug) {
            $problems.Add("${id}: primary expected article '$primarySlug' must match sample slug '$sampleSlug'.") | Out-Null
        }
    }
}

foreach ($domain in $leafDomains) {
    $domainCases = @($cases | Where-Object domain -eq $domain)
    if (-not @($domainCases | Where-Object { @($_.expected).Count -gt 0 }).Count) {
        $problems.Add("${domain}: no positive review fixture.") | Out-Null
    }
    if (-not @($domainCases | Where-Object { @($_.expected).Count -eq 0 }).Count) {
        $problems.Add("${domain}: no clean control fixture.") | Out-Null
    }
}

if ($problems.Count) {
    Write-Host "Review fixture validation FAILED ($($problems.Count) problem(s)):" -ForegroundColor Red
    $problems | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

if ($PrepareDirectory) {
    $markerPath = Join-Path $PrepareDirectory '.bcquality-evaluation'
    if (Test-Path -LiteralPath $PrepareDirectory) {
        $existing = @(Get-ChildItem -LiteralPath $PrepareDirectory -Force)
        if ($existing.Count -and -not (Test-Path -LiteralPath $markerPath -PathType Leaf)) {
            throw "PrepareDirectory is not empty and is not a BCQuality evaluation directory: $PrepareDirectory"
        }
        if (Test-Path -LiteralPath $markerPath -PathType Leaf) {
            Get-ChildItem -LiteralPath $PrepareDirectory -File |
                Where-Object {
                    ($_.Name -like 'case*.al') -or
                    ($_.Name -eq 'review-request.json') -or
                    ($_.Name -like 'request-*.json') -or
                    ($_.Name -eq 'knowledge-index.json') -or
                    ($_.Name -like 'index-*.json') -or
                    ($_.Name -like 'result-*.json')
                } |
                Remove-Item -Force
        }
    } else {
        New-Item -ItemType Directory -Force -Path $PrepareDirectory | Out-Null
    }
    Set-Content -LiteralPath $markerPath -Value 'BCQuality generated evaluation directory' -Encoding UTF8

    $fullIndexPath = Join-Path $PrepareDirectory 'knowledge-index.json'
    & (Join-Path $Root 'tools/Build-KnowledgeIndex.ps1') -BCQualityRoot $Root -IndexPath $fullIndexPath | Out-Null
    $fullIndex = Get-Content -LiteralPath $fullIndexPath -Raw | ConvertFrom-Json

    $requestCases = [System.Collections.Generic.List[object]]::new()
    $requestCasesByDomain = @{}
    $manifestCaseByModelId = @{}
    foreach ($case in $cases) {
        $extension = [System.IO.Path]::GetExtension([string]$case.input)
        $modelId = Get-ModelCaseId -ManifestId ([string]$case.id)
        $neutralName = "$modelId$extension"
        $sourceText = Get-Content -LiteralPath (Join-Path $Root ([string]$case.input)) -Raw
        # Companion samples are human-facing and often label objects/comments as
        # Good, Bad, or Anti-pattern. Strip full-line comments and neutralize those
        # object-name tokens so model-facing fixtures do not reveal the expected
        # outcome while preserving executable AL structure and references.
        $neutralText = [regex]::Replace($sourceText, '(?m)^\s*//.*(?:\r?\n|$)', '')
        $neutralText = [regex]::Replace($neutralText, '\b(?:Good|Bad)\b', 'Eval')
        Set-Content -LiteralPath (Join-Path $PrepareDirectory $neutralName) -Value $neutralText -Encoding UTF8
        $requestCase = [pscustomobject]@{ id = $modelId; file = $neutralName }
        if ($case.PSObject.Properties.Name -contains 'context') {
            $requestCase | Add-Member -NotePropertyName context -NotePropertyValue ([string]$case.context)
        }
        $requestCases.Add($requestCase) | Out-Null
        $manifestCaseByModelId[$modelId] = $case
        $domain = [string]$case.domain
        if (-not $requestCasesByDomain.ContainsKey($domain)) {
            $requestCasesByDomain[$domain] = [System.Collections.Generic.List[object]]::new()
        }
        $requestCasesByDomain[$domain].Add($requestCase) | Out-Null
    }
    $resultSchema = [pscustomobject]@{
        cases = @([pscustomobject]@{
            id = 'case-id'
            findings = @([pscustomobject]@{ id = 'repo-relative knowledge article path' })
        })
    }
    [pscustomobject]@{
        protocol = 'Run BCQuality al-code-review over all files as one PR; return findings per case. Copy every knowledge-backed id from knowledge-index.json.'
        knowledgeIndex = 'knowledge-index.json'
        resultSchema = $resultSchema
        cases = @($requestCases)
    } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $PrepareDirectory 'review-request.json') -Encoding UTF8

    foreach ($domain in $leafDomains) {
        $domainArticles = @($fullIndex.articles | Where-Object domain -eq $domain)
        $domainIndexName = "index-$domain.json"
        $leafPath = "microsoft/skills/review/al-$domain-review.md"
        $leafFullText = Get-Content -LiteralPath (Join-Path $Root $leafPath) -Raw
        $leafInstructions = @($leafFullText -split '(?m)^## Output\s*\r?\n', 2)[0]
        $leafInstructions += "`n## Output`nReturn only the request's resultSchema."
        [pscustomobject]@{
            version = $fullIndex.version
            domain = $domain
            articleCount = $domainArticles.Count
            articles = $domainArticles
        } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $PrepareDirectory $domainIndexName) -Encoding UTF8

        [pscustomobject]@{
            protocol = "Run only $leafPath over these files. Follow leafInstructions exactly, use only the supplied candidate article rows, open matching articles in full, and copy every finding id verbatim from candidateArticles[].path."
            skill = $leafPath
            leafInstructions = $leafInstructions
            knowledgeIndex = $domainIndexName
            candidateArticles = $domainArticles
            resultSchema = $resultSchema
            cases = @($requestCasesByDomain[$domain])
        } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $PrepareDirectory "request-$domain.json") -Encoding UTF8

        foreach ($requestCase in @($requestCasesByDomain[$domain])) {
            $caseText = Get-Content -LiteralPath (Join-Path $PrepareDirectory ([string]$requestCase.file)) -Raw
            if ($requestCase.PSObject.Properties.Name -contains 'context') {
                $caseText += " $([string]$requestCase.context)"
            }
            $rankedArticles = @(Get-RankedArticles -Articles $domainArticles -CaseText $caseText)
            $manifestCase = $manifestCaseByModelId[[string]$requestCase.id]
            $selectedArticlePath = ([string]$manifestCase.input) -replace '\.(?:good|bad)\.al$', '.md'
            $rankedPaths = @($rankedArticles | ForEach-Object { [string]$_.path })
            if ($rankedPaths -notcontains $selectedArticlePath) {
                throw "$($manifestCase.id): deterministic ranking omitted selected article '$selectedArticlePath'. Improve its retrieval metadata or choose an exceptional override article."
            }
            # Candidate order must not reveal which article owns the fixture.
            $rankedArticles = @($rankedArticles | Sort-Object path)
            [pscustomobject]@{
                protocol = "Run only $leafPath over this case. Follow leafInstructions exactly, evaluate the ranked candidate article rows, open matching articles in full, and copy every finding id verbatim from candidateArticles[].path."
                skill = $leafPath
                leafInstructions = $leafInstructions
                knowledgeIndex = $domainIndexName
                candidateArticles = $rankedArticles
                resultSchema = $resultSchema
                cases = @($requestCase)
            } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $PrepareDirectory "request-$($requestCase.id).json") -Encoding UTF8
        }
    }
    Write-Host "Prepared $($cases.Count) neutral fixture(s) in $PrepareDirectory." -ForegroundColor Green
}

if (-not $ResultsPath -and -not $ResultsDirectory) {
    Write-Host "Review fixture validation PASSED: $($cases.Count) cases cover $($leafDomains.Count) leaf domains." -ForegroundColor Green
    exit 0
}

$resultCases = [System.Collections.Generic.List[object]]::new()
if ($ResultsDirectory) {
    if (-not (Test-Path -LiteralPath $ResultsDirectory -PathType Container)) {
        throw "Results directory not found: $ResultsDirectory"
    }
    $resultFiles = @(Get-ChildItem -LiteralPath $ResultsDirectory -File -Filter 'result-case-*.json')
    if (-not $resultFiles.Count) {
        $resultFiles = @(Get-ChildItem -LiteralPath $ResultsDirectory -File -Filter 'result-*.json')
    }
    if (-not $resultFiles.Count) {
        throw "No result-case-*.json or result-*.json files found in: $ResultsDirectory"
    }
    foreach ($resultFile in $resultFiles) {
        try {
            $resultDocument = Get-Content -LiteralPath $resultFile.FullName -Raw | ConvertFrom-Json
        } catch {
            $problems.Add("$($resultFile.Name): invalid JSON: $($_.Exception.Message)") | Out-Null
            continue
        }
        if ($resultDocument.PSObject.Properties.Name -notcontains 'cases') {
            $problems.Add("$($resultFile.Name): result must contain a 'cases' array.") | Out-Null
            continue
        }
        foreach ($resultCase in @($resultDocument.cases)) {
            $resultCases.Add($resultCase) | Out-Null
        }
    }
} else {
    if (-not (Test-Path -LiteralPath $ResultsPath -PathType Leaf)) {
        throw "Results file not found: $ResultsPath"
    }
    $resultDocument = Get-Content -LiteralPath $ResultsPath -Raw | ConvertFrom-Json
    foreach ($resultCase in @($resultDocument.cases)) {
        $resultCases.Add($resultCase) | Out-Null
    }
}

$resultById = @{}
$modelToManifestId = @{}
foreach ($case in $cases) {
    $manifestId = [string]$case.id
    $modelToManifestId[(Get-ModelCaseId -ManifestId $manifestId)] = $manifestId
    # Also accept manifest IDs for maintainers generating local oracle results.
    $modelToManifestId[$manifestId] = $manifestId
}
foreach ($resultCase in @($resultCases)) {
    $rawResultId = [string]$resultCase.id
    if (-not $modelToManifestId.ContainsKey($rawResultId)) {
        $problems.Add("Results contain unknown case id: $rawResultId") | Out-Null
        continue
    }
    $resultId = $modelToManifestId[$rawResultId]
    if ($resultById.ContainsKey($resultId)) {
        $problems.Add("Results contain duplicate case id: $rawResultId") | Out-Null
    } else {
        $resultById[$resultId] = $resultCase
    }
}

$positiveTotal = 0
$positivePassed = 0
$cleanTotal = 0
$cleanPassed = 0
foreach ($case in $cases) {
    $id = [string]$case.id
    if (-not $resultById.ContainsKey($id)) {
        $problems.Add("Results missing case: $id") | Out-Null
        continue
    }

    $findingIds = @(
        @($resultById[$id].findings) | ForEach-Object {
            if ($_ -is [string]) { [string]$_ } else { [string]$_.id }
        } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique
    )
    $expected = @($case.expected | ForEach-Object { [string]$_ })

    if ($expected.Count) {
        $positiveTotal++
        $missing = @($expected | Where-Object { $findingIds -notcontains $_ })
        $unexpected = @($findingIds | Where-Object { $expected -notcontains $_ })
        if (-not $missing.Count -and -not $unexpected.Count) {
            $positivePassed++
        } else {
            if ($missing.Count) { $problems.Add("${id}: missing expected finding(s): $($missing -join ', ')") | Out-Null }
            if ($unexpected.Count) { $problems.Add("${id}: unexpected finding(s): $($unexpected -join ', ')") | Out-Null }
        }
    } else {
        $cleanTotal++
        if (-not $findingIds.Count) {
            $cleanPassed++
        } else {
            $problems.Add("${id}: clean control produced finding(s): $($findingIds -join ', ')") | Out-Null
        }
    }
}

$recall = if ($positiveTotal) { $positivePassed / $positiveTotal } else { 0 }
$cleanRate = if ($cleanTotal) { $cleanPassed / $cleanTotal } else { 0 }
if ($recall -lt [double]$manifest.minimumExpectedRecall) {
    $problems.Add("Expected-finding recall $recall is below $($manifest.minimumExpectedRecall).") | Out-Null
}
if ($cleanRate -lt [double]$manifest.minimumCleanRate) {
    $problems.Add("Clean-control rate $cleanRate is below $($manifest.minimumCleanRate).") | Out-Null
}

if ($problems.Count) {
    Write-Host "Review evaluation FAILED ($($problems.Count) problem(s)):" -ForegroundColor Red
    $problems | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "Review evaluation PASSED: recall=$recall ($positivePassed/$positiveTotal), clean-rate=$cleanRate ($cleanPassed/$cleanTotal)." -ForegroundColor Green
exit 0
