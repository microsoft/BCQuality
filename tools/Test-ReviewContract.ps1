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

function Assert-ReportSchema {
    param([object] $Report, [bool] $Expected, [string] $Message)

    $valid = $Report | ConvertTo-Json -Depth 30 |
        Test-Json -SchemaFile (Join-Path $Root 'schemas/findings-report.schema.json') -ErrorAction SilentlyContinue
    Assert-True ($valid -eq $Expected) $Message
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
    'Copy every citation-based `findings[].id` verbatim from `references[0].path`, with no `#` fragment or other suffix.',
    'For `references: []`, emit only `confidence: "medium"` or `"low"` and `severity: "minor"` or `"info"`.',
    'Open the final source snapshot for every `location.file`.',
    '1-based final-file line numbers within that file''s length, never diff/patch-relative line numbers.',
    'Consumers MUST NOT strip ID suffixes, downgrade agent findings, or clamp locations',
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

    $completedSecurityLeaf = $completedLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $completedSecurityLeaf.skill.id = 'al-security-review'
    $validSuperReport = [ordered]@{
        skill = [ordered]@{ id = 'al-code-review'; version = 1 }
        outcome = 'completed'
        summary = [ordered]@{
            counts = [ordered]@{ blocker = 0; major = 0; minor = 0; info = 0 }
            coverage = [ordered]@{ 'worklist-size' = 2; 'items-evaluated' = 2 }
        }
        findings = @()
        suppressed = @()
        'sub-results' = @($completedLeaf, $completedSecurityLeaf)
    }
    Set-Content -LiteralPath $reportPath -Value ($validSuperReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $acceptedSuper = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super
    Assert-True (-not $acceptedSuper.normalized) 'valid super-skill report is accepted'

    foreach ($isAgent in @($false, $true)) {
        foreach ($severity in 'blocker', 'major', 'minor', 'info') {
            foreach ($confidence in 'high', 'medium', 'low') {
                $schemaLeaf = $validReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
                $schemaLeaf.findings[0].severity = $severity
                $schemaLeaf.findings[0].confidence = $confidence
                $schemaLeaf.summary.counts.minor = 0
                $schemaLeaf.summary.counts.$severity = 1
                if ($isAgent) {
                    $schemaLeaf.findings[0].id = 'agent:uncited-defect'
                    $schemaLeaf.findings[0].references = @()
                }
                $expected = -not $isAgent -or ($severity -in @('minor', 'info') -and $confidence -ne 'high')
                $caseName = "agent=$isAgent severity=$severity confidence=$confidence"
                Assert-ReportSchema $schemaLeaf $expected "leaf schema: $caseName"

                $schemaSuper = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
                $schemaSuper.'sub-results'[0] = $schemaLeaf
                $schemaSuper.summary.counts = $schemaLeaf.summary.counts
                $schemaSuper.findings = @($schemaLeaf.findings[0] | ConvertTo-Json -Depth 20 | ConvertFrom-Json)
                $schemaSuper.findings[0] | Add-Member -NotePropertyName 'from-sub-skill' -NotePropertyValue 'al-style-review'
                if ($isAgent) {
                    $schemaSuper.findings[0].id = "al-style-review:$($schemaLeaf.findings[0].id)"
                }
                Assert-ReportSchema $schemaSuper $expected "rolled-up schema: $caseName"

                if ($isAgent) {
                    $schemaSuper.'sub-results'[0] = $completedLeaf
                    $schemaSuper.findings[0].id = $schemaLeaf.findings[0].id
                    $schemaSuper.findings[0].'from-sub-skill' = 'agent'
                    $schemaSuper.findings[0].domain = 'Agent'
                    Assert-ReportSchema $schemaSuper $expected "root-owned agent schema: $caseName"

                    $schemaSuper.findings = @()
                    $schemaSuper.summary.counts = $completedLeaf.summary.counts
                    $schemaSuper.'sub-results'[0] = $schemaLeaf
                    Assert-ReportSchema $schemaSuper $expected "nested leaf schema: $caseName"
                }
            }
        }
    }

    $citationSuper = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $citationSuper.'sub-results'[0] = $validReport
    $citationSuper.summary.counts = $validReport.summary.counts
    $citationSuper.findings = @($validReport.findings[0] | ConvertTo-Json -Depth 20 | ConvertFrom-Json)
    $citationSuper.findings[0] | Add-Member -NotePropertyName 'from-sub-skill' -NotePropertyValue 'al-style-review'
    foreach ($position in 'leaf', 'root', 'nested-leaf') {
        $fragmentReport = $(if ($position -eq 'leaf') { $validReport } else { $citationSuper }) |
            ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $fragmentFinding = if ($position -eq 'nested-leaf') {
            $fragmentReport.'sub-results'[0].findings[0]
        }
        else {
            $fragmentReport.findings[0]
        }
        $fragmentFinding.id = "$articlePath#location"
        Assert-ReportSchema $fragmentReport $false "$position citation id cannot append a fragment"
    }

    $duplicateLeafReport = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $duplicateLeafReport.'sub-results' = @($completedLeaf, $completedLeaf)
    Set-Content -LiteralPath $reportPath -Value ($duplicateLeafReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_DUPLICATE_SUB_RESULT*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super
    }

    $compositionPath = Join-Path $tmp 'composition.json'
    function Save-AcceptedLeafReports {
        param([object[]] $LeafReports)

        foreach ($leafReport in $LeafReports) {
            $leafPath = Join-Path $tmp "$([guid]::NewGuid()).json"
            Set-Content -LiteralPath $leafPath -Value ($leafReport | ConvertTo-Json -Depth 100) -Encoding utf8NoBOM
            $accepted = & $validator -ReportPath $leafPath -BCQualityRoot $Root
            Assert-True (-not $accepted.normalized) 'host captures a validated leaf report'
            @{ id = $leafReport.skill.id; version = $leafReport.skill.version; reportPath = $leafPath }
        }
    }

    $expectedComposition = [ordered]@{
        superSkill = @{ id = 'al-code-review'; version = 1 }
        subSkills = @(
            @{ id = 'al-style-review'; version = 1 }
            @{ id = 'al-security-review'; version = 1 }
        )
        skipped = @()
        acceptedResults = @(Save-AcceptedLeafReports @($completedLeaf, $completedSecurityLeaf))
    }
    Set-Content -LiteralPath $compositionPath -Value ($expectedComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Set-Content -LiteralPath $reportPath -Value ($validSuperReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $acceptedBoundSuper = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
        -ExpectedCompositionPath $compositionPath
    Assert-True (-not $acceptedBoundSuper.normalized) 'complete composition matches the expected worklist'

    $incompleteComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $incompleteComposition.acceptedResults = @($incompleteComposition.acceptedResults[0])
    Set-Content -LiteralPath $compositionPath -Value ($incompleteComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $missingLeafReport = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $missingLeafReport.'sub-results' = @($completedLeaf)
    $missingLeafReport.summary.coverage.'worklist-size' = 1
    $missingLeafReport.summary.coverage.'items-evaluated' = 1
    Set-Content -LiteralPath $reportPath -Value ($missingLeafReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*SUPER_OUTCOME_MISMATCH*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super -ExpectedCompositionPath $compositionPath
    }
    $missingLeafReport.outcome = 'partial'
    $missingLeafReport | Add-Member -NotePropertyName 'outcome-reason' -NotePropertyValue 'al-security-review was not evaluated before the budget expired.'
    Set-Content -LiteralPath $reportPath -Value ($missingLeafReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $acceptedIncompleteSuper = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
        -ExpectedCompositionPath $compositionPath
    Assert-True ($acceptedIncompleteSuper.report.outcome -ceq 'partial') 'unfinished selected leaves require a truthful partial outcome'

    function Assert-CompositionReport {
        param([object] $Candidate, [string] $ErrorPattern)

        Set-Content -LiteralPath $reportPath -Value ($Candidate | ConvertTo-Json -Depth 30) -Encoding utf8NoBOM
        if ($ErrorPattern) {
            Assert-ThrowsLike -Pattern $ErrorPattern -Action {
                & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
                    -ExpectedCompositionPath $compositionPath -AllowBoundedNormalization
            }
        }
        else {
            $accepted = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
                -ExpectedCompositionPath $compositionPath
            Assert-True (-not $accepted.normalized) 'valid expected composition is accepted without repairs'
        }
    }

    $genericMissingReason = $missingLeafReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $genericMissingReason.'outcome-reason' = 'Budget expired.'
    Assert-CompositionReport $genericMissingReason '*SUPER_MISSING_LEAF_REASON*'
    $genericMissingReason.'outcome-reason' = 'prefix-al-security-review-suffix was not evaluated.'
    Assert-CompositionReport $genericMissingReason '*SUPER_MISSING_LEAF_REASON*'

    foreach ($fabricatedOutcome in 'completed', 'not-applicable', 'no-knowledge') {
        $fabricatedLeafReport = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $fabricatedLeafReport.'sub-results'[1].outcome = $fabricatedOutcome
        if ($fabricatedOutcome -cne 'completed') {
            $fabricatedLeafReport.'sub-results'[1].summary.coverage.'worklist-size' = 0
            $fabricatedLeafReport.'sub-results'[1].summary.coverage.'items-evaluated' = 0
            $fabricatedLeafReport.summary.coverage.'worklist-size' = 1
            $fabricatedLeafReport.summary.coverage.'items-evaluated' = 1
        }
        Assert-CompositionReport $fabricatedLeafReport '*SUPER_LEAF_NOT_ACCEPTED*'
    }
    Set-Content -LiteralPath $compositionPath -Value ($expectedComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-CompositionReport $missingLeafReport '*SUPER_ACCEPTED_LEAF_MISSING*'
    $alteredLeafReport = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $alteredLeafReport.'sub-results'[1].summary.coverage.'worklist-size' = 2
    $alteredLeafReport.'sub-results'[1].summary.coverage.'items-evaluated' = 2
    $alteredLeafReport.summary.coverage.'worklist-size' = 3
    $alteredLeafReport.summary.coverage.'items-evaluated' = 3
    Assert-CompositionReport $alteredLeafReport '*SUPER_LEAF_CONTENT_MISMATCH*'
    $reorderedProperties = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $reorderedProperties.'sub-results'[0].skill = [pscustomobject]@{ version = 1; id = 'al-style-review' }
    Assert-CompositionReport $reorderedProperties
    foreach ($alteredOutcome in 'not-applicable', 'no-knowledge') {
        $alteredOutcomeReport = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $alteredOutcomeReport.'sub-results'[1].outcome = $alteredOutcome
        $alteredOutcomeReport.'sub-results'[1].summary.coverage.'worklist-size' = 0
        $alteredOutcomeReport.'sub-results'[1].summary.coverage.'items-evaluated' = 0
        $alteredOutcomeReport.summary.coverage.'worklist-size' = 1
        $alteredOutcomeReport.summary.coverage.'items-evaluated' = 1
        Assert-CompositionReport $alteredOutcomeReport '*SUPER_LEAF_CONTENT_MISMATCH*'
    }
    $relativeCaptureComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    foreach ($capture in $relativeCaptureComposition.acceptedResults) {
        $capture.reportPath = Split-Path -Leaf $capture.reportPath
    }
    Set-Content -LiteralPath $compositionPath -Value ($relativeCaptureComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-CompositionReport $validSuperReport
    $uncapturedComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $uncapturedComposition.PSObject.Properties.Remove('acceptedResults')
    Set-Content -LiteralPath $compositionPath -Value ($uncapturedComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-CompositionReport $validSuperReport '*Invalid expected composition*'
    $duplicateCaptureComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $duplicateCaptureComposition.acceptedResults = @($duplicateCaptureComposition.acceptedResults[0], $duplicateCaptureComposition.acceptedResults[0])
    Set-Content -LiteralPath $compositionPath -Value ($duplicateCaptureComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-CompositionReport $validSuperReport '*Invalid expected composition*'

    $capturedFindingLeaf = $completedLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $capturedFindingLeaf.findings = @(@{
        id = 'agent:leaf-issue'
        severity = 'minor'
        confidence = 'medium'
        message = 'Preserve this accepted leaf finding.'
        references = @()
    })
    $secondCapturedFinding = $capturedFindingLeaf.findings[0] | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $secondCapturedFinding.id = 'agent:second-leaf-issue'
    $capturedFindingLeaf.findings = @($capturedFindingLeaf.findings[0], $secondCapturedFinding)
    $capturedFindingLeaf.summary.counts.minor = 2
    $findingComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $findingComposition.acceptedResults = @(Save-AcceptedLeafReports @($capturedFindingLeaf, $completedSecurityLeaf))
    Set-Content -LiteralPath $compositionPath -Value ($findingComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $capturedFindingReport = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $capturedFindingReport.'sub-results'[0] = $capturedFindingLeaf
    $capturedFindingReport.findings = @($capturedFindingLeaf.findings | ConvertTo-Json -Depth 20 | ConvertFrom-Json)
    foreach ($finding in $capturedFindingReport.findings) {
        $finding.id = "al-style-review:$($finding.id)"
        $finding | Add-Member -NotePropertyName 'from-sub-skill' -NotePropertyValue 'al-style-review'
    }
    $capturedFindingReport.summary.counts.minor = 2
    Assert-CompositionReport $capturedFindingReport
    $reorderedFindingReport = $capturedFindingReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $reorderedFindingReport.'sub-results'[0].findings = @(
        $reorderedFindingReport.'sub-results'[0].findings[1]
        $reorderedFindingReport.'sub-results'[0].findings[0]
    )
    Assert-CompositionReport $reorderedFindingReport '*SUPER_LEAF_CONTENT_MISMATCH*'
    $addedLeafFieldReport = $capturedFindingReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $addedLeafFieldReport.'sub-results'[0] | Add-Member -NotePropertyName 'outcome-reason' -NotePropertyValue 'A composer-added field.'
    Assert-CompositionReport $addedLeafFieldReport '*SUPER_LEAF_CONTENT_MISMATCH*'
    $alteredFindingReport = $capturedFindingReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $alteredFindingReport.'sub-results'[0].findings[0].message = 'A fabricated replacement message.'
    $alteredFindingReport.findings[0].message = 'A fabricated replacement message.'
    Assert-CompositionReport $alteredFindingReport '*SUPER_LEAF_CONTENT_MISMATCH*'
    $removedFindingReport = $capturedFindingReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $removedFindingReport.'sub-results'[0].findings = @()
    $removedFindingReport.'sub-results'[0].summary.counts.minor = 0
    $removedFindingReport.findings = @()
    $removedFindingReport.summary.counts.minor = 0
    Assert-CompositionReport $removedFindingReport '*SUPER_LEAF_CONTENT_MISMATCH*'

    $capturedCorrectionLeaf = $capturedFindingLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $capturedCorrectionLeaf.findings[0] | Add-Member -NotePropertyName 'suggested-code' -NotePropertyValue 'exit(1);'
    $correctionComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $correctionComposition.acceptedResults = @(Save-AcceptedLeafReports @($capturedCorrectionLeaf, $completedSecurityLeaf))
    Set-Content -LiteralPath $compositionPath -Value ($correctionComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $capturedCorrectionReport = $capturedFindingReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $capturedCorrectionReport.'sub-results'[0] = $capturedCorrectionLeaf
    $capturedCorrectionReport.findings[0] | Add-Member -NotePropertyName 'suggested-code' -NotePropertyValue 'exit(1);'
    Assert-CompositionReport $capturedCorrectionReport
    $correctionCapturePath = $correctionComposition.acceptedResults[0].reportPath
    $immutableCorrectionCapture = [IO.File]::ReadAllText($correctionCapturePath)
    foreach ($codePoint in @(0x0000, 0x00AD, 0x200B, 0xFEFF)) {
        $alteredCorrectionReport = $capturedCorrectionReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $alteredCorrection = 'ex' + [char]$codePoint + 'it(1);'
        $alteredCorrectionReport.'sub-results'[0].findings[0].'suggested-code' = $alteredCorrection
        $alteredCorrectionReport.findings[0].'suggested-code' = $alteredCorrection
        Assert-CompositionReport $alteredCorrectionReport '*SUPER_LEAF_CONTENT_MISMATCH*'
        $rolledOnlyCorrectionReport = $capturedCorrectionReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $rolledOnlyCorrectionReport.findings[0].'suggested-code' = $alteredCorrection
        Assert-CompositionReport $rolledOnlyCorrectionReport '*SUPER_FINDING_MISMATCH*'
        Assert-True ([string]::Equals([IO.File]::ReadAllText($correctionCapturePath), $immutableCorrectionCapture, [StringComparison]::Ordinal)) `
            'rejecting altered corrections leaves the immutable host capture unchanged'
    }
    $timestampReason = '2026-10-02T09:00:00Z'
    $timestampLeaf = $completedLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $timestampLeaf | Add-Member -NotePropertyName 'outcome-reason' -NotePropertyValue $timestampReason
    $timestampComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $timestampComposition.acceptedResults = @(Save-AcceptedLeafReports @($timestampLeaf, $completedSecurityLeaf))
    Set-Content -LiteralPath $compositionPath -Value ($timestampComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $timestampReport = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $timestampReport.'sub-results'[0] = $timestampLeaf
    foreach ($alteredTimestamp in @('2026-10-02T09:00:00.000Z', '2026-10-02T09:00:00+00:00')) {
        $timestampLeaf.'outcome-reason' = $alteredTimestamp
        Assert-CompositionReport $timestampReport '*SUPER_LEAF_CONTENT_MISMATCH*'
    }
    $timestampLeaf.'outcome-reason' = $timestampReason
    Set-Content -LiteralPath $reportPath -Value ($timestampReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $acceptedTimestampReport = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SkillKind super `
        -ExpectedCompositionPath $compositionPath
    $acceptedReason = $acceptedTimestampReport.report.'sub-results'[0].'outcome-reason'
    Assert-True ($acceptedReason -is [string] -and [string]::Equals($acceptedReason, $timestampReason, [StringComparison]::Ordinal)) `
        'accepted timestamp-shaped JSON text remains the original literal string'
    $normalizedTimestampReport = $validReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $normalizedTimestampReport | Add-Member -NotePropertyName 'outcome-reason' -NotePropertyValue '2026-10-02T09:00:00.000Z'
    $normalizedTimestampReport.findings[0].location.range.'start-line' = 1
    Set-Content -LiteralPath $reportPath -Value ($normalizedTimestampReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $acceptedNormalizedTimestamp = & $validator -ReportPath $reportPath -BCQualityRoot $Root -SourceRoot $tmp `
        -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath -AllowBoundedNormalization
    Assert-True $acceptedNormalizedTimestamp.normalized 'bounded normalization still applies to an eligible range'
    Assert-True ($acceptedNormalizedTimestamp.report.'outcome-reason' -is [string] -and
        [string]::Equals($acceptedNormalizedTimestamp.report.'outcome-reason', $normalizedTimestampReport.'outcome-reason', [StringComparison]::Ordinal)) `
        'bounded normalization preserves unrelated timestamp-shaped text exactly'
    Set-Content -LiteralPath $compositionPath -Value ($expectedComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM

    foreach ($case in @(
        @{ Pattern = '*SUPER_IDENTITY_MISMATCH*'; Change = { param($candidate) $candidate.skill.id = 'al-other-review' } }
        @{ Pattern = '*SUPER_IDENTITY_MISMATCH*'; Change = { param($candidate) $candidate.skill.version = 2 } }
        @{ Pattern = '*SUPER_LEAF_VERSION_MISMATCH*'; Change = { param($candidate) $candidate.'sub-results'[0].skill.version = 2 } }
        @{ Pattern = '*SUPER_UNEXPECTED_SUB_RESULT*'; Change = { param($candidate) $candidate.'sub-results'[0].skill.id = 'al-other-review' } }
        @{ Pattern = '*SUPER_SUB_RESULT_ORDER*'; Change = { param($candidate) $candidate.'sub-results' = @($candidate.'sub-results'[1], $candidate.'sub-results'[0]) } }
        @{ Pattern = '*SUPER_DUPLICATE_SUB_RESULT*'; Change = { param($candidate) $candidate.'sub-results' = @($candidate.'sub-results'[0], $candidate.'sub-results'[0]) } }
    )) {
        $candidate = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        & $case.Change $candidate
        Assert-CompositionReport $candidate $case.Pattern
    }

    $fabricatedSkip = $missingLeafReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $fabricatedSkip | Add-Member -NotePropertyName 'skipped-sub-skills' -NotePropertyValue @(
        @{ skill = @{ id = 'al-security-review'; version = 1 }; reason = 'configuration' }
    )
    Assert-CompositionReport $fabricatedSkip '*SUPER_UNEXPECTED_SKIP*'

    $emptyAcceptedComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $emptyAcceptedComposition.acceptedResults = @()
    Set-Content -LiteralPath $compositionPath -Value ($emptyAcceptedComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $noResults = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $noResults.'sub-results' = @()
    $noResults.summary.coverage.'worklist-size' = 0
    $noResults.summary.coverage.'items-evaluated' = 0
    $noResults.outcome = 'not-applicable'
    Assert-CompositionReport $noResults '*SUPER_OUTCOME_MISMATCH*'
    $noResults.outcome = 'failed'
    $noResults | Add-Member -NotePropertyName 'outcome-reason' -NotePropertyValue 'al-style-review and al-security-review could not be evaluated.'
    Assert-CompositionReport $noResults

    $oneMissingId = $noResults | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $oneMissingId.'outcome-reason' = 'al-security-review could not be evaluated.'
    Assert-CompositionReport $oneMissingId '*SUPER_MISSING_LEAF_REASON*'
    foreach ($baseReport in @($missingLeafReport, $noResults, $validSuperReport)) {
        $capturedComposition = if ($baseReport.outcome -ceq 'completed') { $expectedComposition } else { $incompleteComposition }
        Set-Content -LiteralPath $compositionPath -Value ($capturedComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
        $selfReviewReport = $baseReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $selfReviewReport.findings = @(@{
            id = 'agent:cross-domain-gap'
            domain = 'Agent'
            severity = 'minor'
            confidence = 'medium'
            message = 'A cross-domain issue needs attention.'
            references = @()
            'from-sub-skill' = 'agent'
        })
        $selfReviewReport.summary.counts.minor = 1
        if ($baseReport.outcome -ceq 'completed') {
            Assert-CompositionReport $selfReviewReport
        }
        elseif ($baseReport.outcome -ceq 'failed') {
            Assert-CompositionReport $selfReviewReport '*Invalid findings-report JSON or schema*'
        }
        else {
            Assert-CompositionReport $selfReviewReport '*SUPER_AGENT_REVIEW_INCOMPLETE*'
        }
    }

    $allFailed = $noResults | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $allFailed.'sub-results' = @($completedLeaf, $completedSecurityLeaf) | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    foreach ($leaf in $allFailed.'sub-results') {
        $leaf.outcome = 'failed'
        $leaf.summary.coverage.'items-evaluated' = 0
        $leaf | Add-Member -NotePropertyName 'outcome-reason' -NotePropertyValue 'Invocation failed.'
    }
    $failedComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $failedComposition.acceptedResults = @(Save-AcceptedLeafReports $allFailed.'sub-results')
    Set-Content -LiteralPath $compositionPath -Value ($failedComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-CompositionReport $allFailed

    $skipComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $skipComposition.subSkills = @($skipComposition.subSkills[0])
    $skipComposition.skipped = @(@{ id = 'al-security-review'; version = 1; reason = 'not-applicable' })
    $skipComposition.acceptedResults = @($skipComposition.acceptedResults[0])
    Set-Content -LiteralPath $compositionPath -Value ($skipComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $validSkippedReport = $fabricatedSkip | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $validSkippedReport.outcome = 'completed'
    $validSkippedReport.PSObject.Properties.Remove('outcome-reason')
    $validSkippedReport.'skipped-sub-skills'[0].reason = 'not-applicable'
    Assert-CompositionReport $validSkippedReport
    Assert-CompositionReport $missingLeafReport '*SUPER_SKIP_MISSING*'
    $wrongSkip = $validSkippedReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $wrongSkip.'skipped-sub-skills'[0].reason = 'configuration'
    Assert-CompositionReport $wrongSkip '*SUPER_SKIP_MISMATCH*'
    $wrongSkip.'skipped-sub-skills'[0].reason = 'not-applicable'
    $wrongSkip.'skipped-sub-skills'[0].skill.version = 2
    Assert-CompositionReport $wrongSkip '*SUPER_SKIP_MISMATCH*'
    $duplicateSkip = $validSkippedReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $duplicateSkip.'skipped-sub-skills' = @($duplicateSkip.'skipped-sub-skills'[0], $duplicateSkip.'skipped-sub-skills'[0])
    Assert-CompositionReport $duplicateSkip '*SUPER_SKIP_CONFLICT*'
    $returnedAndSkipped = $validSkippedReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $returnedAndSkipped.'skipped-sub-skills'[0].skill.id = 'al-style-review'
    Assert-CompositionReport $returnedAndSkipped '*SUPER_SKIP_CONFLICT*'

    $allSkippedComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $allSkippedComposition.skipped = @($allSkippedComposition.subSkills | ForEach-Object {
        @{ id = $_.id; version = $_.version; reason = 'configuration' }
    })
    $allSkippedComposition.subSkills = @()
    $allSkippedComposition.acceptedResults = @()
    Set-Content -LiteralPath $compositionPath -Value ($allSkippedComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    $allSkippedReport = $noResults | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $allSkippedReport.outcome = 'not-applicable'
    $allSkippedReport.PSObject.Properties.Remove('outcome-reason')
    $allSkippedReport | Add-Member -NotePropertyName 'skipped-sub-skills' -NotePropertyValue @(
        $allSkippedComposition.skipped | ForEach-Object { @{ skill = @{ id = $_.id; version = $_.version }; reason = $_.reason } }
    )
    Assert-CompositionReport $allSkippedReport

    $invalidComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $invalidComposition.skipped = @(@{ id = 'al-style-review'; version = 1; reason = 'configuration' })
    Set-Content -LiteralPath $compositionPath -Value ($invalidComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-CompositionReport $validSuperReport '*Invalid expected composition*'
    $invalidComposition.skipped = @()
    $invalidComposition.subSkills[0].version = '1'
    Set-Content -LiteralPath $compositionPath -Value ($invalidComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-CompositionReport $validSuperReport '*Invalid expected composition*'
    Set-Content -LiteralPath $compositionPath -Value ($expectedComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM

    $layerFixtureRoot = Join-Path $tmp 'layered-skills'
    foreach ($layer in 'microsoft', 'community', 'custom') {
        $layerDirectory = Join-Path $layerFixtureRoot $layer
        New-Item -ItemType Directory -Path $layerDirectory -Force | Out-Null
        $sourceSkills = Join-Path $Root "$layer/skills"
        if (Test-Path -LiteralPath $sourceSkills -PathType Container) {
            Copy-Item -LiteralPath $sourceSkills -Destination (Join-Path $layerDirectory 'skills') -Recurse
        }
    }
    $customSkillDirectory = Join-Path $layerFixtureRoot 'custom/skills/review'
    New-Item -ItemType Directory -Path $customSkillDirectory -Force | Out-Null
    $customSkillPath = 'custom/skills/review/company-style-review.md'
    $styleSkillText = Get-Content -LiteralPath (Join-Path $Root 'microsoft/skills/review/al-style-review.md') -Raw
    Set-Content -LiteralPath (Join-Path $layerFixtureRoot $customSkillPath) `
        -Value ($styleSkillText -replace '(?m)^version: 1\r?$', 'version: 7') -Encoding utf8NoBOM
    $fixtureIndexPath = Join-Path $tmp 'layered-skill-index.json'
    & (Join-Path $Root 'tools/Build-SkillIndex.ps1') -BCQualityRoot $layerFixtureRoot -IndexPath $fixtureIndexPath | Out-Null
    $fixtureIndex = Get-Content -LiteralPath $fixtureIndexPath -Raw | ConvertFrom-Json
    foreach ($selection in @(
        @{ Disabled = @(); ExpectedLayer = 'custom'; ExpectedVersion = 7 }
        @{ Disabled = @($customSkillPath); ExpectedLayer = 'microsoft'; ExpectedVersion = 1 }
        @{ Disabled = @($customSkillPath, 'microsoft/skills/review/al-style-review.md'); ExpectedLayer = $null }
    )) {
        $resolved = & (Join-Path $Root 'tools/Resolve-SkillWorklist.ps1') -BCQualityRoot $layerFixtureRoot `
            -IndexPath $fixtureIndexPath -SuperSkillPath 'microsoft/skills/review/al-code-review.md' `
            -DisabledSkills $selection.Disabled
        $styleSlots = @($resolved.subSkills | Where-Object id -CEQ 'al-style-review')
        if ($selection.ExpectedLayer) {
            Assert-True ($styleSlots.Count -eq 1 -and $styleSlots[0].layer -ceq $selection.ExpectedLayer -and
                $styleSlots[0].version -eq $selection.ExpectedVersion) 'resolver-selected override or fallback is authoritative'
        }
        else {
            Assert-True ($styleSlots.Count -eq 0) 'fully disabled slot is not selected'
        }
        $resolved.skipped = @($resolved.skipped | ForEach-Object {
            $declaredPath = $_.declaredPath
            $declaredSkill = @($fixtureIndex.skills | Where-Object path -CEQ $declaredPath)[0]
            @{ id = $_.id; version = $declaredSkill.version; reason = $_.reason; declaredPath = $declaredPath }
        })
        $resolvedReport = $validSuperReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $resolvedReport.'sub-results' = @($resolved.subSkills | ForEach-Object {
            $leafReport = $completedLeaf | ConvertTo-Json -Depth 20 | ConvertFrom-Json
            $leafReport.skill.id = $_.id
            $leafReport.skill.version = $_.version
            $leafReport
        })
        $resolvedReport.summary.coverage.'worklist-size' = $resolved.subSkills.Count
        $resolvedReport.summary.coverage.'items-evaluated' = $resolved.subSkills.Count
        $resolvedReport | Add-Member -NotePropertyName 'skipped-sub-skills' -NotePropertyValue @(
            $resolved.skipped | ForEach-Object { @{ skill = @{ id = $_.id; version = $_.version }; reason = $_.reason } }
        )
        $resolved | Add-Member -NotePropertyName 'acceptedResults' -NotePropertyValue @(Save-AcceptedLeafReports $resolvedReport.'sub-results')
        Set-Content -LiteralPath $compositionPath -Value ($resolved | ConvertTo-Json -Depth 30) -Encoding utf8NoBOM
        Assert-CompositionReport $resolvedReport
    }
    Set-Content -LiteralPath $compositionPath -Value ($expectedComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM

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
    $partialComposition = $expectedComposition | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $partialComposition.acceptedResults = @(Save-AcceptedLeafReports @($completedLeaf, $failedLeaf))
    Set-Content -LiteralPath $compositionPath -Value ($partialComposition | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-CompositionReport $partialSuperReport

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
    $invalidAgentRaw = [IO.File]::ReadAllText($reportPath)
    Assert-ThrowsLike -Pattern '*Invalid findings-report JSON or schema*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SourceRoot $tmp -SourcePaths $sourcePath `
            -AllowBoundedNormalization
    }
    Assert-True ([IO.File]::ReadAllText($reportPath) -ceq $invalidAgentRaw) 'invalid agent payload is not silently repaired'

    $mismatchedCitation = $validReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $mismatchedCitation.findings[0].id = "${articlePath}:location"
    Assert-ReportSchema $mismatchedCitation $true 'cross-field citation equality still requires semantic validation'
    Set-Content -LiteralPath $reportPath -Value ($mismatchedCitation | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
    Assert-ThrowsLike -Pattern '*PRIMARY_REFERENCE_MISMATCH*' -Action {
        & $validator -ReportPath $reportPath -BCQualityRoot $Root -SourceRoot $tmp `
            -SourcePaths $sourcePath -RetrievedArticlePaths $articlePath -AllowBoundedNormalization
    }

    $finalSourcePath = 'src/final-snapshot.al'
    Set-Content -LiteralPath (Join-Path $tmp $finalSourcePath) -Value (1..22 | ForEach-Object { "line $_" }) -Encoding utf8NoBOM
    foreach ($bounds in @(
        @{ Line = 22; End = 22; Error = $null }
        @{ Line = 44; End = $null; Error = '*SOURCE_LINE_INVALID*' }
        @{ Line = 22; End = 44; Error = '*SOURCE_RANGE_INVALID*' }
    )) {
        $locationReport = $validReport | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $locationReport.findings[0].location = @{
            file = $finalSourcePath
            line = $bounds.Line
        }
        if ($bounds.End) {
            $locationReport.findings[0].location.range = @{ 'start-line' = $bounds.Line; 'end-line' = $bounds.End }
        }
        Assert-ReportSchema $locationReport $true 'schema alone cannot verify final-file line bounds'
        Set-Content -LiteralPath $reportPath -Value ($locationReport | ConvertTo-Json -Depth 20) -Encoding utf8NoBOM
        $locationRaw = [IO.File]::ReadAllText($reportPath)
        $validateLocation = {
            & $validator -ReportPath $reportPath -BCQualityRoot $Root -SourceRoot $tmp `
                -SourcePaths $finalSourcePath -RetrievedArticlePaths $articlePath -AllowBoundedNormalization
        }
        if ($bounds.Error) {
            Assert-ThrowsLike -Pattern $bounds.Error -Action $validateLocation
        }
        else {
            $acceptedLocation = & $validateLocation
            Assert-True (-not $acceptedLocation.normalized) 'the final source line is accepted without normalization'
        }
        Assert-True ([IO.File]::ReadAllText($reportPath) -ceq $locationRaw) 'source locations are never clamped in the raw payload'
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
