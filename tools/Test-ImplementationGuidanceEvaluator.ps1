<#
.SYNOPSIS
    Deterministic, offline regressions for implementation-guidance fixtures.
.DESCRIPTION
    Exercises the shared guidance scorer with controlled reports and standalone
    synthetic AL repositories. No model, compiler, deployment, or network access
    is used. The uniquely named regression directory is removed in finally.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'DevelopmentGuidance.Evidence.ps1')

$sourceRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot '..')).FullName
$evaluator = Join-Path $PSScriptRoot 'Test-DevelopmentGuidanceFixtures.ps1'
$sourceManifestPath = Join-Path $sourceRoot 'evaluation\implementation-guidance-fixtures.json'
$scratch = Join-Path $sourceRoot ".implementation-guidance-regression-$([guid]::NewGuid().ToString('N'))"
$knowledgeRoot = Join-Path $scratch 'knowledge-checkout'
$runnerRoot = Join-Path $scratch 'runner'
$results = Join-Path $runnerRoot 'results'
$mapPath = Join-Path $runnerRoot 'workspace-map.json'
$baselinePath = Join-Path $runnerRoot 'baseline.json'
$manifestPath = Join-Path $knowledgeRoot 'evaluation\implementation-guidance-fixtures.json'
$tests = [Collections.Generic.List[string]]::new()

function Set-TestJson([string] $Path, $Value) {
    [IO.Directory]::CreateDirectory((Split-Path $Path -Parent)) | Out-Null
    [IO.File]::WriteAllText($Path, ($Value | ConvertTo-Json -Depth 64))
}

function Invoke-TestGit([string] $Directory, [string[]] $Arguments) {
    $null = @(& git --no-optional-locks -C $Directory @Arguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw 'Regression Git setup failed.' }
}

