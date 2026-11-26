<#
.SYNOPSIS
    Regresses fixture coverage inputs against a stale PR event base.
#>
[CmdletBinding()]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..' '..'))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path -LiteralPath $Root).Path
$collector = Join-Path $Root '.github/scripts/Get-ReviewChangedPaths.ps1'
$work = Join-Path ([IO.Path]::GetTempPath()) "bcquality-changed-paths-$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Path $work | Out-Null
$originalLocation = Get-Location

function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments)] [string[]] $Arguments)
    $output = @(git @Arguments 2>&1)
    if ($LASTEXITCODE -ne 0) { throw "git $($Arguments -join ' ') failed: $($output -join "`n")" }
    return $output
}

function Assert-Paths {
    param([string[]] $Expected, [string] $Message)
    $actual = @(Get-Content -LiteralPath (Join-Path $work 'changed.txt'))
    if (($actual -join "`n") -cne (($Expected | Sort-Object) -join "`n")) { throw $Message }
}

try {
    Set-Location $work
    Invoke-Git @('init', '--quiet', '--initial-branch=main') | Out-Null
    Invoke-Git @('config', 'user.name', 'Fixture regression') | Out-Null
    Invoke-Git @('config', 'user.email', 'fixture@example.invalid') | Out-Null
    Invoke-Git @('config', 'commit.gpgsign', 'false') | Out-Null
    'initial' | Set-Content -LiteralPath 'seed.txt'
    Invoke-Git @('add', '.') | Out-Null
    Invoke-Git @('commit', '--quiet', '-m', 'Initial tree') | Out-Null
    $eventBase = [string](Invoke-Git @('rev-parse', 'HEAD'))

    $historical = @('historical.md', 'historical.good.al', 'historical.bad.al')
    foreach ($path in $historical) { 'existing main content' | Set-Content -LiteralPath $path }
    Invoke-Git @('add', '.') | Out-Null
    Invoke-Git @('commit', '--quiet', '-m', 'Unrelated main articles') | Out-Null
    $actualBase = [string](Invoke-Git @('rev-parse', 'HEAD'))
    Invoke-Git @('checkout', '--quiet', '-b', 'contribution') | Out-Null
    $contribution = @('contribution.md', 'contribution.good.al', 'contribution.bad.al')
    foreach ($path in $contribution) { 'new paired article' | Set-Content -LiteralPath $path }
    'edited existing article' | Set-Content -LiteralPath 'historical.md'
    $changed = @($contribution) + @('historical.md')
    Invoke-Git @('add', '.') | Out-Null
    Invoke-Git @('commit', '--quiet', '-m', 'Contributed pair') | Out-Null
    $head = [string](Invoke-Git @('rev-parse', 'HEAD'))
    Invoke-Git @('checkout', '--quiet', 'main') | Out-Null
    Invoke-Git @('merge', '--quiet', '--no-ff', 'contribution', '-m', 'Synthetic PR test merge') | Out-Null
    $merge = [string](Invoke-Git @('rev-parse', 'HEAD'))
    $outputPath = Join-Path $work 'changed.txt'

    $stalePaths = @(Invoke-Git @('diff', '--name-only', $eventBase, $merge))
    if ($stalePaths.Count -ne 6) { throw 'The stale-base reproduction must include unrelated history.' }
    & $collector -EventName pull_request -CommitSha $merge -BaseSha $eventBase -OutputPath $outputPath
    Assert-Paths $changed 'PR coverage included unrelated history or omitted a new pair/existing article edit.'
    & $collector -EventName pull_request -CommitSha $merge -BaseSha $actualBase -OutputPath $outputPath
    Assert-Paths $changed 'PR coverage changed when event metadata used the current base.'

    & $collector -EventName push -CommitSha $head -BaseSha $actualBase -OutputPath $outputPath
    Assert-Paths $changed 'Push coverage must retain the full before-to-after delta.'
    & $collector -EventName push -CommitSha $head -BaseSha $eventBase -OutputPath $outputPath
    Assert-Paths (@($contribution) + $historical) 'A multi-commit push must include every change since before.'
    & $collector -EventName push -CommitSha $head -BaseSha ('0' * 40) -OutputPath $outputPath
    Assert-Paths $changed 'An initial push must retain last-commit path collection.'
    & $collector -EventName push -CommitSha $head -OutputPath $outputPath
    Assert-Paths $changed 'An absent push base must retain last-commit path collection.'

    $failed = $false
    try { & $collector -EventName pull_request -CommitSha $head -BaseSha $eventBase -OutputPath $outputPath }
    catch {
        if ($_.Exception.Message -notlike '*two-parent test merge*') { throw }
        $failed = $true
    }
    if (-not $failed) { throw 'A non-merge PR checkout must fail explicitly.' }
    $failed = $false
    try { & $collector -EventName push -CommitSha $head -BaseSha ('f' * 40) -OutputPath $outputPath 2>$null }
    catch {
        if ($_.Exception.Message -notlike '*Cannot collect changed paths*') { throw }
        $failed = $true
    }
    if (-not $failed) { throw 'A missing push base must not yield success-shaped coverage.' }
    Write-Host 'Changed-path regression checks PASSED: stale/current PR bases, paired paths, push fallbacks, and explicit failures.'
} finally {
    Set-Location $originalLocation
    Remove-Item -LiteralPath $work -Recurse -Force
}
# Expected negative subprocesses must not determine a successful CI step exit.
exit 0
