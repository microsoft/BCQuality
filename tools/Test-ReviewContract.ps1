<#
.SYNOPSIS
    Validates executable findings-report acceptance and bounded normalization.

.DESCRIPTION
    These assertions keep the normative DO contract, executable validator, AL
    coordinator, and standalone runner aligned while exercising semantic report
    validation and the exact normalization predicate.
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

function Assert-ThrowsLike {
    param(
        [scriptblock] $Action,
        [string] $Pattern
    )

    try {
        & $Action
    }
    catch {
        if ($_.Exception.Message -like $Pattern) {
            return
        }
        throw "Expected error like '$Pattern', received: $($_.Exception.Message)"
    }
    throw "Expected error like '$Pattern', but no error was thrown."
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

$validator = Join-Path $Root 'tools/Validate-FindingsReport.ps1'
Assert-True (Test-Path -LiteralPath $validator -PathType Leaf) 'executable report validator exists'
$tmp = Join-Path ([IO.Path]::GetTempPath()) ("reviewcontract_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp -Force | Out-Null
try {
    $sourcePath = 'src/codeunit.al'
    $sourceFile = Join-Path $tmp 'src/codeunit.al'
    New-Item -ItemType Directory -Path (Split-Path -Parent $sourceFile) -Force | Out-Null
    Set-Content -LiteralPath $sourceFile -Value @('line one', 'line two', 'line three') -Encoding utf8NoBOM
    $articlePath = 'microsoft/knowledge/style/caption-required-on-page-fields.md'
    $supportingArticlePath = 'microsoft/knowledge/style/tooltip-required-on-page-fields.md'
    $reportPath = Join-Path $tmp 'report.json'

    $validReport = [ordered]@{
        skill = [ordered]@{ id = 'al-style-review'; version = 1 }
        outcome = 'completed'
        summary = [ordered]@{
            counts = [ordered]@{ blocker = 0; major = 0; minor = 1; info = 0 }
            coverage = [ordered]@{ 'worklist-size' = 1; 'items-evaluated' = 1 }
        }
        findings = @(
            [ordered]@{
                id = $articlePath
                severity = 'minor'
                message = 'A concrete style defect.'
                location = [ordered]@{
                    file = $sourcePath
                    line = 2
                    range = [ordered]@{ 'start-line' = 2; 'end-line' = 3 }
                }
                references = @([ordered]@{ path = $articlePath })
                confidence = 'high'
                domain = 'Style'
            }
        )
        suppressed = @()
    }
    Set-Content -LiteralPath $reportPath -Value ($validReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $accepted = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SourceRoot $tmp `
        -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    Assert-True (-not $accepted.normalized) 'valid report is accepted without normalization'

    $invalidCounts = $validReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $invalidCounts.summary.counts.minor = 0
    Set-Content -LiteralPath $reportPath -Value ($invalidCounts | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*COUNT_MISMATCH*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SourceRoot $tmp `
            -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    }

    $completedUndercoverage = $validReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $completedUndercoverage.summary.coverage.'items-evaluated' = 0
    Set-Content -LiteralPath $reportPath -Value ($completedUndercoverage | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*COMPLETED_COVERAGE_INCOMPLETE*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SourceRoot $tmp `
            -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    }

    $partialFullCoverage = $validReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $partialFullCoverage.outcome = 'partial'
    $partialFullCoverage | Add-Member -NotePropertyName 'outcome-reason' -NotePropertyValue 'Stopped early.'
    Set-Content -LiteralPath $reportPath -Value ($partialFullCoverage | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*PARTIAL_COVERAGE_INVALID*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SourceRoot $tmp `
            -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    }

    $completedLeaf = [ordered]@{
        skill = [ordered]@{ id = 'al-style-review'; version = 1 }
        outcome = 'completed'
        summary = [ordered]@{
            counts = [ordered]@{ blocker = 0; major = 0; minor = 0; info = 0 }
            coverage = [ordered]@{ 'worklist-size' = 1; 'items-evaluated' = 1 }
        }
        findings = @()
        suppressed = @()
    }
    $leafWithSubResults = $completedLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $leafWithSubResults | Add-Member -NotePropertyName 'sub-results' -NotePropertyValue @($completedLeaf)
    Set-Content -LiteralPath $reportPath -Value ($leafWithSubResults | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*LEAF_COMPOSITION_INVALID*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root
    }

    $validSuperReport = [ordered]@{
        skill = [ordered]@{ id = 'al-code-review'; version = 1 }
        outcome = 'completed'
        summary = [ordered]@{
            counts = [ordered]@{ blocker = 0; major = 0; minor = 0; info = 0 }
            coverage = [ordered]@{ 'worklist-size' = 2; 'items-evaluated' = 2 }
        }
        findings = @()
        suppressed = @()
        'sub-results' = @($completedLeaf, $completedLeaf)
    }
    Set-Content -LiteralPath $reportPath -Value ($validSuperReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $acceptedSuper = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super
    Assert-True (-not $acceptedSuper.normalized) 'valid super-skill report is accepted'

    $styleFindingLeaf = $validReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $securityFindingLeaf = $validReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $securityFindingLeaf.skill.id = 'al-security-review'
    $rolledFinding = $validReport.findings[0] | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $rolledFinding | Add-Member -NotePropertyName 'from-sub-skill' -NotePropertyValue 'al-style-review'
    $deduplicatedSuperReport = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $deduplicatedSuperReport.summary.counts.minor = 1
    $deduplicatedSuperReport.findings = @($rolledFinding)
    $deduplicatedSuperReport.'sub-results' = @($styleFindingLeaf, $securityFindingLeaf)
    Set-Content -LiteralPath $reportPath -Value ($deduplicatedSuperReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $acceptedDeduplicatedSuper = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
        -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    Assert-True (-not $acceptedDeduplicatedSuper.normalized) 'one top-level finding may deduplicate the same citation from two leaves'

    $twoOccurrenceLeaf = $styleFindingLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $secondOccurrence = $twoOccurrenceLeaf.findings[0] | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $secondOccurrence.location.line = 1
    $secondOccurrence.location.range.'start-line' = 1
    $secondOccurrence.location.range.'end-line' = 1
    $twoOccurrenceLeaf.findings = @($twoOccurrenceLeaf.findings[0], $secondOccurrence)
    $twoOccurrenceLeaf.summary.counts.minor = 2
    $emptySecurityLeaf = $completedLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $emptySecurityLeaf.skill.id = 'al-security-review'
    $sameIdOccurrenceOmitted = $deduplicatedSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $sameIdOccurrenceOmitted.'sub-results' = @($twoOccurrenceLeaf, $emptySecurityLeaf)
    Set-Content -LiteralPath $reportPath -Value ($sameIdOccurrenceOmitted | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_FINDING_MISSING*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
            -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    }

    $mergeOwnerLeaf = $styleFindingLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $mergeOwnerLeaf.findings[0] | Add-Member -NotePropertyName 'suggested-code' -NotePropertyValue 'Caption = ''Customer name'';'
    $supportingFindingLeaf = $securityFindingLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $supportingFindingLeaf.findings[0].id = $supportingArticlePath
    $supportingFindingLeaf.findings[0].references[0].path = $supportingArticlePath
    $supportingFindingLeaf.findings[0].confidence = 'medium'
    $supportingFindingLeaf.findings[0].message = 'The field needs the same mechanical correction for a supporting rule.'
    $supportingFindingLeaf.findings[0] | Add-Member -NotePropertyName 'suggested-code' -NotePropertyValue 'Caption = ''Customer name'';'
    $mergedFinding = $rolledFinding | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $mergedFinding | Add-Member -NotePropertyName 'suggested-code' -NotePropertyValue 'Caption = ''Customer name'';'
    $mergedFinding.references = @(
        [pscustomobject]@{ path = $articlePath }
        [pscustomobject]@{ path = $supportingArticlePath }
    )
    $mergedSuperReport = $deduplicatedSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $mergedSuperReport.findings = @($mergedFinding)
    $mergedSuperReport.'sub-results' = @($mergeOwnerLeaf, $supportingFindingLeaf)
    Set-Content -LiteralPath $reportPath -Value ($mergedSuperReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $acceptedMergedSuper = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
        -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath, $supportingArticlePath
    Assert-True (-not $acceptedMergedSuper.normalized) 'overlapping A and B findings may merge into A with B as a supporting reference'

    $textOnlyOwnerLeaf = $mergeOwnerLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $textOnlyOwnerLeaf.findings[0].PSObject.Properties.Remove('suggested-code')
    $textOnlySupportingLeaf = $supportingFindingLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $textOnlySupportingLeaf.findings[0].PSObject.Properties.Remove('suggested-code')
    $textOnlyMergedFinding = $mergedFinding | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $textOnlyMergedFinding.PSObject.Properties.Remove('suggested-code')
    $textOnlyMergedSuper = $mergedSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $textOnlyMergedSuper.findings = @($textOnlyMergedFinding)
    $textOnlyMergedSuper.'sub-results' = @($textOnlyOwnerLeaf, $textOnlySupportingLeaf)
    Set-Content -LiteralPath $reportPath -Value ($textOnlyMergedSuper | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $acceptedTextOnlyMerge = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
        -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath, $supportingArticlePath
    Assert-True (-not $acceptedTextOnlyMerge.normalized) 'supporting references permit an overlapping A and B merge with different messages and no suggested code'

    $conflictingSupportingLeaf = $supportingFindingLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $conflictingSupportingLeaf.findings[0].'suggested-code' = 'ToolTip = ''Customer name'';'
    $conflictingCorrectionMerge = $mergedSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $conflictingCorrectionMerge.'sub-results' = @($mergeOwnerLeaf, $conflictingSupportingLeaf)
    Set-Content -LiteralPath $reportPath -Value ($conflictingCorrectionMerge | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_FINDING_MISSING*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
            -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath, $supportingArticlePath
    }

    $omittedConflictingCorrectionMerge = $conflictingCorrectionMerge | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $omittedConflictingCorrectionMerge.findings[0].PSObject.Properties.Remove('suggested-code')
    Set-Content -LiteralPath $reportPath -Value ($omittedConflictingCorrectionMerge | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_FINDING_MISMATCH*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
            -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath, $supportingArticlePath
    }

    $unmergedSupportingFinding = $supportingFindingLeaf.findings[0] | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $unmergedSupportingFinding | Add-Member -NotePropertyName 'from-sub-skill' -NotePropertyValue 'al-security-review'
    $unmergedDuplicates = $mergedSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $unmergedDuplicates.summary.counts.minor = 2
    $unmergedDuplicates.findings = @($mergedFinding, $unmergedSupportingFinding)
    Set-Content -LiteralPath $reportPath -Value ($unmergedDuplicates | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_DUPLICATE_FINDINGS*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
            -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath, $supportingArticlePath
    }

    $omittedLeafFinding = $deduplicatedSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $omittedLeafFinding.summary.counts.minor = 0
    $omittedLeafFinding.findings = @()
    Set-Content -LiteralPath $reportPath -Value ($omittedLeafFinding | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_FINDING_MISSING*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
            -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    }

    $locationlessLeaf = $styleFindingLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $locationlessLeaf.findings[0].PSObject.Properties.Remove('location')
    $secondLocationlessFinding = $locationlessLeaf.findings[0] | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $locationlessLeaf.findings = @($locationlessLeaf.findings[0], $secondLocationlessFinding)
    $locationlessLeaf.summary.counts.minor = 2
    $locationlessRolledFinding = $rolledFinding | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $locationlessRolledFinding.PSObject.Properties.Remove('location')
    $locationlessOmission = $deduplicatedSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $locationlessOmission.findings = @($locationlessRolledFinding)
    $locationlessOmission.'sub-results' = @($locationlessLeaf, $emptySecurityLeaf)
    Set-Content -LiteralPath $reportPath -Value ($locationlessOmission | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_FINDING_MISSING*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
            -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    }

    $completeLocationlessRollup = $locationlessOmission | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $completeLocationlessRollup.summary.counts.minor = 2
    $completeLocationlessRollup.findings = @(
        $locationlessRolledFinding
        ($locationlessRolledFinding | ConvertTo-Json -Depth 20 | ConvertFrom-Json)
    )
    Set-Content -LiteralPath $reportPath -Value ($completeLocationlessRollup | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $acceptedLocationlessRollup = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
        -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    Assert-True (-not $acceptedLocationlessRollup.normalized) 'two locationless leaf occurrences require and accept two distinct rolled findings'

    $nonexistentProducer = $deduplicatedSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $nonexistentProducer.findings[0].'from-sub-skill' = 'al-missing-review'
    Set-Content -LiteralPath $reportPath -Value ($nonexistentProducer | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_PRODUCER_INVALID*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
            -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    }

    $rewrittenLeafFinding = $deduplicatedSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $rewrittenLeafFinding.findings[0].message = 'A rewritten rollup message.'
    Set-Content -LiteralPath $reportPath -Value ($rewrittenLeafFinding | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_FINDING_MISMATCH*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
            -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    }

    $failedLeaf = $completedLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $failedLeaf.skill.id = 'al-security-review'
    $failedLeaf.outcome = 'failed'
    $failedLeaf | Add-Member -NotePropertyName 'outcome-reason' -NotePropertyValue 'Validation failed.'
    $failedLeaf.summary.coverage.'items-evaluated' = 0
    $partialSuperReport = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $partialSuperReport.outcome = 'partial'
    $partialSuperReport | Add-Member -NotePropertyName 'outcome-reason' -NotePropertyValue 'One sub-skill failed.'
    $partialSuperReport.summary.coverage.'worklist-size' = 1
    $partialSuperReport.summary.coverage.'items-evaluated' = 1
    $partialSuperReport.'sub-results' = @($completedLeaf, $failedLeaf)
    Set-Content -LiteralPath $reportPath -Value ($partialSuperReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $acceptedPartialSuper = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super
    Assert-True (-not $acceptedPartialSuper.normalized) 'partial super-skill excludes failed coverage from its rollup'

    $failedLeafLeakage = $partialSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $failedLeafLeakage.summary.counts.minor = 1
    $failedLeafLeakage.findings = @($rolledFinding | ConvertTo-Json -Depth 20 | ConvertFrom-Json)
    $failedLeafLeakage.findings[0].'from-sub-skill' = 'al-security-review'
    Set-Content -LiteralPath $reportPath -Value ($failedLeafLeakage | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_FAILED_FINDING_LEAKAGE*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
            -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    }

    $failedLeafRelabeledAsAgent = $partialSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $failedLeafRelabeledAsAgent.summary.counts.minor = 1
    $failedLeafRelabeledAsAgent.findings = @($rolledFinding | ConvertTo-Json -Depth 20 | ConvertFrom-Json)
    $failedLeafRelabeledAsAgent.findings[0].'from-sub-skill' = 'agent'
    $failedLeafRelabeledAsAgent.findings[0].domain = 'Agent'
    Set-Content -LiteralPath $reportPath -Value ($failedLeafRelabeledAsAgent | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_AGENT_FINDING_INVALID*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
            -SourceRoot $tmp -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    }

    $incorrectOutcome = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $incorrectOutcome.outcome = 'not-applicable'
    Set-Content -LiteralPath $reportPath -Value ($incorrectOutcome | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_OUTCOME_MISMATCH*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super
    }

    $incorrectRollup = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $incorrectRollup.summary.coverage.'worklist-size' = 1
    $incorrectRollup.summary.coverage.'items-evaluated' = 1
    Set-Content -LiteralPath $reportPath -Value ($incorrectRollup | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_COVERAGE_MISMATCH*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super
    }

    Set-Content -LiteralPath $reportPath -Value ($validReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*REFERENCE_NOT_RETRIEVED*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SourceRoot $tmp -SourcePaths $sourcePath
    }

    $invalidAgent = $validReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $invalidAgent.findings[0].id = 'agent:uncited-defect'
    $invalidAgent.findings[0].references = @()
    $invalidAgent.findings[0].confidence = 'high'
    Set-Content -LiteralPath $reportPath -Value ($invalidAgent | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*AGENT_CONFIDENCE_INVALID*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SourceRoot $tmp -SourcePaths $sourcePath
    }

    $normalizable = $validReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $normalizable.findings[0].location.range.'start-line' = 1
    Set-Content -LiteralPath $reportPath -Value ($normalizable | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*RANGE_START_MISMATCH*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SourceRoot $tmp `
            -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath
    }
    $normalized = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SourceRoot $tmp `
        -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath -AllowBoundedNormalization
    Assert-True $normalized.normalized 'eligible range mismatch is normalized'
    Assert-True ($normalized.removedRanges.Count -eq 1) 'normalization records one removed range'
    Assert-True (-not ($normalized.report.findings[0].location.PSObject.Properties.Name -contains 'range')) `
        'accepted normalized report removes only the optional range'
}
finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output "Review contract validation passed ($($cases.Count) predicate cases plus executable acceptance cases)."
