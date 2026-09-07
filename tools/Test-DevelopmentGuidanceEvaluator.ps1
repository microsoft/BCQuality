<#
.SYNOPSIS
    Deterministic, offline regressions for the guidance evaluator (no model/AL run).
.DESCRIPTION
    Creates only a uniquely named .guidance-evaluator-regression-* directory below
    the current checkout, with standalone Git repositories and sibling runner
    artifacts. Removes that exact directory in finally; never uses the OS temp
    directory or cleans a caller-provided repository.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'DevelopmentGuidance.Evidence.ps1')
$evaluator = Join-Path $PSScriptRoot 'Test-DevelopmentGuidanceFixtures.ps1'
$sourceRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..')).FullName
$scratch = Join-Path $sourceRoot ".guidance-evaluator-regression-$([guid]::NewGuid().ToString('N'))"
$root = Join-Path $scratch 'knowledge-checkout'
$article = 'microsoft/knowledge/performance/pair-findset-with-next-loop.md'
$otherArticle = 'microsoft/knowledge/performance/findset-true-applies-updlock-on-read.md'
$sample = 'microsoft/knowledge/performance/pair-findset-with-next-loop.good.al'
$tests = [Collections.Generic.List[string]]::new()
$script:scenarioNumber = 0
$script:reportScenario = $null

function Set-TestJson($Path, $Value) {
    [IO.File]::WriteAllText($Path, ($Value | ConvertTo-Json -Depth 64))
}

function Invoke-TestGit([string] $Directory, [string[]] $Arguments) {
    $output = @(& git --no-optional-locks -C $Directory @Arguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw 'Regression Git setup failed.' }
}

function Initialize-TestRepository([string] $Directory) {
    [IO.Directory]::CreateDirectory($Directory) | Out-Null
    Invoke-TestGit $Directory @('init', '--quiet')
    Invoke-TestGit $Directory @('config', 'user.email', 'guidance-fixture@example.invalid')
    Invoke-TestGit $Directory @('config', 'user.name', 'Guidance fixture')
    Invoke-TestGit $Directory @('config', 'commit.gpgSign', 'false')
    Invoke-TestGit $Directory @('config', 'core.autocrlf', 'false')
    [IO.File]::WriteAllText((Join-Path $Directory 'app.json'), '{"name":"Synthetic AL fixture","application":"28.0.0.0"}')
    [IO.File]::WriteAllText((Join-Path $Directory 'tracked.al'), 'codeunit 50100 Example {}')
    [IO.File]::WriteAllText((Join-Path $Directory '.gitignore'), "ignored.txt`nignored-directory/`n")
    Invoke-TestGit $Directory @('add', '.')
    Invoke-TestGit $Directory @('commit', '--quiet', '-m', 'Synthetic fixture baseline')
}

function Invoke-EvaluatorTest([string] $Name, [string[]] $Arguments, [bool] $ShouldPass, [string] $Diagnostic = '') {
    $output = @(& pwsh -NoProfile -File $evaluator @Arguments 2>&1) -join "`n"
    $code = $LASTEXITCODE
    if (($code -eq 0) -ne $ShouldPass -or $output -notmatch $(if ($ShouldPass) { 'PASSED|captured' } else { 'FAILED' })) {
        throw "Regression '$Name' unexpected exit $code. $output"
    }
    if ($Diagnostic -and $output -notmatch [regex]::Escape($Diagnostic)) {
        throw "Regression '$Name' missing diagnostic '$Diagnostic'. $output"
    }
    if ($output -match 'MODEL_SECRET_SENTINEL') { throw "Regression '$Name' leaked model content." }
    $tests.Add($Name)
}

