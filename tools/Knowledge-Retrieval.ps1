# Shared filesystem guards for catalog and exact article retrieval.
Set-StrictMode -Version Latest

function Resolve-KnowledgeRoot {
    param([string] $Root)

    $item = Get-Item -LiteralPath $Root -Force -ErrorAction Stop
    if ($item.PSProvider.Name -ne 'FileSystem' -or -not $item.PSIsContainer) {
        throw "BCQuality root must be a filesystem directory: $Root"
    }
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "Linked BCQuality roots are not supported: $Root"
    }
    return $item.FullName
}

function Assert-KnowledgePath {
    param(
        [string] $Path,
        [ValidateSet('article', 'sample')] [string] $Kind = 'article'
    )

    if ([string]::IsNullOrWhiteSpace($Path) -or
        $Path -cnotmatch '^(microsoft|community|custom)/knowledge/[^/]+/.+' -or
        $Path -match '[\\:*?"<>|\x00-\x1f]' -or
        @($Path.Split('/') | Where-Object { $_ -in '', '.', '..' -or $_ -match '[. ]$' }).Count) {
        throw "Invalid knowledge path: $Path"
    }
    if (($Kind -eq 'article' -and -not $Path.EndsWith('.md', [StringComparison]::Ordinal)) -or
        ($Kind -eq 'sample' -and $Path -cnotmatch '\.(good|bad)\.[a-z0-9]+$')) {
        throw "Expected an exact $Kind path: $Path"
    }
}

function Resolve-KnowledgePath {
    param(
        [string] $Root,
        [string] $Path,
        [ValidateSet('article', 'sample')] [string] $Kind = 'article'
    )

    Assert-KnowledgePath -Path $Path -Kind $Kind
    $current = $Root
    foreach ($part in $Path.Split('/')) {
        $items = @(
            Get-ChildItem -LiteralPath $current -Filter $part -Force -ErrorAction Stop |
                Where-Object Name -CEQ $part
        )
        if ($items.Count -ne 1) {
            throw "Knowledge path does not exist with exact casing: $Path"
        }
        $item = $items[0]
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "Linked knowledge paths are not supported: $Path"
        }
        $current = $item.FullName
    }
    if ($item.PSIsContainer) {
        throw "Knowledge path is not a file: $Path"
    }
    return $item.FullName
}

function Read-KnowledgeText {
    param([string] $Path)

    $bytes = [IO.File]::ReadAllBytes($Path)
    try {
        $text = [Text.UTF8Encoding]::new($false, $true).GetString($bytes)
    }
    catch {
        throw "Knowledge file is not valid strict UTF-8: $Path"
    }
    return [pscustomobject]@{
        text = $text
        bytes = $bytes.Length
        sha256 = [Convert]::ToHexString(
            [Security.Cryptography.SHA256]::HashData($bytes)
        ).ToLowerInvariant()
    }
}

function Get-NormalizedKnowledgeVersions {
    param([string[]] $Values)

    foreach ($value in $Values) {
        if ($value -match '^"([^"]*)"$' -or $value -match "^'([^']*)'$") {
            $Matches[1]
        }
        else {
            $value
        }
    }
}

function Get-KnowledgeMetadataProblem {
    param([Collections.IDictionary] $Row)

    if ($Row['parsed'] -isnot [bool] -or -not $Row['parsed']) {
        return 'unparsed frontmatter'
    }
    if ($Row['domain'] -isnot [string] -or
        $Row['domain'] -cnotmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
        return 'missing/invalid domain'
    }
    foreach ($field in @('bc-version', 'technologies', 'countries', 'application-area', 'keywords')) {
        if ($Row[$field] -isnot [array] -or -not $Row[$field].Count) {
            return "missing/invalid $field"
        }
        foreach ($value in $Row[$field]) {
            if ($value -isnot [string] -or [string]::IsNullOrWhiteSpace($value)) {
                return "invalid $field value"
            }
        }
    }
    foreach ($field in @('title', 'description')) {
        if ($Row[$field] -isnot [string] -or
            [string]::IsNullOrWhiteSpace($Row[$field]) -or
            $Row[$field] -match '[\r\n]') {
            return "missing/invalid $field"
        }
    }

    $versions = @(Get-NormalizedKnowledgeVersions -Values $Row['bc-version'])
    if ($versions -ccontains 'all') {
        if ($versions.Count -ne 1) {
            return 'mixed bc-version sentinel'
        }
    }
    elseif ($versions.Count -eq 1 -and $versions[0] -match '^(\d+)\.\.(\d+)?$') {
        $start = [bigint]::Parse($Matches[1])
        if ($start -le 0 -or ($Matches[2] -and [bigint]::Parse($Matches[2]) -le 0)) {
            return 'invalid bc-version range bound'
        }
        if ($Matches[2] -and $start -gt [bigint]::Parse($Matches[2])) {
            return 'descending bc-version range'
        }
    }
    else {
        foreach ($version in $versions) {
            if ($version -notmatch '^\d+$' -or [bigint]::Parse($version) -le 0) {
                return 'invalid bc-version'
            }
        }
    }
    if (@($Row.technologies | Where-Object { $_ -cnotmatch '^[a-z0-9]+(-[a-z0-9]+)*$' }).Count) {
        return 'invalid technologies'
    }
    if ($Row.technologies -ccontains 'all') {
        return 'invalid technologies sentinel'
    }
    if ($Row.countries -ccontains 'w1') {
        if ($Row.countries.Count -ne 1) {
            return 'mixed countries sentinel'
        }
    }
    elseif (@($Row.countries | Where-Object { $_ -cnotmatch '^[a-z]{2}$' }).Count) {
        return 'invalid countries'
    }
    if (@($Row['application-area'] | Where-Object { $_ -cnotmatch '^(all|[a-z0-9]+(-[a-z0-9]+)*)$' }).Count) {
        return 'invalid application-area'
    }
    if ($Row['application-area'] -ccontains 'all' -and $Row['application-area'].Count -ne 1) {
        return 'mixed application-area sentinel'
    }
    if (@($Row.keywords | Where-Object { $_ -cnotmatch '^[a-z0-9]+(-[a-z0-9]+)*$' }).Count) {
        return 'invalid keywords'
    }
    return ''
}

