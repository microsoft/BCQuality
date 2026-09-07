# Helpers for Test-DevelopmentGuidanceFixtures.ps1 and its deterministic regressions.
function Get-GuidanceDiagnostic {
    param($ErrorRecord)
    if ($ErrorRecord.Exception -is [Management.Automation.RuntimeException] -and
        $ErrorRecord.FullyQualifiedErrorId -eq $ErrorRecord.Exception.Message) {
        return $ErrorRecord.Exception.Message
    }
    return 'Evidence or report could not be read safely (missing, malformed, inaccessible or unsupported state).'
}

function Assert-GuidanceObject {
    param($Value, [string] $Label, [string[]] $Fields = @())
    if ($Value -isnot [Collections.IDictionary]) { throw "$Label must be a JSON object." }
    foreach ($field in $Fields) {
        if (-not $Value.Contains($field)) { throw "$Label is missing required field '$field'." }
    }
}

function Assert-GuidanceString {
    param($Value, [string] $Label)
    if ($Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) { throw "$Label must be a non-empty string." }
}

function Assert-GuidanceArray {
    param($Value, [string] $Label, [switch] $Strings, [switch] $NonEmpty)
    if ($Value -isnot [array]) { throw "$Label must be a JSON array." }
    if ($NonEmpty -and $Value.Count -eq 0) { throw "$Label must not be empty." }
    if ($Strings) { foreach ($item in $Value) { Assert-GuidanceString $item "$Label entry" } }
}

function Assert-GuidanceInteger {
    param($Value, [string] $Label)
    if (($Value -isnot [long] -and $Value -isnot [int] -and $Value -isnot [bigint]) -or $Value -lt 0) {
        throw "$Label must be a non-negative integer."
    }
}

function Read-GuidanceJson {
    param([string] $Path)
    function Assert-JsonMembers($Element) {
        if ($Element.ValueKind -eq [Text.Json.JsonValueKind]::Object) {
            $names = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
            foreach ($property in $Element.EnumerateObject()) {
                if (-not $names.Add($property.Name)) { throw 'JSON contains duplicate or case-ambiguous members.' }
                Assert-JsonMembers $property.Value
            }
        } elseif ($Element.ValueKind -eq [Text.Json.JsonValueKind]::Array) {
            foreach ($item in $Element.EnumerateArray()) { Assert-JsonMembers $item }
        }
    }
    try {
        if ((Get-Item -LiteralPath $Path -Force).Length -gt 32MB) { throw 'Oversized JSON.' }
        $text = [IO.File]::ReadAllText($Path)
        $document = [Text.Json.JsonDocument]::Parse($text)
        try { Assert-JsonMembers $document.RootElement } finally { $document.Dispose() }
        return ConvertFrom-Json -InputObject $text -AsHashtable -Depth 64 -NoEnumerate
    } catch { throw 'Input is not readable, strict JSON with unique members.' }
}