function New-TestScenario([string] $Outcome = 'completed', [switch] $Unknown, [switch] $SecondCase) {
    $script:scenarioNumber++
    $directory = Join-Path $scratch "scenario-$script:scenarioNumber"
    [IO.Directory]::CreateDirectory($directory) | Out-Null
    $workspace = Join-Path $directory 'target'
    Initialize-TestRepository $workspace
    [IO.File]::WriteAllText((Join-Path $workspace 'untracked.txt'), 'existing untracked content')
    [IO.File]::WriteAllText((Join-Path $workspace 'ignored.txt'), 'existing ignored content')
    [IO.Directory]::CreateDirectory((Join-Path $workspace 'ignored-directory')) | Out-Null
    [IO.File]::WriteAllText((Join-Path $workspace 'ignored-directory\child.txt'), 'ignored child')
    $results = Join-Path $directory 'results'
    [IO.Directory]::CreateDirectory($results) | Out-Null
    $hasKnowledge = $Outcome -in @('completed', 'partial')
    $case = [ordered]@{
        id = 'synthetic-case'
        expectedKind = 'bug'
        expectedOutcome = $Outcome
        expectedUnknown = @($(if ($Unknown) { 'bc-version' }))
        requiresUnresolved = ($Outcome -eq 'partial' -or $Unknown.IsPresent)
        requiresMaterialUnresolved = ($Outcome -eq 'partial')
        'development-plan' = [ordered]@{ kind = 'bug'; request = 'Iterate the supplied filtered record set.' }
        context = [ordered]@{
            'bc-version' = $(if ($Unknown) { 'unknown' } else { '28' })
            technologies = @('al')
            countries = @('w1')
            'application-area' = @('all')
            unknown = @($(if ($Unknown) { 'bc-version' }))
        }
        requiredKnowledge = @($(if ($hasKnowledge) { $article }))
        optionalKnowledge = @()
    }
    $manifest = [ordered]@{
        version = 1
        skill = 'microsoft/skills/development/al-development-plan.md'
        minimumKnowledgeRecall = 1.0
        minimumKnowledgePrecision = 1.0
        cases = @($case)
    }
    $result = [ordered]@{
        caseId = Get-GuidanceCaseId $case.id
        guidanceReport = [ordered]@{
            skill = [ordered]@{ id = 'al-development-plan'; version = 1 }
            outcome = $Outcome
            summary = [ordered]@{ request = 'Iterate all selected records.'; kind = 'bug'; candidates = [int]$hasKnowledge; selected = [int]$hasKnowledge }
            context = $case.context
            knowledge = @($(if ($hasKnowledge) {
                [ordered]@{ path = $article; 'used-for' = 'Choose the multi-record reader.'; constraints = @('Use FindSet when iterating with Next.'); 'sample-paths' = @($sample) }
            }))
            'validation-considerations' = @([ordered]@{ id = 'all-selected'; reason = 'Preserve selection.'; evidence = 'Test all selected records and an excluded record.' })
            suppressed = @()
            unresolved = @($(if ($Outcome -eq 'partial') {
                if ($Unknown) { 'bc-version is unknown and materially affects the candidate; clarify before completing guidance.' }
                else { 'The caller cardinality decision remains materially unresolved.' }
            } elseif ($Unknown) { 'bc-version is unknown but immaterial: selected loop guidance applies to all versions.' }))
        }
    }
    if ($Outcome -in @('partial', 'failed')) { $result.guidanceReport.'outcome-reason' = 'Fixture intentionally leaves evaluation incomplete.' }
    $manifestPath = Join-Path $directory 'manifest.json'
    $mapPath = Join-Path $directory 'workspace-map.json'
    $map = [ordered]@{ 'synthetic-case' = $workspace }
    if ($SecondCase) {
        $second = $case | ConvertTo-Json -Depth 64 | ConvertFrom-Json -AsHashtable
        $second.id = 'second-case'
        $manifest.cases += $second
        $secondWorkspace = Join-Path $directory 'second-target'
        Initialize-TestRepository $secondWorkspace
        $map[$second.id] = $secondWorkspace
        $secondResult = $result | ConvertTo-Json -Depth 64 | ConvertFrom-Json -AsHashtable
        $secondResult.caseId = Get-GuidanceCaseId $second.id
        Set-TestJson (Join-Path $results "result-$($secondResult.caseId).json") $secondResult
    }
    Set-TestJson $manifestPath $manifest
    Set-TestJson $mapPath $map
    $resultPath = Join-Path $results "result-$($result.caseId).json"
    Set-TestJson $resultPath $result
    $baselinePath = Join-Path $directory 'baseline.json'
    $captureArgs = @('-Root', $root, '-ManifestPath', $manifestPath, '-CaptureBaseline', '-WorkspaceMapPath', $mapPath, '-BaselinePath', $baselinePath)
    $output = @(& pwsh -NoProfile -File $evaluator @captureArgs 2>&1) -join "`n"
    if ($LASTEXITCODE -ne 0) { throw "Baseline setup failed. $output" }
    return [ordered]@{
        directory = $directory; workspace = $workspace; resultPath = $resultPath; result = $result
        results = $results; manifest = $manifest; manifestPath = $manifestPath; mapPath = $mapPath
        baselinePath = $baselinePath; captureArgs = $captureArgs
        scoreArgs = @('-Root', $root, '-ManifestPath', $manifestPath, '-ResultsDirectory', $results, '-BaselinePath', $baselinePath, '-BaselineSha256', (Get-GuidanceHash $baselinePath))
    }
}

