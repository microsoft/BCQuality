<#
.SYNOPSIS
    Collects the paths changed by the exact tree under fixture validation.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('pull_request', 'push')]
    [string] $EventName,
    [Parameter(Mandatory)]
    [ValidatePattern('^[0-9a-fA-F]{40}$')]
    [string] $CommitSha,
    [string] $BaseSha,
    [Parameter(Mandatory)]
    [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($EventName -eq 'pull_request') {
    $parents = @(git rev-list --parents -n 1 $CommitSha)
    if ($LASTEXITCODE -ne 0) { throw "Cannot inspect tested PR merge '$CommitSha'." }
    $commits = ([string]($parents -join ' ')).Split(' ', [StringSplitOptions]::RemoveEmptyEntries)
    if ($commits.Count -ne 3) { throw 'Fixture PR validation requires the two-parent test merge commit.' }
    # Event base.sha can be stale; the first parent is the base actually tested.
    $BaseSha = $commits[1]
}

$paths = if (-not $BaseSha -or $BaseSha -match '^0+$') {
    @(git diff-tree --no-commit-id --name-only -r $CommitSha)
} else {
    @(git diff --name-only $BaseSha $CommitSha)
}
if ($LASTEXITCODE -ne 0) { throw "Cannot collect changed paths for '$CommitSha'." }
$paths | Set-Content -LiteralPath $OutputPath -Encoding utf8NoBOM
