<#
.SYNOPSIS
    Validates the bounded leaf-range normalization contract.

.DESCRIPTION
    BCQuality has no executable findings-report consumer. These assertions keep
    the normative DO contract, AL coordinator, and standalone runner aligned
    while exercising the exact normalization predicate against representative
    safe and ambiguous inputs.
#>
[CmdletBinding()]
param(
    [string] $Root = (Resolve-Path (Join-Path $PSScriptRoot '..'))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path -LiteralPath $Root).Path

function Assert-True {
    param(
        [bool] $Condition,
        [string] $Message
    )

    if (-not $Condition) {
        throw "Assertion failed: $Message"
    }
}

function Assert-Contains {
    param(
        [string] $Text,
        [string] $Expected,
        [string] $Message
    )

    Assert-True $Text.Contains($Expected) $Message
}

function Test-PositiveInteger {
    param([object] $Value)

    if (($null -eq $Value) -or ($Value -is [bool]) -or ($Value -isnot [ValueType])) {
        return $false
    }

    $number = [double]$Value
    return [double]::IsFinite($number) -and ($number -gt 0) -and ([math]::Truncate($number) -eq $number)
}

function Test-RangeNormalizationEligibility {
    param([pscustomobject] $Finding)

    if ($Finding.PSObject.Properties.Name -contains 'suggested-code') {
        return $false
    }
    if (-not ($Finding.PSObject.Properties.Name -contains 'location')) {
        return $false
    }
    if (-not ($Finding.location.PSObject.Properties.Name -contains 'line')) {
        return $false
    }
    if (-not ($Finding.location.PSObject.Properties.Name -contains 'range')) {
        return $false
    }

    $range = $Finding.location.range
    if (-not ($range.PSObject.Properties.Name -contains 'start-line') -or
        -not ($range.PSObject.Properties.Name -contains 'end-line')) {
        return $false
    }

    $line = $Finding.location.line
    $startLine = $range.'start-line'
    $endLine = $range.'end-line'
    if (-not (Test-PositiveInteger $line) -or
        -not (Test-PositiveInteger $startLine) -or
        -not (Test-PositiveInteger $endLine)) {
        return $false
    }

    return ($startLine -le $line) -and ($line -le $endLine) -and ($startLine -ne $line)
}

$transportSentence = 'Capture the exact Task return as the immutable raw audit payload and primary transport.'
$doContract = Get-Content -LiteralPath (Join-Path $Root 'skills/do.md') -Raw
$coordinatorContract = Get-Content -LiteralPath (Join-Path $Root 'microsoft/skills/review/al-code-review.md') -Raw
$runnerContract = Get-Content -LiteralPath (Join-Path $Root 'docs/standalone-runner.md') -Raw

foreach ($surface in @(
    [pscustomobject]@{ Name = 'DO'; Text = ($doContract -replace '\s+', ' ') }
    [pscustomobject]@{ Name = 'AL coordinator'; Text = ($coordinatorContract -replace '\s+', ' ') }
    [pscustomobject]@{ Name = 'standalone runner'; Text = ($runnerContract -replace '\s+', ' ') }
)) {
    Assert-Contains $surface.Text $transportSentence "$($surface.Name) preserves exact Task transport wording"
}

$normalizedDoContract = $doContract -replace '\s+', ' '
foreach ($expected in @(
    'positive integers',
    'start-line <= line <= end-line',
    'does not contain the `suggested-code` field',
    'remove only',
    'private run telemetry or artifacts',
    'Validate the entire normalized candidate',
    'If any other validation defect exists',
    'salvage arbitrary individual findings'
)) {
    Assert-Contains $normalizedDoContract $expected "DO documents '$expected'"
}

$cases = @(
    [pscustomobject]@{
        Name = 'contained mismatched range without suggested code'
        Expected = $true
        Finding = '{"message":"keep me","location":{"file":"src/codeunit.al","line":37,"range":{"start-line":36,"end-line":38}}}' | ConvertFrom-Json
    }
    [pscustomobject]@{
        Name = 'aligned range'
        Expected = $false
        Finding = '{"location":{"line":37,"range":{"start-line":37,"end-line":38}}}' | ConvertFrom-Json
    }
    [pscustomobject]@{
        Name = 'suggested code present'
        Expected = $false
        Finding = '{"location":{"line":37,"range":{"start-line":36,"end-line":38}},"suggested-code":""}' | ConvertFrom-Json
    }
    [pscustomobject]@{
        Name = 'line outside range'
        Expected = $false
        Finding = '{"location":{"line":39,"range":{"start-line":36,"end-line":38}}}' | ConvertFrom-Json
    }
    [pscustomobject]@{
        Name = 'reversed range'
        Expected = $false
        Finding = '{"location":{"line":37,"range":{"start-line":38,"end-line":36}}}' | ConvertFrom-Json
    }
    [pscustomobject]@{
        Name = 'zero bound'
        Expected = $false
        Finding = '{"location":{"line":1,"range":{"start-line":0,"end-line":2}}}' | ConvertFrom-Json
    }
    [pscustomobject]@{
        Name = 'fractional primary line'
        Expected = $false
        Finding = '{"location":{"line":37.5,"range":{"start-line":36,"end-line":38}}}' | ConvertFrom-Json
    }
    [pscustomobject]@{
        Name = 'missing end line'
        Expected = $false
        Finding = '{"location":{"line":37,"range":{"start-line":36}}}' | ConvertFrom-Json
    }
)

foreach ($case in $cases) {
    $actual = Test-RangeNormalizationEligibility $case.Finding
    Assert-True ($actual -eq $case.Expected) "$($case.Name) eligibility is $($case.Expected)"
}

$rawFinding = $cases[0].Finding
$candidateFinding = $rawFinding | ConvertTo-Json -Depth 10 | ConvertFrom-Json
$candidateFinding.location.PSObject.Properties.Remove('range')

Assert-True ($rawFinding.location.PSObject.Properties.Name -contains 'range') 'raw finding remains unchanged'
Assert-True (-not ($candidateFinding.location.PSObject.Properties.Name -contains 'range')) 'candidate removes only the optional range'
Assert-True ($candidateFinding.location.line -eq $rawFinding.location.line) 'candidate preserves the primary line'
Assert-True ($candidateFinding.message -ceq $rawFinding.message) 'candidate preserves all other finding content'

Write-Output "Review contract validation passed ($($cases.Count) normalization cases)."