function Get-PreparedManifestSha256 {
    param(
        [string[]] $Paths,
        [Collections.Generic.Dictionary[string, object]] $ByPath
    )

    $hash = [Security.Cryptography.IncrementalHash]::CreateHash(
        [Security.Cryptography.HashAlgorithmName]::SHA256
    )
    try {
        $hash.AppendData([byte[]][char]'[')
        for ($i = 0; $i -lt $Paths.Count; $i++) {
            if ($i) {
                $hash.AppendData([byte[]][char]',')
            }
            $row = [ordered]@{
                path = $Paths[$i]
                sha256 = $ByPath[$Paths[$i]].sourceSha256
            }
            $hash.AppendData([Text.Encoding]::UTF8.GetBytes(
                (ConvertTo-Json -InputObject $row -Depth 8 -Compress)
            ))
        }
        $hash.AppendData([byte[]][char]']')
        return [Convert]::ToHexString($hash.GetHashAndReset()).ToLowerInvariant()
    }
    finally {
        $hash.Dispose()
    }
}

function Read-PreparedKnowledgeIndex {
    param(
        [string] $IndexPath,
        [string] $Recovery
    )

    if (-not (Test-Path -LiteralPath $IndexPath -PathType Leaf)) {
        throw "Knowledge index missing: $IndexPath. $Recovery"
    }
    $indexItem = Get-Item -LiteralPath $IndexPath -Force -ErrorAction Stop
    if ($indexItem.PSProvider.Name -ne 'FileSystem' -or
        ($indexItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw "Knowledge index must be an unlinked filesystem file: $IndexPath. $Recovery"
    }

    $content = Read-KnowledgeText -Path $indexItem.FullName
    try {
        $index = $content.text.TrimStart([char]0xfeff) |
            ConvertFrom-Json -AsHashtable -ErrorAction Stop
    }
    catch {
        throw "Malformed knowledge index JSON: $($_.Exception.Message). $Recovery"
    }
    if ($index -isnot [Collections.IDictionary] -or
        $index.version -ne 1 -or
        $index.articles -isnot [array] -or
        $index.articleCount -ne $index.articles.Count -or
        $index.enabledLayers -isnot [array] -or
        $index.knowledgeAllow -isnot [array] -or
        $index.knowledgeDeny -isnot [array] -or
        $index.sourceSnapshot -isnot [string] -or
        $index.sourceSnapshot -cnotmatch '^[a-f0-9]{64}$') {
        throw "Invalid knowledge index envelope. $Recovery"
    }

    $generatedAt = [DateTimeOffset]::MinValue
    if ($index.generatedAt -is [DateTime]) {
        $generatedAt = [DateTimeOffset]$index.generatedAt
    }
    elseif (-not [DateTimeOffset]::TryParse(
        [string]$index.generatedAt,
        [Globalization.CultureInfo]::InvariantCulture,
        [Globalization.DateTimeStyles]::RoundtripKind,
        [ref]$generatedAt
    )) {
        throw "Invalid knowledge index generatedAt. $Recovery"
    }
    if ($generatedAt -gt [DateTimeOffset]::UtcNow.AddMinutes(1)) {
        throw "Invalid knowledge index generatedAt. $Recovery"
    }

    $byPath = [Collections.Generic.Dictionary[string, object]]::new([StringComparer]::Ordinal)
    foreach ($row in $index.articles) {
        if ($row -isnot [Collections.IDictionary] -or $row.path -isnot [string]) {
            throw "Index row has no exact path. $Recovery"
        }
        Assert-KnowledgePath -Path $row.path
        if ($row.layer -cne $row.path.Split('/')[0] -or
            $row.layer -cnotin @('microsoft', 'community', 'custom')) {
            throw "Invalid index layer: $($row.path). $Recovery"
        }
        if ($row.sourceSha256 -isnot [string] -or
            $row.sourceSha256 -cnotmatch '^[a-f0-9]{64}$') {
            throw "Invalid source hash in knowledge index: $($row.path). $Recovery"
        }
        if (-not $byPath.TryAdd($row.path, $row)) {
            throw "Duplicate index path: $($row.path). $Recovery"
        }
    }

    $paths = [string[]]@($byPath.Keys)
    [Array]::Sort($paths, [StringComparer]::Ordinal)
    if ((Get-PreparedManifestSha256 -Paths $paths -ByPath $byPath) -cne $index.sourceSnapshot) {
        throw "Stale or internally inconsistent prepared index snapshot. $Recovery"
    }

    return [pscustomobject]@{
        index = $index
        content = $content
        byPath = $byPath
        paths = $paths
    }
}

function Assert-SampleLink {
    param(
        [string] $ArticleText,
        [string] $SamplePath
    )

    $sampleName = [IO.Path]::GetFileName($SamplePath)
    $expected = '[`' + $sampleName + '`](' + $sampleName + ')'
    if (-not $ArticleText.Contains($expected, [StringComparison]::Ordinal)) {
        throw "Sample is not linked by its article using the READ convention: $sampleName"
    }
}