function Get-GuidanceHash {
    param([string] $Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Get-GuidanceCaseId {
    param([string] $Id)
    $bytes = [Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($Id))
    return "case-$([Convert]::ToHexString($bytes).Substring(0, 8).ToLowerInvariant())"
}

function Test-GuidanceWithin {
    param([string] $Path, [string] $Parent)
    $comparison = if ($IsWindows) { [StringComparison]::OrdinalIgnoreCase } else { [StringComparison]::Ordinal }
    $prefix = $Parent.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    return $Path.Equals($Parent, $comparison) -or $Path.StartsWith($prefix, $comparison)
}

function Assert-GuidanceItem {
    param($Item)
    if (($Item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or $Item.LinkType -or $Item.LinkTarget) {
        throw 'Links, junctions, hard links and reparse points are not supported.'
    }
    if (-not $Item.PSIsContainer -and $IsWindows) {
        $streams = @(Get-Item -LiteralPath $Item.FullName -Stream '*' -Force -ErrorAction Stop)
        if (@($streams | Where-Object Stream -ne ':$DATA').Count) {
            throw 'Alternate data streams are not supported.'
        }
    }
}

function Get-GuidanceSafePath {
    param([string] $Path, [switch] $AllowMissing, [switch] $Directory, [switch] $File)
    Assert-GuidanceString $Path 'Filesystem path'
    $full = [IO.Path]::GetFullPath($Path)
    $driveRoot = [IO.Path]::GetPathRoot($full)
    if ($IsWindows -and ($driveRoot.StartsWith('\\') -or $full.Substring($driveRoot.Length).Contains(':'))) {
        throw 'Network paths and alternate stream paths are not supported.'
    }
    $cursor = $driveRoot
    $components = $full.Substring($driveRoot.Length).Split([IO.Path]::DirectorySeparatorChar, [StringSplitOptions]::RemoveEmptyEntries)
    foreach ($component in $components) {
        if ($component -match '[\. ]$') { throw 'Ambiguous filesystem path components are not supported.' }
        $cursor = Join-Path $cursor $component
        # Get-Item sees dangling links that Test-Path may treat as missing.
        $item = Get-Item -LiteralPath $cursor -Force -ErrorAction SilentlyContinue
        if ($null -ne $item) { Assert-GuidanceItem $item }
        elseif (-not $AllowMissing) { throw 'Required filesystem path is missing.' }
    }
    if ($Directory -and -not (Test-Path -LiteralPath $full -PathType Container)) { throw 'Required directory is missing.' }
    if ($File -and -not (Test-Path -LiteralPath $full -PathType Leaf)) { throw 'Required file is missing.' }
    return $full.TrimEnd([IO.Path]::DirectorySeparatorChar)
}

function Assert-GuidanceTree {
    param([string] $Root)
    $pending = [Collections.Generic.Stack[string]]::new()
    $pending.Push($Root)
    while ($pending.Count) {
        foreach ($item in Get-ChildItem -LiteralPath $pending.Pop() -Force) {
            Assert-GuidanceItem $item
            if ($item.PSIsContainer) { $pending.Push($item.FullName) }
        }
    }
}

function Invoke-GuidanceGit {
    param([string] $Root, [string[]] $Arguments, [switch] $RawOutput)
    $start = [Diagnostics.ProcessStartInfo]::new('git')
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    foreach ($variable in @('GIT_DIR', 'GIT_WORK_TREE', 'GIT_COMMON_DIR', 'GIT_INDEX_FILE',
            'GIT_OBJECT_DIRECTORY', 'GIT_ALTERNATE_OBJECT_DIRECTORIES', 'GIT_CONFIG',
            'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS', 'GIT_NAMESPACE')) {
        $null = $start.Environment.Remove($variable)
    }
    $start.Environment['GIT_CONFIG_NOSYSTEM'] = '1'
    $start.Environment['GIT_CONFIG_GLOBAL'] = ''
    $start.Environment['GIT_TERMINAL_PROMPT'] = '0'
    # In particular, do not execute a repository-supplied fsmonitor hook on reads.
    foreach ($argument in (@('--no-optional-locks', '-c', 'core.fsmonitor=false', '-C', $Root) + $Arguments)) {
        $start.ArgumentList.Add($argument)
    }
    $process = [Diagnostics.Process]::Start($start)
    try {
        $output = $process.StandardOutput.ReadToEndAsync()
        $errors = $process.StandardError.ReadToEndAsync()
        $process.WaitForExit()
        $null = $errors.GetAwaiter().GetResult()
        if ($process.ExitCode -ne 0) { throw 'Git evidence could not be read.' }
        $text = $output.GetAwaiter().GetResult()
        if ($RawOutput) { return $text }
        return $text.TrimEnd("`r", "`n")
    } finally { $process.Dispose() }
}

function Get-GuidanceSnapshot {
    param([string] $Root, [switch] $Target)
    $Root = Get-GuidanceSafePath $Root -Directory
    $dotGit = Get-GuidanceSafePath (Join-Path $Root '.git')
    if (Test-Path -LiteralPath $dotGit -PathType Container) {
        $gitDir = $dotGit
    } else {
        if ($Target) { throw 'Target workspaces must be standalone repositories with internal Git storage.' }
        $pointer = [IO.File]::ReadAllText($dotGit)
        if ($pointer -notmatch '\Agitdir: ([^\r\n]+)\r?\n?\z') { throw 'Unsupported Git worktree pointer.' }
        $gitPath = $Matches[1]
        if (-not [IO.Path]::IsPathFullyQualified($gitPath)) { $gitPath = Join-Path $Root $gitPath }
        $gitDir = Get-GuidanceSafePath $gitPath -Directory
    }
    $commonDir = $gitDir
    $commonPointer = Get-GuidanceSafePath (Join-Path $gitDir 'commondir') -AllowMissing
    if (Test-Path -LiteralPath $commonPointer) {
        $commonPath = [IO.File]::ReadAllText($commonPointer).Trim()
        if (-not [IO.Path]::IsPathFullyQualified($commonPath)) { $commonPath = Join-Path $gitDir $commonPath }
        $commonDir = Get-GuidanceSafePath $commonPath -Directory
    }
    if ($Target -and ($gitDir -cne (Join-Path $Root '.git') -or $commonDir -cne $gitDir)) {
        throw 'Target workspaces must be standalone repositories with internal Git storage.'
    }
    $files = [Collections.Generic.List[object]]::new()
    $pending = [Collections.Generic.Stack[string]]::new()
    $pending.Push($Root)
    while ($pending.Count) {
        foreach ($item in @(Get-ChildItem -LiteralPath $pending.Pop() -Force | Sort-Object Name -CaseSensitive)) {
            Assert-GuidanceItem $item
            $relative = [IO.Path]::GetRelativePath($Root, $item.FullName).Replace('\', '/')
            $entry = [ordered]@{
                path = $relative
                kind = if ($item.PSIsContainer) { 'directory' } else { 'file' }
                attributes = [int]$item.Attributes
                unixMode = [int]$item.UnixFileMode
                creationUtcTicks = $item.CreationTimeUtc.Ticks
            }
            if ($item.PSIsContainer) {
                $pending.Push($item.FullName)
            } else {
                $entry.length = $item.Length
                $entry.lastWriteUtcTicks = $item.LastWriteTimeUtc.Ticks
                $entry.sha256 = Get-GuidanceHash $item.FullName
            }
            $files.Add($entry)
        }
    }
    # Linked knowledge worktrees have explicitly identified Git metadata outside
    # the content root. Record its meaningful configuration as well as HEAD/refs.
    $gitMetadata = [ordered]@{}
    foreach ($storage in @($gitDir, $commonDir) | Sort-Object -Unique) {
        foreach ($name in @('HEAD', 'commondir', 'config', 'config.worktree', 'packed-refs', 'refs', 'objects', 'index', 'info\exclude', 'shallow')) {
            $path = Get-GuidanceSafePath (Join-Path $storage $name) -AllowMissing
            if ((Test-Path -LiteralPath $path -PathType Container) -and -not (Test-GuidanceWithin $path $Root)) {
                Assert-GuidanceTree $path
            }
            if (Test-Path -LiteralPath $path -PathType Leaf) {
                $gitMetadata[$path] = Get-GuidanceHash $path
            }
            if ($name -in @('config', 'config.worktree') -and (Test-Path -LiteralPath $path) -and
                [IO.File]::ReadAllText($path) -match '(?im)^\s*\[include(?:If)?\b') {
                throw 'External Git configuration includes are not supported.'
            }
        }
        foreach ($name in @('objects\info\alternates', 'objects\info\http-alternates')) {
            if (Test-Path -LiteralPath (Join-Path $storage $name)) { throw 'External Git object stores are not supported.' }
        }
    }
    $top = Get-GuidanceSafePath (Invoke-GuidanceGit $Root @('rev-parse', '--show-toplevel')) -Directory
    if ($top -cne $Root) { throw 'Evidence requires the exact Git worktree root, not a subdirectory.' }
    $indexPath = Get-GuidanceSafePath (Join-Path $gitDir 'index') -AllowMissing
    $tracked = Invoke-GuidanceGit $Root @('ls-files', '--stage')
    if ($tracked -match '(?m)^160000 ') { throw 'Submodule workspaces are not supported.' }
    if ((Invoke-GuidanceGit $Root @('ls-files', '-t')) -match '(?m)^S ') { throw 'Sparse workspaces are not supported.' }
    $head = Invoke-GuidanceGit $Root @('rev-parse', '--verify', 'HEAD')
    $headFile = Get-GuidanceSafePath (Join-Path $gitDir 'HEAD') -File
    # Access times, Git status refreshes, and index-builder generatedAt are not evidence.
    return [ordered]@{
        version = 1
        root = $Root
        rootCreationUtcTicks = (Get-Item -LiteralPath $Root -Force).CreationTimeUtc.Ticks
        gitDir = $gitDir
        commonDir = $commonDir
        gitMetadata = $gitMetadata
        head = $head
        headFileSha256 = Get-GuidanceHash $headFile
        references = Invoke-GuidanceGit $Root @('for-each-ref', '--format=%(refname) %(objectname) %(symref)')
        indexPath = $indexPath
        indexSha256 = if (Test-Path -LiteralPath $indexPath) { Get-GuidanceHash $indexPath } else { $null }
        files = @($files | Sort-Object { $_.path } -CaseSensitive)
    }
}

function Test-GuidanceSnapshotEqual {
    param($Before, $After)
    return ($Before | ConvertTo-Json -Depth 64 -Compress) -ceq ($After | ConvertTo-Json -Depth 64 -Compress)
}

function Write-GuidanceNewJson {
    param([string] $Path, $Value)
    $parent = Split-Path -Parent $Path
    [IO.Directory]::CreateDirectory($parent) | Out-Null
    $bytes = [Text.Encoding]::UTF8.GetBytes(($Value | ConvertTo-Json -Depth 64))
    $stream = [IO.File]::Open($Path, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try { $stream.Write($bytes, 0, $bytes.Length) } finally { $stream.Dispose() }
}

function Resolve-GuidanceReference {
    param([string] $Root, $Reference, [switch] $Knowledge, [string] $Article)
    Assert-GuidanceString $Reference 'Reference path'
    if ($Reference -cnotmatch '^[a-zA-Z0-9_-]+(?:/[a-zA-Z0-9_.-]+)+$' -or
        @($Reference.Split('/') | Where-Object { $_ -in @('.', '..') -or $_ -match '[\. ]$' }).Count) {
        throw 'Reference must be an unambiguous forward-slash repository-relative path without traversal.'
    }
    if ($Knowledge -and $Reference -cnotmatch '^(microsoft|community|custom)/knowledge/[a-z0-9-]+/(?:[a-z0-9-]+/)*[a-z0-9-]+\.md$') {
        throw 'Knowledge references must identify actual layered knowledge articles.'
    }
    if ($Article) {
        $stem = $Article.Substring(0, $Article.Length - 3)
        if ($Reference -cnotmatch ('^' + [regex]::Escape($stem) + '\.(good|bad)\.[a-zA-Z0-9]+$')) {
            throw 'Sample references must be good/bad siblings of their knowledge article.'
        }
    }
    $cursor = $Root
    foreach ($component in $Reference.Split('/')) {
        $cursor = Join-Path $cursor $component
        $cursor = Get-GuidanceSafePath $cursor
        if ((Get-Item -LiteralPath $cursor -Force).Name -cne $component) { throw 'Reference path casing must match the actual file.' }
    }
    if (-not (Test-GuidanceWithin $cursor $Root) -or -not (Test-Path -LiteralPath $cursor -PathType Leaf)) {
        throw 'Reference must resolve to an existing file inside the knowledge checkout.'
    }
    if ($Knowledge) {
        $text = [IO.File]::ReadAllText($cursor)
        if ($text -notmatch '(?s)^---\r?\n.*?\r?\n---' -or
            $text -notmatch '(?m)^domain:\s*\S+' -or $text -notmatch '(?m)^## (Best Practice|Anti Pattern)\s*$') {
            throw 'Knowledge reference does not contain a normative knowledge article.'
        }
    }
    return $cursor
}

function Get-GuidancePlanRequest {
    param($Plan)
    if ($Plan -is [string]) { Assert-GuidanceString $Plan 'development-plan'; return $Plan }
    Assert-GuidanceObject $Plan 'development-plan' @('request')
    Assert-GuidanceString $Plan.request 'development-plan.request'
    return $Plan.request
}

function Assert-GuidanceContext {
    param($Context)
    Assert-GuidanceObject $Context 'context' @('bc-version', 'technologies', 'countries', 'application-area', 'unknown')
    Assert-GuidanceString $Context.'bc-version' 'context.bc-version'
    foreach ($key in @('technologies', 'countries', 'application-area', 'unknown')) {
        Assert-GuidanceArray $Context[$key] "context.$key" -Strings
        if (@($Context[$key] | Sort-Object -Unique).Count -ne $Context[$key].Count) { throw "context.$key contains duplicates." }
    }
    foreach ($key in $Context.unknown) {
        if ($key -cnotin @('bc-version', 'technologies', 'countries', 'application-area')) { throw 'context.unknown contains an invalid dimension.' }
    }
    if ($Context.'bc-version' -eq 'unknown' -and 'bc-version' -cnotin $Context.unknown) {
        throw 'Unknown BC version must be recorded in context.unknown.'
    }
    foreach ($key in @('technologies', 'countries', 'application-area')) {
        if ((-not $Context[$key].Count -or 'unknown' -in $Context[$key]) -and $key -cnotin $Context.unknown) {
            throw 'Unavailable applicability dimensions must be recorded in context.unknown.'
        }
    }
}

function Assert-GuidanceManifest {
    param($Manifest, [string] $Root)
    Assert-GuidanceObject $Manifest 'manifest' @('version', 'minimumKnowledgeRecall', 'minimumKnowledgePrecision', 'skill', 'cases')
    if ($Manifest.version -ne 1) { throw 'Unsupported guidance fixture manifest version.' }
    foreach ($name in @('minimumKnowledgeRecall', 'minimumKnowledgePrecision')) {
        $value = $Manifest[$name]
        if (($value -isnot [double] -and $value -isnot [long] -and $value -isnot [int] -and $value -isnot [decimal]) -or
            $value -lt 0 -or $value -gt 1) { throw 'Manifest thresholds must be numbers between zero and one.' }
    }
    $null = Resolve-GuidanceReference $Root $Manifest.skill
    Assert-GuidanceArray $Manifest.cases 'manifest.cases' -NonEmpty
    $ids = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $modelIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($case in $Manifest.cases) {
        Assert-GuidanceObject $case 'manifest case' @('id', 'expectedKind', 'expectedOutcome', 'development-plan', 'context', 'requiredKnowledge', 'optionalKnowledge', 'expectedUnknown', 'requiresUnresolved', 'requiresMaterialUnresolved')
        if ($case.id -isnot [string] -or $case.id -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') { throw 'Fixture id must be kebab-case.' }
        if (-not $ids.Add($case.id) -or -not $modelIds.Add((Get-GuidanceCaseId $case.id))) { throw 'Duplicate fixture or model case identity.' }
        if ($case.expectedKind -cnotin @('feature', 'bug', 'refactor', 'upgrade', 'maintenance')) { throw 'Fixture expectedKind is invalid.' }
        if ($case.expectedOutcome -cnotin @('completed', 'not-applicable', 'no-knowledge', 'partial', 'failed')) { throw 'Fixture expectedOutcome is invalid.' }
        Assert-GuidanceString $case.expectedKind 'fixture.expectedKind'
        Assert-GuidanceString $case.expectedOutcome 'fixture.expectedOutcome'
        $null = Get-GuidancePlanRequest $case.'development-plan'
        Assert-GuidanceContext $case.context
        foreach ($name in @('requiredKnowledge', 'optionalKnowledge', 'expectedUnknown')) {
            Assert-GuidanceArray $case[$name] "fixture.$name" -Strings
        }
        if ($case.requiresUnresolved -isnot [bool]) { throw 'Fixture requiresUnresolved must be boolean.' }
        if ($case.requiresMaterialUnresolved -isnot [bool]) { throw 'Fixture requiresMaterialUnresolved must be boolean.' }
        if ($case.requiresMaterialUnresolved -and ($case.expectedOutcome -ne 'partial' -or -not $case.requiresUnresolved)) {
            throw 'Materially unresolved fixtures must expect partial and unresolved evidence.'
        }
        foreach ($key in $case.expectedUnknown) {
            if ($key -cnotin @('bc-version', 'technologies', 'countries', 'application-area')) { throw 'Fixture expectedUnknown is invalid.' }
        }
        $references = @($case.requiredKnowledge) + @($case.optionalKnowledge)
        if (@($references | Sort-Object -Unique).Count -ne $references.Count) { throw 'Fixture knowledge references contain duplicates.' }
        foreach ($reference in $references) { $null = Resolve-GuidanceReference $Root $reference -Knowledge }
        if ($case.expectedOutcome -in @('no-knowledge', 'not-applicable') -and $references.Count) {
            throw 'Empty-knowledge outcomes cannot require or accept knowledge.'
        }
    }
}

function Assert-GuidanceResult {
    param($Result, $Case, $Manifest, [string] $Root, [string] $Workspace)
    Assert-GuidanceObject $Result 'result' @('caseId', 'guidanceReport')
    Assert-GuidanceString $Result.caseId 'result.caseId'
    if ($Result.caseId -cne (Get-GuidanceCaseId $Case.id)) { throw 'Result caseId mismatch.' }
    if ($Result.Contains('workspaceRoot')) {
        Assert-GuidanceString $Result.workspaceRoot 'result.workspaceRoot'
        if (-not [IO.Path]::IsPathFullyQualified($Result.workspaceRoot) -or
            (Get-GuidanceSafePath $Result.workspaceRoot -Directory) -cne $Workspace) {
            throw 'Result workspaceRoot disagrees with the runner binding.'
        }
    }
    $report = $Result.guidanceReport
    Assert-GuidanceObject $report 'guidanceReport' @('skill', 'outcome', 'summary', 'context', 'knowledge', 'validation-considerations', 'suppressed', 'unresolved')
    Assert-GuidanceObject $report.skill 'skill' @('id', 'version')
    Assert-GuidanceString $report.skill.id 'skill.id'
    if ($report.skill.id -cne 'al-development-plan' -or $report.skill.version -isnot [long] -or $report.skill.version -ne 1) {
        throw 'Report skill identity/version is invalid.'
    }
    Assert-GuidanceString $report.outcome 'outcome'
    if ($report.outcome -cnotin @('completed', 'not-applicable', 'no-knowledge', 'partial', 'failed')) { throw 'Report outcome enum is invalid.' }
    if ($report.outcome -cne $Case.expectedOutcome) { throw 'Report outcome does not match fixture expectedOutcome.' }
    if ($report.outcome -in @('partial', 'failed') -or $report.Contains('outcome-reason')) {
        Assert-GuidanceString $report['outcome-reason'] 'outcome-reason'
    }
    Assert-GuidanceObject $report.summary 'summary' @('request', 'kind', 'candidates', 'selected')
    Assert-GuidanceString $report.summary.request 'summary.request'
    Assert-GuidanceString $report.summary.kind 'summary.kind'
    if ($report.summary.kind -cne $Case.expectedKind) { throw 'summary.kind does not match the intended change.' }
    Assert-GuidanceInteger $report.summary.candidates 'summary.candidates'
    Assert-GuidanceInteger $report.summary.selected 'summary.selected'
    Assert-GuidanceContext $report.context
    foreach ($name in @('knowledge', 'validation-considerations', 'suppressed', 'unresolved')) {
        Assert-GuidanceArray $report[$name] $name
    }
    Assert-GuidanceArray $report.unresolved 'unresolved' -Strings
    if ($report.summary.selected -ne $report.knowledge.Count -or $report.summary.selected -gt $report.summary.candidates) {
        throw 'Summary counts disagree with selected knowledge/candidates.'
    }
    if ($report.outcome -in @('no-knowledge', 'not-applicable') -and $report.knowledge.Count) { throw 'This outcome requires empty knowledge.' }
    if ($report.outcome -eq 'completed' -and -not $report.knowledge.Count) { throw 'Completed requires selected knowledge; empty evaluation is no-knowledge.' }
    if (($report.outcome -eq 'partial' -or $Case.requiresUnresolved) -and -not $report.unresolved.Count) {
        throw 'Partial/incomplete evaluation must explain unresolved gaps.'
    }
    foreach ($dimension in $Case.expectedUnknown) {
        if ($dimension -cnotin $report.context.unknown) { throw 'Expected unknown context was silently resolved.' }
    }
    foreach ($dimension in $report.context.unknown) {
        if (-not @($report.unresolved | Where-Object { $_ -match [regex]::Escape($dimension) }).Count) {
            throw 'Unknown dimensions require a corresponding unresolved explanation.'
        }
    }
    # Free-form unresolved text has no machine-readable materiality field in DO.
    # Known material fixture conditions are runner expectations, not model claims.
    if ($Case.requiresMaterialUnresolved -and $report.outcome -ne 'partial') { throw 'Material unknown guidance must remain partial.' }
    $used = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($entry in $report.knowledge) {
        Assert-GuidanceObject $entry 'knowledge entry' @('path', 'used-for', 'constraints', 'sample-paths')
        $null = Resolve-GuidanceReference $Root $entry.path -Knowledge
        if (-not $used.Add($entry.path)) { throw 'Duplicate knowledge reference.' }
        Assert-GuidanceString $entry.'used-for' 'knowledge.used-for'
        Assert-GuidanceArray $entry.constraints 'knowledge.constraints' -Strings -NonEmpty
        Assert-GuidanceArray $entry.'sample-paths' 'knowledge.sample-paths' -Strings
        if (@($entry.'sample-paths' | Sort-Object -Unique).Count -ne $entry.'sample-paths'.Count) { throw 'Duplicate sample reference.' }
        foreach ($sample in $entry.'sample-paths') { $null = Resolve-GuidanceReference $Root $sample -Article $entry.path }
        Assert-GuidanceReferenceSha $entry $Root
    }
    $validationIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($entry in $report.'validation-considerations') {
        Assert-GuidanceObject $entry 'validation consideration' @('id', 'reason', 'evidence')
        foreach ($key in @('id', 'reason', 'evidence')) { Assert-GuidanceString $entry[$key] "validation-considerations.$key" }
        if (-not $validationIds.Add($entry.id)) { throw 'Duplicate validation consideration id.' }
    }
    $suppressed = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($entry in $report.suppressed) {
        Assert-GuidanceObject $entry 'suppressed entry' @('reference', 'reason')
        Assert-GuidanceObject $entry.reference 'suppressed.reference' @('path')
        $null = Resolve-GuidanceReference $Root $entry.reference.path -Knowledge
        Assert-GuidanceReferenceSha $entry.reference $Root
        Assert-GuidanceString $entry.reason 'suppression reason'
        if ($entry.reason -cnotin @('layer-precedence', 'configuration')) { throw 'Suppression reason is invalid.' }
        if (-not $suppressed.Add($entry.reference.path) -or $used.Contains($entry.reference.path)) { throw 'Duplicate or selected suppressed reference.' }
    }
    $matched = @($Case.requiredKnowledge | Where-Object { $used.Contains($_) }).Count
    $recall = if ($Case.requiredKnowledge.Count) { $matched / $Case.requiredKnowledge.Count } else { 1.0 }
    $accepted = @($Case.requiredKnowledge) + @($Case.optionalKnowledge)
    $acceptedCount = @($used | Where-Object { $_ -cin $accepted }).Count
    $precision = if ($used.Count) { $acceptedCount / $used.Count } elseif (-not $Case.requiredKnowledge.Count) { 1.0 } else { 0.0 }
    if ($recall -lt $Manifest.minimumKnowledgeRecall) { throw 'Knowledge recall is below the manifest threshold.' }
    if ($precision -lt $Manifest.minimumKnowledgePrecision) { throw 'Knowledge precision is below the manifest threshold.' }
}

function Assert-GuidanceReferenceSha {
    param($Entry, [string] $Root)
    if ($Entry.Contains('sha')) {
        if ($Entry.sha -isnot [string] -or $Entry.sha -cnotmatch '^([0-9a-fA-F]{40}|[0-9a-fA-F]{64})$') {
            throw 'Reference SHA must be a full commit object id.'
        }
        $head = Invoke-GuidanceGit $Root @('rev-parse', '--verify', 'HEAD')
        if ($Entry.sha -ne $head) { throw 'Reference SHA does not identify the recorded live checkout.' }
        $committed = Invoke-GuidanceGit $Root @('cat-file', 'blob', "$head`:$($Entry.path)") -RawOutput
        $live = [IO.File]::ReadAllText((Resolve-GuidanceReference $Root $Entry.path -Knowledge))
        if ($committed.Replace("`r`n", "`n") -cne $live.Replace("`r`n", "`n")) {
            throw 'Reference SHA content differs from the live knowledge article.'
        }
    }
}

function Get-GuidanceResultSchema {
    param([string] $CaseId)
    return [ordered]@{
        caseId = $CaseId
        guidanceReport = [ordered]@{
            skill = [ordered]@{ id = 'al-development-plan'; version = 1 }
            outcome = 'completed | not-applicable | no-knowledge | partial | failed'
            'outcome-reason' = 'required for partial or failed'
            summary = [ordered]@{ request = 'planned intent'; kind = 'feature | bug | refactor | upgrade | maintenance'; candidates = 0; selected = 0 }
            context = [ordered]@{ 'bc-version' = 'resolved target or unknown'; technologies = @('al'); countries = @('w1'); 'application-area' = @('all'); unknown = @() }
            knowledge = @([ordered]@{ path = 'repo-relative knowledge article'; sha = 'optional full checkout commit id'; 'used-for' = 'plan decision'; constraints = @('faithful normative constraint'); 'sample-paths' = @() })
            'validation-considerations' = @([ordered]@{ id = 'stable id'; reason = 'why needed'; evidence = 'evidence implementation should obtain' })
            suppressed = @([ordered]@{ reference = [ordered]@{ path = 'suppressed knowledge path' }; reason = 'layer-precedence | configuration' })
            unresolved = @('Missing context/decision, affected candidate, and materiality; name unknown dimensions exactly.')
        }
    }
}
