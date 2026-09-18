<#
.SYNOPSIS
    Reads a bounded prefix of exact article or sample paths without altering bodies.
.DESCRIPTION
    The UTF-8 byte size bound covers the complete serialized JSON plus its output
    newline. A body that cannot fit fails explicitly; it is never summarized or
    truncated. Samples are loaded only with -Samples and must be linked by their
    sibling article using READ's exact link convention.
#>
#requires -Version 7.2
[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()] [string] $BCQualityRoot = (Split-Path $PSScriptRoot -Parent),
    [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [string[]] $Paths,
    [ValidateRange(1, 8)] [int] $MaxArticles = 8,
    [ValidateRange(1024, 16000)] [int] $MaxBytes = 16000,
    [ValidateSet('microsoft', 'community', 'custom')]
    [AllowEmptyCollection()] [string[]] $EnabledLayers = @('microsoft', 'community', 'custom'),
    [string] $IndexPath,
    [ValidatePattern('^[a-f0-9]{64}$')] [string] $Snapshot,
    [switch] $Samples
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Knowledge-Retrieval.ps1')
. (Join-Path $PSScriptRoot 'Bounded-Results.ps1')

$BCQualityRoot = Resolve-KnowledgeRoot $BCQualityRoot
if (-not $IndexPath) {
    $IndexPath = Join-Path $BCQualityRoot 'knowledge-index.json'
}
if ($Paths.Count -gt $MaxArticles) {
    throw "Paths count $($Paths.Count) exceeds MaxArticles=$MaxArticles. Split the worklist into stable chunks of at most $MaxArticles exact paths."
}
if ($null -eq $EnabledLayers) {
    throw 'EnabledLayers must be an array.'
}
if (@($EnabledLayers | Where-Object { $_ -cnotin @('microsoft', 'community', 'custom') }).Count -or
    @($EnabledLayers | Group-Object -CaseSensitive | Where-Object Count -gt 1).Count) {
    throw 'EnabledLayers must contain unique canonical lowercase layer names.'
}

$recovery = "Run Entry preparation once before dispatch, or use READ's bounded native-file fallback. Do not rebuild in a leaf."
$preparedIndex = Read-PreparedKnowledgeIndex -IndexPath $IndexPath -Recovery $recovery
$index = $preparedIndex.index
$byPath = $preparedIndex.byPath
$unrestricted = $index.enabledLayers.Count -eq 0 -or
    ($index.enabledLayers.Count -eq 1 -and $null -eq $index.enabledLayers[0])
$indexedLayers = @(
    if ($unrestricted) { 'microsoft', 'community', 'custom' } else { $index.enabledLayers }
)
if (@($EnabledLayers | Where-Object { $_ -cnotin $indexedLayers }).Count) {
    throw "Index layer coverage does not cover EnabledLayers. $recovery"
}

$resolved = [Collections.Generic.List[string]]::new()
$records = [Collections.Generic.List[object]]::new()
$seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
$articleTexts = [Collections.Generic.Dictionary[string, string]]::new([StringComparer]::Ordinal)
$sampleContents = [Collections.Generic.Dictionary[string, object]]::new([StringComparer]::Ordinal)
foreach ($path in $Paths) {
    $kind = if ($Samples) { 'sample' } else { 'article' }
    $fullPath = Resolve-KnowledgePath -Root $BCQualityRoot -Path $path -Kind $kind
    if ($path.Split('/')[0] -cnotin $EnabledLayers) {
        throw "Layer disabled for path: $path"
    }
    if (-not $seen.Add($path)) {
        throw "Duplicate requested path: $path"
    }
    if ($Samples) {
        $articlePath = $path -replace '\.(good|bad)\.[a-z0-9]+$', '.md'
        if (-not $byPath.ContainsKey($articlePath)) {
            throw "Sample article is absent from the prepared index: $articlePath"
        }
        $fullArticlePath = Resolve-KnowledgePath -Root $BCQualityRoot -Path $articlePath
        if (-not $articleTexts.ContainsKey($articlePath)) {
            $articleContent = Read-KnowledgeText -Path $fullArticlePath
            if ($articleContent.sha256 -cne $byPath[$articlePath].sourceSha256) {
                throw "Selected article hash does not match the prepared index: $articlePath"
            }
            $articleTexts.Add($articlePath, $articleContent.text)
        }
        Assert-SampleLink -ArticleText $articleTexts[$articlePath] -SamplePath $fullPath
        $sampleContent = Read-KnowledgeText -Path $fullPath
        $sampleContents.Add($path, $sampleContent)
        $records.Add([ordered]@{
            path = $path
            articlePath = $articlePath
            articleSha256 = $byPath[$articlePath].sourceSha256
            sampleSha256 = $sampleContent.sha256
            sampleBytes = $sampleContent.bytes
        })
    }
    else {
        if (-not $byPath.ContainsKey($path)) {
            throw "Selected article is absent from the prepared index: $path"
        }
        $records.Add([ordered]@{
            path = $path
            expectedSha256 = $byPath[$path].sourceSha256
        })
    }
    $resolved.Add($fullPath)
}

$requestSnapshot = Get-ResultSnapshot -Value ([ordered]@{
    root = $BCQualityRoot
    preparedIndexSha256 = $preparedIndex.content.sha256
    kind = if ($Samples) { 'samples' } else { 'articles' }
    enabledLayers = @($EnabledLayers)
    files = @($records)
})
if ($Snapshot -and $Snapshot -cne $requestSnapshot) {
    throw 'Article snapshot changed or continuation belongs to another exact path batch. Discard partial results and restart.'
}

$articles = [Collections.Generic.List[object]]::new()
function ConvertTo-BatchJson {
    param([int] $ReadCount)

    $remaining = @(
        if ($ReadCount -lt $Paths.Count) {
            $Paths[$ReadCount..($Paths.Count - 1)]
        }
    )
    $remainingRecords = @(
        if ($ReadCount -lt $records.Count) {
            $records[$ReadCount..($records.Count - 1)]
        }
    )
    $continuation = if ($remaining.Count) {
        [ordered]@{
            snapshot = Get-ResultSnapshot -Value ([ordered]@{
                root = $BCQualityRoot
                preparedIndexSha256 = $preparedIndex.content.sha256
                kind = if ($Samples) { 'samples' } else { 'articles' }
                enabledLayers = @($EnabledLayers)
                files = $remainingRecords
            })
        }
    }
    else {
        $null
    }
    return [ordered]@{
        version = 1
        kind = if ($Samples) { 'samples' } else { 'articles' }
        snapshot = $requestSnapshot
        requestedCount = $Paths.Count
        returnedCount = $ReadCount
        complete = ($ReadCount -eq $Paths.Count)
        articles = @($articles)
        remainingPaths = $remaining
        continuation = $continuation
    } | ConvertTo-Json -Depth 8 -Compress
}

$json = ''
for ($i = 0; $i -lt [Math]::Min($MaxArticles, $Paths.Count); $i++) {
    $content = if ($Samples) {
        $sampleContents[$Paths[$i]]
    }
    else {
        Read-KnowledgeText -Path $resolved[$i]
    }
    if (-not $Samples -and $content.sha256 -cne $records[$i].expectedSha256) {
        throw "Selected article hash does not match the prepared index: $($Paths[$i])"
    }
    $articles.Add([ordered]@{
        path = $Paths[$i]
        bytes = $content.bytes
        sha256 = $content.sha256
        body = $content.text
    })
    $next = ConvertTo-BatchJson -ReadCount ($i + 1)
    if ((Get-SerializedByteCount -Json $next) -gt $MaxBytes) {
        $articles.RemoveAt($articles.Count - 1)
        if ($i -eq 0) {
            throw "No complete body plus continuation fits MaxBytes=$MaxBytes at $($Paths[$i]). Use a smaller exact path batch or READ's bounded native-file fallback; never truncate."
        }
        break
    }
    $json = $next
}

$json