function Test-ReportMutation([string] $Name, [scriptblock] $Change, [string] $Diagnostic) {
    if ($null -eq $script:reportScenario) { $script:reportScenario = New-TestScenario }
    $scenario = $script:reportScenario
    $result = $scenario.result | ConvertTo-Json -Depth 64 | ConvertFrom-Json -AsHashtable
    & $Change $result
    Set-TestJson $scenario.resultPath $result
    Invoke-EvaluatorTest $Name $scenario.scoreArgs $false $Diagnostic
}

try {
    [IO.Directory]::CreateDirectory($root) | Out-Null
    foreach ($reference in @($article, $otherArticle, $sample, $otherArticle.Replace('.md', '.good.al'),
            'microsoft/skills/development/al-development-plan.md', 'tools/Build-KnowledgeIndex.ps1')) {
        $destination = Join-Path $root $reference.Replace('/', [IO.Path]::DirectorySeparatorChar)
        [IO.Directory]::CreateDirectory((Split-Path $destination -Parent)) | Out-Null
        [IO.File]::Copy((Join-Path $sourceRoot $reference.Replace('/', [IO.Path]::DirectorySeparatorChar)), $destination)
    }
    Initialize-TestRepository $root

    $publicManifestPath = Join-Path $sourceRoot 'evaluation\development-guidance-fixtures.json'
    $publicManifest = Read-GuidanceJson $publicManifestPath
    $publicRoot = Join-Path $scratch 'public-fixture-checkout'
    $publicReferences = @($publicManifest.skill, 'tools/Build-KnowledgeIndex.ps1', 'evaluation/development-guidance-fixtures.json') +
        @($publicManifest.cases | ForEach-Object { $_.requiredKnowledge; $_.optionalKnowledge })
    foreach ($reference in @($publicReferences | Sort-Object -Unique)) {
        $destination = Join-Path $publicRoot $reference.Replace('/', [IO.Path]::DirectorySeparatorChar)
        [IO.Directory]::CreateDirectory((Split-Path $destination -Parent)) | Out-Null
        [IO.File]::Copy((Join-Path $sourceRoot $reference.Replace('/', [IO.Path]::DirectorySeparatorChar)), $destination)
    }
    $publicPrepared = Join-Path $scratch 'public-prepared'
    Invoke-EvaluatorTest 'public five-case manifest validation' @('-Root', $publicRoot) $true
    Invoke-EvaluatorTest 'public five-case manifest preparation' @('-Root', $publicRoot, '-PrepareDirectory', $publicPrepared) $true
    $initialCase = $publicManifest.cases | Where-Object id -eq 'synthetic-normal-initial-plan'
    $initialRequest = Read-GuidanceJson (Join-Path $publicPrepared "request-$(Get-GuidanceCaseId $initialCase.id).json")
    if ($initialRequest.'development-plan' -cne $initialCase.'development-plan') { throw 'Preparation truncated the serialized initial plan.' }
    $document = $initialRequest.'development-plan' | ConvertFrom-Json -AsHashtable
    if ($document.metadata.kind -ne 'bug' -or
        @('Root cause and design', 'Proposed fix', 'Affected files', 'Test strategy', 'Acceptance criteria' |
            Where-Object { $document.body -notmatch [regex]::Escape($_) }).Count) {
        throw 'Synthetic consumer boundary lost metadata or markdown plan sections.'
    }
    $tests.Add('serialized synthetic initial-plan boundary preserves full metadata and markdown body')

    $scenario = New-TestScenario
    Invoke-EvaluatorTest 'unchanged target with ignored and untracked files passes' $scenario.scoreArgs $true
    Invoke-EvaluatorTest 'scoring itself leaves index and content unchanged' $scenario.scoreArgs $true
    Invoke-EvaluatorTest 'existing baseline cannot silently recapture' $scenario.captureArgs $false 'Baseline already exists'
    Invoke-EvaluatorTest 'scoring without baseline fails' @('-Root', $root, '-ManifestPath', $scenario.manifestPath, '-ResultsDirectory', $scenario.results) $false 'require BaselinePath'
    Invoke-EvaluatorTest 'scoring requires independently retained baseline digest' @('-Root', $root, '-ManifestPath', $scenario.manifestPath, '-ResultsDirectory', $scenario.results, '-BaselinePath', $scenario.baselinePath) $false 'runner-retained pre-run BaselineSha256'
    Invoke-EvaluatorTest 'tampered baseline digest fails' @('-Root', $root, '-ManifestPath', $scenario.manifestPath, '-ResultsDirectory', $scenario.results, '-BaselinePath', $scenario.baselinePath, '-BaselineSha256', ('0' * 64)) $false 'digest mismatch'

    $prepare = Join-Path $scenario.directory 'prepared'
    Invoke-EvaluatorTest 'prepare outside roots with runner workspace binding' @('-Root', $root, '-ManifestPath', $scenario.manifestPath, '-PrepareDirectory', $prepare, '-WorkspaceMapPath', $scenario.mapPath) $true
    $prepared = Read-GuidanceJson (Join-Path $prepare "request-$($scenario.result.caseId).json")
    if ($prepared.repository -cne $scenario.workspace -or $prepared.Contains('expectedOutcome') -or $prepared.Contains('requiredKnowledge')) {
        throw 'Prepared request lost runner binding or exposed answers.'
    }
    Invoke-EvaluatorTest 'preparation never overwrites requests' @('-Root', $root, '-ManifestPath', $scenario.manifestPath, '-PrepareDirectory', $prepare) $false 'new or empty'
    foreach ($option in @('PrepareDirectory', 'BaselinePath', 'ResultsDirectory')) {
        $inside = Join-Path $scenario.workspace 'unsafe-artifact'
        $arguments = @('-Root', $root, '-ManifestPath', $scenario.manifestPath)
        if ($option -eq 'PrepareDirectory') { $arguments += @('-PrepareDirectory', $inside, '-WorkspaceMapPath', $scenario.mapPath) }
        elseif ($option -eq 'BaselinePath') { $arguments += @('-CaptureBaseline', '-BaselinePath', $inside, '-WorkspaceMapPath', $scenario.mapPath) }
        else { $arguments += @('-BaselinePath', $scenario.baselinePath, '-BaselineSha256', (Get-GuidanceHash $scenario.baselinePath), '-ResultsDirectory', $inside) }
        Invoke-EvaluatorTest "$option inside target rejected" $arguments $false 'outside target workspaces'
    }

    foreach ($mutation in @('uncommitted', 'committed', 'empty-commit', 'staged', 'index-only', 'untracked', 'ignored', 'ignored-child', 'added', 'deleted', 'directory', 'ref', 'metadata')) {
        $scenario = New-TestScenario
        switch ($mutation) {
            'uncommitted' { [IO.File]::AppendAllText((Join-Path $scenario.workspace 'tracked.al'), "`n// changed") }
            'committed' {
                [IO.File]::AppendAllText((Join-Path $scenario.workspace 'tracked.al'), "`n// changed")
                Invoke-TestGit $scenario.workspace @('add', 'tracked.al')
                Invoke-TestGit $scenario.workspace @('commit', '--quiet', '-m', 'Committed forbidden edit')
            }
            'staged' {
                [IO.File]::AppendAllText((Join-Path $scenario.workspace 'tracked.al'), "`n// changed")
                Invoke-TestGit $scenario.workspace @('add', 'tracked.al')
            }
            'empty-commit' { Invoke-TestGit $scenario.workspace @('commit', '--quiet', '--allow-empty', '-m', 'Forbidden empty commit') }
            'index-only' { Invoke-TestGit $scenario.workspace @('update-index', '--assume-unchanged', 'tracked.al') }
            'untracked' { [IO.File]::AppendAllText((Join-Path $scenario.workspace 'untracked.txt'), 'changed') }
            'ignored' { [IO.File]::AppendAllText((Join-Path $scenario.workspace 'ignored.txt'), 'changed') }
            'ignored-child' { [IO.File]::AppendAllText((Join-Path $scenario.workspace 'ignored-directory\child.txt'), 'changed') }
            'added' { [IO.File]::WriteAllText((Join-Path $scenario.workspace 'new.txt'), 'new ignored/untracked payload') }
            'deleted' { [IO.File]::Delete((Join-Path $scenario.workspace 'untracked.txt')) }
            'directory' { [IO.Directory]::CreateDirectory((Join-Path $scenario.workspace 'new-empty-directory')) | Out-Null }
            'ref' { Invoke-TestGit $scenario.workspace @('branch', 'new-reference') }
            'metadata' {
                $path = Join-Path $scenario.workspace 'tracked.al'
                [IO.File]::SetLastWriteTimeUtc($path, [IO.File]::GetLastWriteTimeUtc($path).AddSeconds(5))
            }
        }
        Invoke-EvaluatorTest "$mutation mutation fails" $scenario.scoreArgs $false 'identity/content changed'
    }

    $scenario = New-TestScenario -SecondCase
    Invoke-EvaluatorTest 'two independently bound workspaces pass' $scenario.scoreArgs $true
    $map = Read-GuidanceJson $scenario.mapPath
    [IO.File]::AppendAllText((Join-Path $scenario.workspace 'tracked.al'), "`n// changed")
    $scenario.result.workspaceRoot = $map['second-case']
    Set-TestJson $scenario.resultPath $scenario.result
    Invoke-EvaluatorTest 'self-reported clean workspace cannot hide changed runner target' $scenario.scoreArgs $false 'identity/content changed'
    $scenario = New-TestScenario -SecondCase
    $scenario.result.workspaceRoot = (Read-GuidanceJson $scenario.mapPath)['second-case']
    Set-TestJson $scenario.resultPath $scenario.result
    Invoke-EvaluatorTest 'result workspace swapping rejected even when both are clean' $scenario.scoreArgs $false 'runner binding'
    $scenario = New-TestScenario -SecondCase
    $scenario.result.caseId = Get-GuidanceCaseId 'second-case'
    Set-TestJson $scenario.resultPath $scenario.result
    Invoke-EvaluatorTest 'result case swapping rejected' $scenario.scoreArgs $false 'caseId mismatch'
    $scenario = New-TestScenario
    $scenario.manifest.cases[0].expectedKind = 'feature'
    Set-TestJson $scenario.manifestPath $scenario.manifest
    Invoke-EvaluatorTest 'changed manifest rejected' $scenario.scoreArgs $false 'root or manifest'
    $scenario = New-TestScenario
    $baseline = Read-GuidanceJson $scenario.baselinePath
    $baseline.workspaces['synthetic-case'].caseId = 'case-00000000'
    Set-TestJson $scenario.baselinePath $baseline
    Invoke-EvaluatorTest 'baseline case binding checked even with matching digest' @('-Root', $root, '-ManifestPath', $scenario.manifestPath, '-ResultsDirectory', $scenario.results, '-BaselinePath', $scenario.baselinePath, '-BaselineSha256', (Get-GuidanceHash $scenario.baselinePath)) $false 'case identity mismatch'

    foreach ($outcome in @('no-knowledge', 'partial', 'failed', 'not-applicable')) {
        $scenario = New-TestScenario $outcome
        Invoke-EvaluatorTest "honest $outcome is distinguishable and passes" $scenario.scoreArgs $true
    }
    $scenario = New-TestScenario 'partial' -Unknown
    Invoke-EvaluatorTest 'material unknown stays partial' $scenario.scoreArgs $true
    $scenario.result.guidanceReport.outcome = 'completed'
    Set-TestJson $scenario.resultPath $scenario.result
    Invoke-EvaluatorTest 'material unknown cannot silently complete' $scenario.scoreArgs $false 'expectedOutcome'
    $scenario = New-TestScenario 'completed' -Unknown
    Invoke-EvaluatorTest 'nonmaterial unknown can complete with explanation' $scenario.scoreArgs $true
    $scenario.result.guidanceReport.unresolved = @()
    Set-TestJson $scenario.resultPath $scenario.result
    Invoke-EvaluatorTest 'unknown cannot disappear from unresolved evidence' $scenario.scoreArgs $false 'unresolved gaps'
    $scenario = New-TestScenario 'no-knowledge' -Unknown
    Invoke-EvaluatorTest 'immaterial unknown and no-knowledge are not failures' $scenario.scoreArgs $true
    foreach ($outcome in @('partial', 'failed')) {
        $scenario = New-TestScenario $outcome
        $scenario.result.guidanceReport.Remove('outcome-reason')
        Set-TestJson $scenario.resultPath $scenario.result
        Invoke-EvaluatorTest "$outcome requires outcome-reason" $scenario.scoreArgs $false 'outcome-reason'
    }
    $scenario = New-TestScenario 'no-knowledge'
    $scenario.result.guidanceReport.outcome = 'completed'
    Set-TestJson $scenario.resultPath $scenario.result
    Invoke-EvaluatorTest 'no-knowledge is not completed-empty' $scenario.scoreArgs $false 'expectedOutcome'
    $scenario = New-TestScenario 'no-knowledge'
    $scenario.result.guidanceReport.knowledge = @(@{ path = $article; 'used-for' = 'filler'; constraints = @('filler'); 'sample-paths' = @() })
    $scenario.result.guidanceReport.summary.candidates = 1
    $scenario.result.guidanceReport.summary.selected = 1
    Set-TestJson $scenario.resultPath $scenario.result
    Invoke-EvaluatorTest 'no-knowledge cannot contain filler knowledge' $scenario.scoreArgs $false 'requires empty knowledge'

    Test-ReportMutation 'invalid outcome enum' { param($r) $r.guidanceReport.outcome = 'success' } 'outcome enum'
    Test-ReportMutation 'missing report fields' { param($r) $r.guidanceReport.Remove('knowledge') } 'missing required field'
    Test-ReportMutation 'null report object' { param($r) $r.guidanceReport = $null } 'JSON object'
    Test-ReportMutation 'wrong skill version type' { param($r) $r.guidanceReport.skill.version = '1' } 'identity/version'
    Test-ReportMutation 'wrong skill id type' { param($r) $r.guidanceReport.skill.id = @('al-development-plan') } 'non-empty string'
    Test-ReportMutation 'wrong kind type' { param($r) $r.guidanceReport.summary.kind = @('bug') } 'non-empty string'
    Test-ReportMutation 'wrong summary type' { param($r) $r.guidanceReport.summary = @() } 'JSON object'
    Test-ReportMutation 'fractional count' { param($r) $r.guidanceReport.summary.candidates = 1.5 } 'non-negative integer'
    Test-ReportMutation 'negative count' { param($r) $r.guidanceReport.summary.selected = -1 } 'non-negative integer'
    Test-ReportMutation 'inconsistent selected count' { param($r) $r.guidanceReport.summary.selected = 0 } 'Summary counts'
    Test-ReportMutation 'candidate count below selected' { param($r) $r.guidanceReport.summary.candidates = 0 } 'Summary counts'
    Test-ReportMutation 'wrong context list type' { param($r) $r.guidanceReport.context.technologies = 'al' } 'JSON array'
    Test-ReportMutation 'missing constraints' { param($r) $r.guidanceReport.knowledge[0].constraints = @() } 'must not be empty'
    Test-ReportMutation 'non-string constraints' { param($r) $r.guidanceReport.knowledge[0].constraints = @(@{ body = 'MODEL_SECRET_SENTINEL' }) } 'non-empty string'
    Test-ReportMutation 'missing sample array' { param($r) $r.guidanceReport.knowledge[0].Remove('sample-paths') } 'missing required field'
    Test-ReportMutation 'duplicate knowledge' {
        param($r)
        $r.guidanceReport.knowledge += $r.guidanceReport.knowledge[0]
        $r.guidanceReport.summary.selected = 2
        $r.guidanceReport.summary.candidates = 2
    } 'Duplicate knowledge'
    Test-ReportMutation 'bad validation entry' { param($r) $r.guidanceReport.'validation-considerations'[0].evidence = $false } 'non-empty string'
    Test-ReportMutation 'invalid suppression shape' { param($r) $r.guidanceReport.suppressed = @(@{ path = $article; reason = 'configuration' }) } 'missing required field'
    Test-ReportMutation 'invalid unresolved shape' { param($r) $r.guidanceReport.unresolved = @(@{ candidate = $article }) } 'non-empty string'
    Test-ReportMutation 'invalid SHA provenance' { param($r) $r.guidanceReport.knowledge[0].sha = '0' * 40 } 'recorded live checkout'
    $scenario = New-TestScenario
    $scenario.result.guidanceReport.knowledge[0].sha = Invoke-GuidanceGit $root @('rev-parse', 'HEAD')
    Set-TestJson $scenario.resultPath $scenario.result
    Invoke-EvaluatorTest 'actual pinned knowledge SHA accepted' $scenario.scoreArgs $true

    foreach ($badPath in @('../outside.md', '/absolute.md', 'C:/external.md',
            'microsoft\knowledge\performance\pair-findset-with-next-loop.md',
            'microsoft/knowledge/performance/../performance/pair-findset-with-next-loop.md',
            'https://example.invalid/article.md', 'microsoft/knowledge/performance/missing.md',
            'microsoft/skills/development/al-development-plan.md')) {
        $scenario = New-TestScenario
        $scenario.result.guidanceReport.knowledge[0].path = $badPath
        Set-TestJson $scenario.resultPath $scenario.result
        Invoke-EvaluatorTest 'unsafe/nonexistent/non-knowledge citation rejected' $scenario.scoreArgs $false
    }
    foreach ($badSample in @('../outside.al', $article, $otherArticle.Replace('.md', '.good.al'), 'microsoft/knowledge/performance/other.good.al', 'microsoft\knowledge\performance\pair-findset-with-next-loop.good.al')) {
        $scenario = New-TestScenario
        $scenario.result.guidanceReport.knowledge[0].'sample-paths' = @($badSample)
        Set-TestJson $scenario.resultPath $scenario.result
        Invoke-EvaluatorTest 'unsafe/nonexistent/non-sibling sample rejected' $scenario.scoreArgs $false
    }
    foreach ($json in @('{', 'null', '[]', '{"caseId":"MODEL_SECRET_SENTINEL","caseId":"duplicate"}', '{"caseId":true,}', '// comment')) {
        $scenario = New-TestScenario
        [IO.File]::WriteAllText($scenario.resultPath, $json)
        Invoke-EvaluatorTest 'malformed model result fails without runtime crash or content leakage' $scenario.scoreArgs $false
    }

    $scenario = New-TestScenario
    $outside = Join-Path $scenario.directory 'outside'
    [IO.Directory]::CreateDirectory($outside) | Out-Null
    $link = Join-Path $scenario.workspace 'escape'
    $linkKind = if ($IsWindows) { 'Junction' } else { 'SymbolicLink' }
    New-Item -ItemType $linkKind -Path $link -Target $outside | Out-Null
    try {
        Invoke-EvaluatorTest 'target junction/symlink rejected instead of followed' $scenario.scoreArgs $false 'Links, junctions'
        Invoke-EvaluatorTest 'baseline capture rejects junction/symlink target children' @('-Root', $root, '-ManifestPath', $scenario.manifestPath, '-CaptureBaseline', '-WorkspaceMapPath', $scenario.mapPath, '-BaselinePath', (Join-Path $scenario.directory 'linked-baseline.json')) $false 'Links, junctions'
        Invoke-EvaluatorTest 'prepared directory cannot escape through junction' @('-Root', $root, '-ManifestPath', $scenario.manifestPath, '-PrepareDirectory', (Join-Path $link 'prepared'), '-WorkspaceMapPath', $scenario.mapPath) $false 'Links, junctions'
    } finally { Remove-Item -LiteralPath $link -Force }
    $scenario = New-TestScenario
    $external = Join-Path $scenario.directory 'external.txt'
    [IO.File]::WriteAllText($external, 'external hard-link target')
    $hardLink = Join-Path $scenario.workspace 'hard-link.txt'
    New-Item -ItemType HardLink -Path $hardLink -Target $external | Out-Null
    try {
        Invoke-EvaluatorTest 'hard-link escape rejected' $scenario.scoreArgs $false 'Links, junctions'
    } finally { Remove-Item -LiteralPath $hardLink -Force }
    $scenario = New-TestScenario
    $externalArticle = Join-Path $scenario.directory 'outside.md'
    [IO.File]::Copy((Join-Path $root $article.Replace('/', [IO.Path]::DirectorySeparatorChar)), $externalArticle)
    $articleLink = Join-Path $root 'custom\knowledge\performance'
    [IO.Directory]::CreateDirectory((Split-Path $articleLink -Parent)) | Out-Null
    New-Item -ItemType $linkKind -Path $articleLink -Target $scenario.directory | Out-Null
    try {
        $rejected = $false
        try { $null = Resolve-GuidanceReference $root 'custom/knowledge/performance/outside.md' -Knowledge }
        catch { $rejected = $_.Exception.Message -match 'Links, junctions' }
        if (-not $rejected) { throw 'Linked knowledge reference was followed.' }
        $tests.Add('knowledge junction/symlink reference rejected')
        $rejected = $false
        try { $null = Resolve-GuidanceReference $root 'custom/knowledge/performance/pair-findset-with-next-loop.good.al' -Article 'custom/knowledge/performance/pair-findset-with-next-loop.md' }
        catch { $rejected = $_.Exception.Message -match 'Links, junctions' }
        if (-not $rejected) { throw 'Linked sample reference was followed.' }
        $tests.Add('sample junction/symlink reference rejected')
    } finally { Remove-Item -LiteralPath $articleLink -Force }
    $normativePath = Join-Path $root 'microsoft\knowledge\performance\single-normative-section.md'
    foreach ($heading in @('Best Practice', 'Anti Pattern')) {
        [IO.File]::WriteAllText($normativePath, "---`ndomain: performance`n---`n## Description`nSynthetic contract fixture.`n## $heading`nSynthetic normative constraint.`n")
        $null = Resolve-GuidanceReference $root 'microsoft/knowledge/performance/single-normative-section.md' -Knowledge
        $tests.Add("Knowledge article with only $heading accepted")
    }
    [IO.File]::Delete($normativePath)
    $scenario = New-TestScenario
    $linkedRoot = Join-Path $scratch 'linked-knowledge-checkout'
    Invoke-TestGit $root @('worktree', 'add', '--quiet', '--detach', $linkedRoot, 'HEAD')
    $linkedBaseline = Join-Path $scenario.directory 'linked-root-baseline.json'
    Invoke-EvaluatorTest 'linked knowledge checkout baseline capture' @('-Root', $linkedRoot, '-ManifestPath', $scenario.manifestPath, '-CaptureBaseline', '-WorkspaceMapPath', $scenario.mapPath, '-BaselinePath', $linkedBaseline) $true
    Invoke-EvaluatorTest 'unchanged linked knowledge checkout scoring' @('-Root', $linkedRoot, '-ManifestPath', $scenario.manifestPath, '-ResultsDirectory', $scenario.results, '-BaselinePath', $linkedBaseline, '-BaselineSha256', (Get-GuidanceHash $linkedBaseline)) $true
    $scenario = New-TestScenario
    $map = Read-GuidanceJson $scenario.mapPath
    $map['synthetic-case'] = $linkedRoot
    Set-TestJson $scenario.mapPath $map
    Invoke-EvaluatorTest 'linked target checkout rejected as external Git storage' @('-Root', $root, '-ManifestPath', $scenario.manifestPath, '-CaptureBaseline', '-WorkspaceMapPath', $scenario.mapPath, '-BaselinePath', (Join-Path $scenario.directory 'external-git-baseline.json')) $false 'standalone repositories'
    $scenario = New-TestScenario
    [IO.File]::AppendAllText((Join-Path $root $sample.Replace('/', [IO.Path]::DirectorySeparatorChar)), "`n// changed knowledge sample")
    Invoke-EvaluatorTest 'knowledge checkout changes rejected' $scenario.scoreArgs $false 'Knowledge checkout identity/content changed'
    Write-Host "Development guidance evaluator regressions PASSED: $($tests.Count) checks."
} finally {
    if (Test-Path -LiteralPath $scratch) {
        # Only our own uniquely named directory; links made by tests are removed above.
        Remove-Item -LiteralPath $scratch -Recurse -Force
    }
}