function Initialize-TestRepository([string] $Directory, [string] $CaseId) {
    [IO.Directory]::CreateDirectory($Directory) | Out-Null
    Invoke-TestGit $Directory @('init', '--quiet')
    Invoke-TestGit $Directory @('config', 'user.email', 'implementation-guidance@example.invalid')
    Invoke-TestGit $Directory @('config', 'user.name', 'Implementation guidance fixture')
    Invoke-TestGit $Directory @('config', 'commit.gpgSign', 'false')
    Invoke-TestGit $Directory @('config', 'core.autocrlf', 'false')
    [IO.File]::WriteAllText((Join-Path $Directory 'app.json'), '{"name":"Synthetic implementation fixture","application":"28.0.0.0"}')
    [IO.File]::WriteAllText((Join-Path $Directory 'CurrentImplementation.al'), "codeunit 71000 `"$CaseId`" { }")
    Invoke-TestGit $Directory @('add', '.')
    Invoke-TestGit $Directory @('commit', '--quiet', '-m', 'Synthetic implementation baseline')
}

function Invoke-Evaluator([string[]] $Arguments, [bool] $ShouldPass, [string] $Name, [string] $Diagnostic = '') {
    $output = @(& pwsh -NoProfile -File $evaluator @Arguments 2>&1) -join "`n"
    if (($LASTEXITCODE -eq 0) -ne $ShouldPass -or
        $output -notmatch $(if ($ShouldPass) { 'PASSED|captured' } else { 'FAILED' })) {
        throw "Regression '$Name' failed unexpectedly. $output"
    }
    if ($Diagnostic -and $output -notmatch [regex]::Escape($Diagnostic)) {
        throw "Regression '$Name' missed diagnostic '$Diagnostic'. $output"
    }
    $tests.Add($Name)
}

function New-ControlledReport($Case, [string] $KnowledgeSha) {
    $notApplicable = $Case.expectedOutcome -eq 'not-applicable'
    $decision = if ($notApplicable) {
        [ordered]@{
            phase = 'unavailable'; decision = 'Current implementation decision was not supplied.'
            'decision-key' = 'unavailable'; 'evidence-fingerprint' = 'unavailable'
            'affected-files' = @(); 'affected-symbols' = @(); 'changed-tokens' = @()
            'development-plan-pin' = 'unpinned'; 'implementation-evidence-pin' = 'unpinned'
        }
    } else { $Case.'decision-context' }
    $knowledge = @(
        foreach ($path in $Case.requiredKnowledge) {
            [ordered]@{
                path = $path
                sha = $KnowledgeSha
                'used-for' = $decision.decision
                constraints = @('Apply the opened article normative constraint to this current decision.')
                'sample-paths' = @()
            }
        }
    )
    $omitted = @(
        foreach ($path in $Case.expectedOmitted) {
            $consumed = @($Case.'consumed-guidance' | Where-Object path -CEQ $path)[0]
            [ordered]@{
                path = $path
                'decision-key' = $consumed.'decision-key'
                'evidence-fingerprint' = $consumed.'evidence-fingerprint'
                'prior-decision' = $consumed.'prior-decision'
            }
        }
    )
    return [ordered]@{
        skill = [ordered]@{ id = 'al-implementation-guidance'; version = 1 }
        outcome = $Case.expectedOutcome
        summary = [ordered]@{
            request = Get-GuidancePlanRequest $Case.'development-plan'
            phase = $decision.phase
            decision = $decision.decision
            'decision-key' = $decision.'decision-key'
            'evidence-fingerprint' = $decision.'evidence-fingerprint'
            candidates = $knowledge.Count + $omitted.Count
            selected = $knowledge.Count
            'omitted-consumed' = $omitted.Count
        }
        pins = [ordered]@{
            'knowledge-checkout' = $KnowledgeSha
            'development-plan' = $decision.'development-plan-pin'
            'implementation-evidence' = $decision.'implementation-evidence-pin'
        }
        context = [ordered]@{
            'bc-version' = $Case.context.'bc-version'
            technologies = @($Case.context.technologies)
            countries = @($Case.context.countries)
            'application-area' = @($Case.context.'application-area')
            'affected-files' = @($decision.'affected-files')
            'affected-symbols' = @($decision.'affected-symbols')
            'changed-tokens' = @($decision.'changed-tokens')
            unknown = @($Case.context.unknown)
        }
        knowledge = $knowledge
        'validation-considerations' = @()
        deduplication = [ordered]@{
            strategy = 'omit-exact-consumed-match'
            omitted = $omitted
        }
        suppressed = @()
        unresolved = @()
    }
}

try {
    $manifest = Read-GuidanceJson $sourceManifestPath
    $references = @($manifest.skill, 'tools/Build-KnowledgeIndex.ps1',
        'evaluation/implementation-guidance-fixtures.json') +
        @($manifest.cases | ForEach-Object {
            $_.requiredKnowledge
            $_.optionalKnowledge
            $_.expectedOmitted
        })
    foreach ($reference in @($references | Sort-Object -Unique)) {
        $source = Join-Path $sourceRoot $reference.Replace('/', [IO.Path]::DirectorySeparatorChar)
        $destination = Join-Path $knowledgeRoot $reference.Replace('/', [IO.Path]::DirectorySeparatorChar)
        [IO.Directory]::CreateDirectory((Split-Path $destination -Parent)) | Out-Null
        [IO.File]::Copy($source, $destination)
    }
    Initialize-TestRepository $knowledgeRoot 'Knowledge Checkout'
    [IO.Directory]::CreateDirectory($results) | Out-Null
    $workspaces = [ordered]@{}
    foreach ($case in $manifest.cases) {
        $workspace = Join-Path $scratch "target-$($case.id)"
        Initialize-TestRepository $workspace $case.id
        $workspaces[$case.id] = $workspace
    }
    Set-TestJson $mapPath $workspaces

    Invoke-Evaluator @('-Root', $knowledgeRoot, '-ManifestPath', $manifestPath) $true 'public implementation manifest validates'
    $prepared = Join-Path $runnerRoot 'prepared'
    Invoke-Evaluator @('-Root', $knowledgeRoot, '-ManifestPath', $manifestPath,
        '-PrepareDirectory', $prepared, '-WorkspaceMapPath', $mapPath) $true 'all implementation requests prepare'
    $missingCase = @($manifest.cases | Where-Object id -CEQ 'missing-current-decision-and-diff')[0]
    $missingRequest = Read-GuidanceJson (Join-Path $prepared "request-$(Get-GuidanceCaseId $missingCase.id).json")
    if ($missingRequest.'implementation-diff' -cne '' -or $missingRequest.'decision-context'.Count) {
        throw 'Preparation invented missing current implementation context.'
    }
    $tests.Add('missing context remains missing during preparation')

    Invoke-Evaluator @('-Root', $knowledgeRoot, '-ManifestPath', $manifestPath,
        '-CaptureBaseline', '-WorkspaceMapPath', $mapPath, '-BaselinePath', $baselinePath) $true 'read-only baselines capture'
    $knowledgeSha = Invoke-GuidanceGit $knowledgeRoot @('rev-parse', 'HEAD')
    foreach ($case in $manifest.cases) {
        Set-TestJson (Join-Path $results "result-$(Get-GuidanceCaseId $case.id).json") ([ordered]@{
            caseId = Get-GuidanceCaseId $case.id
            guidanceReport = New-ControlledReport $case $knowledgeSha
        })
    }
    $scoreArgs = @('-Root', $knowledgeRoot, '-ManifestPath', $manifestPath,
        '-ResultsDirectory', $results, '-BaselinePath', $baselinePath,
        '-BaselineSha256', (Get-GuidanceHash $baselinePath))
    Invoke-Evaluator $scoreArgs $true 'focused, deduplicated, clean, missing, and boundary reports score'

    $consumedCase = @($manifest.cases | Where-Object id -CEQ 'exact-consumed-guidance-is-omitted')[0]
    $consumedPath = Join-Path $results "result-$(Get-GuidanceCaseId $consumedCase.id).json"
    $consumedResult = Read-GuidanceJson $consumedPath
    $consumedResult.guidanceReport.deduplication.omitted = @()
    $consumedResult.guidanceReport.summary.'omitted-consumed' = 0
    Set-TestJson $consumedPath $consumedResult
    Invoke-Evaluator $scoreArgs $false 'exact consumed guidance cannot disappear from deduplication' 'omitted set'
    Set-TestJson $consumedPath ([ordered]@{
        caseId = Get-GuidanceCaseId $consumedCase.id
        guidanceReport = New-ControlledReport $consumedCase $knowledgeSha
    })

    [IO.File]::AppendAllText((Join-Path $workspaces['read-only-public-interface-checkpoint'] 'CurrentImplementation.al'), "`n// forbidden mutation")
    Invoke-Evaluator $scoreArgs $false 'target repository mutation is detected' 'identity/content changed'

    Write-Host "Implementation guidance evaluator regressions PASSED: $($tests.Count) checks."
} finally {
    if (Test-Path -LiteralPath $scratch) {
        Remove-Item -LiteralPath $scratch -Recurse -Force
    }
}

exit 0
