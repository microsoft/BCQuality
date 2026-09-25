<#
.SYNOPSIS
    Validates a BCQuality findings-report against its structural and semantic contract.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $ReportPath,
    [string] $BCQualityRoot,
    [string] $SourceRoot,
    [string[]] $SourcePaths = @(),
    [string[]] $RetrievedArticlePaths = @(),
    [ValidateSet('leaf', 'super')]
    [string] $SkillKind = 'leaf',
    [switch] $AllowBoundedNormalization
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $BCQualityRoot) {
    $BCQualityRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}
$BCQualityRoot = (Resolve-Path -LiteralPath $BCQualityRoot).Path
$schemaPath = Join-Path $BCQualityRoot 'schemas/findings-report.schema.json'
$raw = Get-Content -LiteralPath $ReportPath -Raw
try {
    if (-not ($raw | Test-Json -SchemaFile $schemaPath -ErrorAction Stop)) {
        throw 'Report does not satisfy schemas/findings-report.schema.json.'
    }
    $report = $raw | ConvertFrom-Json -Depth 100
}
catch {
    throw "Invalid findings-report JSON or schema: $($_.Exception.Message)"
}

$retrieved = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
foreach ($path in $RetrievedArticlePaths) {
    $retrieved.Add($path) | Out-Null
}
$sources = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
foreach ($path in $SourcePaths) {
    $sources.Add($path) | Out-Null
}
$lineCounts = @{}

function Test-HasProperty {
    param([object] $Object, [string] $Name)
    return $null -ne $Object -and $Object.PSObject.Properties.Name -ccontains $Name
}

function Get-SourceLineCount {
    param([string] $Path)

    if ($lineCounts.ContainsKey($Path)) {
        return $lineCounts[$Path]
    }
    if (-not $SourceRoot) {
        return -1
    }
    $fullPath = Join-Path $SourceRoot ($Path -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        return -1
    }
    $lineCounts[$Path] = [IO.File]::ReadAllLines($fullPath).Count
    return $lineCounts[$Path]
}

function Get-SemanticErrors {
    param(
        [object] $Candidate,
        [switch] $PermitRangeStartMismatch
    )

    $errors = [Collections.Generic.List[object]]::new()
    function Add-Error {
        param([string] $Code, [string] $Path, [string] $Message)
        $errors.Add([pscustomobject]@{ Code = $Code; Path = $Path; Message = $Message }) | Out-Null
    }

    function Get-DerivedSuperOutcome {
        param([object[]] $SubResults)

        if (-not $SubResults.Count) {
            return 'not-applicable'
        }

        $outcomes = @($SubResults | ForEach-Object { $_.outcome })
        if (-not @($outcomes | Where-Object { $_ -cne 'failed' }).Count) {
            return 'failed'
        }
        if (($outcomes -ccontains 'partial') -or
            (($outcomes -ccontains 'failed') -and @($outcomes | Where-Object { $_ -cne 'failed' }).Count)) {
            return 'partial'
        }
        if (-not @($outcomes | Where-Object { $_ -cne 'not-applicable' }).Count) {
            return 'not-applicable'
        }
        if (($outcomes -ccontains 'no-knowledge') -and
            -not @($outcomes | Where-Object { $_ -cnotin @('no-knowledge', 'not-applicable') }).Count) {
            return 'no-knowledge'
        }
        return 'completed'
    }

    function Get-SeverityRank {
        param([string] $Severity)
        return @{'info' = 0; 'minor' = 1; 'major' = 2; 'blocker' = 3}[$Severity]
    }

    function Get-ConfidenceRank {
        param([string] $Confidence)
        return @{'low' = 0; 'medium' = 1; 'high' = 2}[$Confidence]
    }

    function Test-LocationsOverlap {
        param([object] $First, [object] $Second)

        $firstHasLocation = Test-HasProperty $First 'location'
        $secondHasLocation = Test-HasProperty $Second 'location'
        if ($firstHasLocation -ne $secondHasLocation) {
            return $false
        }
        if (-not $firstHasLocation) {
            return $false
        }
        if ($First.location.file -cne $Second.location.file) {
            return $false
        }
        $firstEnd = if (Test-HasProperty $First.location 'range') { $First.location.range.'end-line' } else { $First.location.line }
        $secondEnd = if (Test-HasProperty $Second.location 'range') { $Second.location.range.'end-line' } else { $Second.location.line }
        return $First.location.line -le $secondEnd -and $Second.location.line -le $firstEnd
    }

    function Test-SameCorrection {
        param([object] $First, [object] $Second)

        $firstHasCode = Test-HasProperty $First 'suggested-code'
        $secondHasCode = Test-HasProperty $Second 'suggested-code'
        if ($firstHasCode -or $secondHasCode) {
            return $firstHasCode -and $secondHasCode -and $First.'suggested-code' -ceq $Second.'suggested-code'
        }
        return $First.message -ceq $Second.message
    }

    function Test-ReferencesInclude {
        param([object[]] $RolledReferences, [object[]] $LeafReferences)

        foreach ($leafReference in $LeafReferences) {
            $matched = @($RolledReferences | Where-Object {
                if ($_.path -cne $leafReference.path) {
                    return $false
                }
                $rolledHasSha = Test-HasProperty $_ 'sha'
                $leafHasSha = Test-HasProperty $leafReference 'sha'
                return $rolledHasSha -eq $leafHasSha -and
                    (-not $rolledHasSha -or $_.sha -ceq $leafReference.sha)
            }).Count
            if (-not $matched) {
                return $false
            }
        }
        return $true
    }

    function Test-RolledFindingRepresents {
        param(
            [object] $RolledFinding,
            [object] $LeafFinding,
            [string] $LeafProducerId,
            [switch] $RequirePrimaryOwner
        )

        $rolledHasLocation = Test-HasProperty $RolledFinding 'location'
        $leafHasLocation = Test-HasProperty $LeafFinding 'location'
        $leafReferences = @($LeafFinding.references)
        $rolledReferences = @($RolledFinding.references)
        if (-not $rolledHasLocation -and -not $leafHasLocation) {
            $expectedId = if ($leafReferences.Count) { $LeafFinding.id } else { "${LeafProducerId}:$($LeafFinding.id)" }
            if ($RolledFinding.'from-sub-skill' -cne $LeafProducerId -or
                $RolledFinding.id -cne $expectedId -or
                $RolledFinding.severity -cne $LeafFinding.severity -or
                $RolledFinding.confidence -cne $LeafFinding.confidence -or
                $RolledFinding.message -cne $LeafFinding.message -or
                $rolledReferences.Count -ne $leafReferences.Count -or
                -not (Test-ReferencesInclude $rolledReferences $leafReferences)) {
                return $false
            }
            foreach ($name in 'domain', 'suggested-code', 'suggested-code-omission-reason') {
                $rolledHasProperty = Test-HasProperty $RolledFinding $name
                $leafHasProperty = Test-HasProperty $LeafFinding $name
                if ($rolledHasProperty -ne $leafHasProperty -or
                    ($rolledHasProperty -and $RolledFinding.$name -cne $LeafFinding.$name)) {
                    return $false
                }
            }
            return $true
        }

        if (-not (Test-LocationsOverlap $RolledFinding $LeafFinding) -or
            (Get-SeverityRank $RolledFinding.severity) -lt (Get-SeverityRank $LeafFinding.severity) -or
            (Get-ConfidenceRank $RolledFinding.confidence) -lt (Get-ConfidenceRank $LeafFinding.confidence)) {
            return $false
        }

        $sameCorrection = Test-SameCorrection $RolledFinding $LeafFinding
        $correctionsConflict = (Test-HasProperty $RolledFinding 'suggested-code') -and
            (Test-HasProperty $LeafFinding 'suggested-code') -and
            $RolledFinding.'suggested-code' -cne $LeafFinding.'suggested-code'
        $explicitCrossRuleMerge = $leafReferences.Count -and
            $rolledReferences.Count -gt $leafReferences.Count -and
            -not $correctionsConflict -and
            (Test-ReferencesInclude $rolledReferences $leafReferences)
        if (-not $sameCorrection -and -not $explicitCrossRuleMerge) {
            return $false
        }

        if (-not $leafReferences.Count) {
            return $RolledFinding.'from-sub-skill' -ceq $LeafProducerId -and
                $RolledFinding.id -ceq "${LeafProducerId}:$($LeafFinding.id)" -and
                -not $rolledReferences.Count
        }
        if (-not (Test-ReferencesInclude $rolledReferences $leafReferences)) {
            return $false
        }
        if ($RequirePrimaryOwner) {
            $rolledHasDomain = Test-HasProperty $RolledFinding 'domain'
            $leafHasDomain = Test-HasProperty $LeafFinding 'domain'
            return $RolledFinding.'from-sub-skill' -ceq $LeafProducerId -and
                $RolledFinding.id -ceq $LeafFinding.id -and
                @($RolledFinding.references)[0].path -ceq $leafReferences[0].path -and
                $rolledHasDomain -eq $leafHasDomain -and
                (-not $rolledHasDomain -or $RolledFinding.domain -ceq $LeafFinding.domain)
        }
        return $true
    }

    function Test-Report {
        param(
            [object] $Current,
            [string] $ReportPathPrefix,
            [ValidateSet('leaf', 'super')]
            [string] $CurrentSkillKind
        )

        $findings = @($Current.findings)
        foreach ($severity in 'blocker', 'major', 'minor', 'info') {
            $actual = @($findings | Where-Object severity -CEQ $severity).Count
            if ($Current.summary.counts.$severity -ne $actual) {
                Add-Error 'COUNT_MISMATCH' "$ReportPathPrefix.summary.counts.$severity" "Expected $actual."
            }
        }
        $worklistSize = $Current.summary.coverage.'worklist-size'
        $itemsEvaluated = $Current.summary.coverage.'items-evaluated'
        if ($itemsEvaluated -gt $worklistSize) {
            Add-Error 'COVERAGE_INVALID' "$ReportPathPrefix.summary.coverage" 'items-evaluated exceeds worklist-size.'
        }
        elseif ($Current.outcome -ceq 'completed' -and $itemsEvaluated -ne $worklistSize) {
            Add-Error 'COMPLETED_COVERAGE_INCOMPLETE' "$ReportPathPrefix.summary.coverage" 'A completed report must evaluate its full worklist.'
        }
        elseif ($CurrentSkillKind -ceq 'leaf' -and $Current.outcome -ceq 'partial' -and
            ($itemsEvaluated -le 0 -or $itemsEvaluated -ge $worklistSize)) {
            Add-Error 'PARTIAL_COVERAGE_INVALID' "$ReportPathPrefix.summary.coverage" 'A partial report must evaluate a non-zero proper subset of its worklist.'
        }

        $hasSubResults = Test-HasProperty $Current 'sub-results'
        $hasSkippedSubSkills = Test-HasProperty $Current 'skipped-sub-skills'
        if ($CurrentSkillKind -ceq 'leaf') {
            if ($hasSubResults -or $hasSkippedSubSkills) {
                Add-Error 'LEAF_COMPOSITION_INVALID' $ReportPathPrefix 'A leaf report must not contain sub-results or skipped-sub-skills.'
            }
        }
        elseif (-not $hasSubResults) {
            Add-Error 'SUPER_SUB_RESULTS_REQUIRED' $ReportPathPrefix 'A super-skill report must contain sub-results.'
        }

        for ($index = 0; $index -lt $findings.Count; $index++) {
            $finding = $findings[$index]
            $findingPath = "$ReportPathPrefix.findings[$index]"
            $references = @($finding.references)
            $hasProducer = Test-HasProperty $finding 'from-sub-skill'
            if ($CurrentSkillKind -ceq 'leaf' -and $hasProducer) {
                Add-Error 'LEAF_PRODUCER_INVALID' "$findingPath.from-sub-skill" 'A leaf finding must not contain from-sub-skill.'
            }
            elseif ($CurrentSkillKind -ceq 'super' -and -not $hasProducer) {
                Add-Error 'SUPER_PRODUCER_REQUIRED' $findingPath 'A super-skill finding must identify its producer in from-sub-skill.'
            }
            if (-not $references.Count) {
                if ($finding.id -cnotmatch '(^|:)agent:[a-z0-9]+(?:-[a-z0-9]+)*$') {
                    Add-Error 'AGENT_ID_INVALID' "$findingPath.id" 'An agent finding id must contain an agent: slug marker.'
                }
                if ($finding.confidence -ceq 'high') {
                    Add-Error 'AGENT_CONFIDENCE_INVALID' "$findingPath.confidence" 'Agent confidence cannot be high.'
                }
                if ($finding.severity -cin @('blocker', 'major')) {
                    Add-Error 'AGENT_SEVERITY_INVALID' "$findingPath.severity" 'Agent severity cannot exceed minor.'
                }
            }
            else {
                if ($finding.id -cne $references[0].path) {
                    Add-Error 'PRIMARY_REFERENCE_MISMATCH' "$findingPath.id" 'Finding id must equal the primary reference path.'
                }
                foreach ($reference in $references) {
                    if ($reference.path -cnotmatch '^(microsoft|community|custom)/knowledge/.+\.md$') {
                        Add-Error 'REFERENCE_PATH_INVALID' "$findingPath.references" "Invalid knowledge path '$($reference.path)'."
                        continue
                    }
                    if (-not (Test-Path -LiteralPath (Join-Path $BCQualityRoot $reference.path) -PathType Leaf)) {
                        Add-Error 'REFERENCE_MISSING' "$findingPath.references" "Knowledge path '$($reference.path)' does not exist."
                    }
                    if (-not $retrieved.Contains($reference.path)) {
                        Add-Error 'REFERENCE_NOT_RETRIEVED' "$findingPath.references" "Knowledge path '$($reference.path)' was not retrieved in full."
                    }
                }
            }

            if (Test-HasProperty $finding 'location') {
                $location = $finding.location
                if (-not $sources.Contains($location.file)) {
                    Add-Error 'SOURCE_OUT_OF_SCOPE' "$findingPath.location.file" "Source path '$($location.file)' is outside the supplied scope."
                }
                $lineCount = Get-SourceLineCount $location.file
                if ($lineCount -lt 0) {
                    Add-Error 'SOURCE_MISSING' "$findingPath.location.file" "Source path '$($location.file)' does not exist."
                }
                elseif ($location.line -gt $lineCount) {
                    Add-Error 'SOURCE_LINE_INVALID' "$findingPath.location.line" "Line exceeds the file's $lineCount lines."
                }

                if (Test-HasProperty $location 'range') {
                    $range = $location.range
                    if ($range.'start-line' -ne $location.line) {
                        Add-Error 'RANGE_START_MISMATCH' "$findingPath.location.range.start-line" 'start-line must equal line.'
                    }
                    if ($range.'end-line' -lt $range.'start-line' -or
                        ($lineCount -ge 0 -and $range.'end-line' -gt $lineCount)) {
                        Add-Error 'SOURCE_RANGE_INVALID' "$findingPath.location.range" 'Range is reversed or exceeds the source file.'
                    }
                }
            }
        }

        if ($CurrentSkillKind -ceq 'super' -and $hasSubResults) {
            $subResults = @($Current.'sub-results')
            for ($index = 0; $index -lt $subResults.Count; $index++) {
                Test-Report $subResults[$index] "$ReportPathPrefix.sub-results[$index]" 'leaf'
            }

            $expectedOutcome = Get-DerivedSuperOutcome $subResults
            if ($Current.outcome -cne $expectedOutcome) {
                Add-Error 'SUPER_OUTCOME_MISMATCH' "$ReportPathPrefix.outcome" "Expected '$expectedOutcome' from sub-results."
            }

            $includedSubResults = @($subResults | Where-Object outcome -CNE 'failed')
            $expectedWorklistSize = ($includedSubResults | Measure-Object -Property { $_.summary.coverage.'worklist-size' } -Sum).Sum
            $expectedItemsEvaluated = ($includedSubResults | Measure-Object -Property { $_.summary.coverage.'items-evaluated' } -Sum).Sum
            if ($null -eq $expectedWorklistSize) { $expectedWorklistSize = 0 }
            if ($null -eq $expectedItemsEvaluated) { $expectedItemsEvaluated = 0 }
            if ($worklistSize -ne $expectedWorklistSize -or $itemsEvaluated -ne $expectedItemsEvaluated) {
                Add-Error 'SUPER_COVERAGE_MISMATCH' "$ReportPathPrefix.summary.coverage" `
                    "Expected worklist-size $expectedWorklistSize and items-evaluated $expectedItemsEvaluated from non-failed sub-results."
            }

            $failedProducerIds = @($subResults | Where-Object outcome -CEQ 'failed' | ForEach-Object { $_.skill.id })
            $includedProducerIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
            $eligibleFindings = [Collections.Generic.List[object]]::new()
            foreach ($subResult in $includedSubResults) {
                $includedProducerIds.Add([string]$subResult.skill.id) | Out-Null
                foreach ($finding in @($subResult.findings)) {
                    $eligibleFindings.Add([pscustomobject]@{
                        ProducerId = [string]$subResult.skill.id
                        Finding = $finding
                    }) | Out-Null
                }
            }

            for ($index = 0; $index -lt $findings.Count; $index++) {
                $finding = $findings[$index]
                $producerId = [string]$finding.'from-sub-skill'
                if ($producerId -ceq 'agent') {
                    if (@($finding.references).Count -or
                        $finding.id -cnotmatch '^agent:[a-z0-9]+(?:-[a-z0-9]+)*$' -or
                        -not (Test-HasProperty $finding 'domain') -or
                        $finding.domain -cne 'Agent') {
                        Add-Error 'SUPER_AGENT_FINDING_INVALID' "$ReportPathPrefix.findings[$index]" `
                            'A super-skill agent finding must use an agent: id, Agent domain, and no references.'
                    }
                    continue
                }
                if ($producerId -cin $failedProducerIds) {
                    Add-Error 'SUPER_FAILED_FINDING_LEAKAGE' "$ReportPathPrefix.findings[$index].from-sub-skill" `
                        "Finding is attributed to failed sub-skill '$producerId'."
                    continue
                }
                if (-not $includedProducerIds.Contains($producerId)) {
                    Add-Error 'SUPER_PRODUCER_INVALID' "$ReportPathPrefix.findings[$index].from-sub-skill" `
                        "Sub-skill '$producerId' has no non-failed result."
                    continue
                }
                $ownedLeafFindings = @($eligibleFindings | Where-Object {
                    $_.ProducerId -ceq $producerId -and
                    (Test-RolledFindingRepresents $finding $_.Finding $_.ProducerId -RequirePrimaryOwner)
                })
                if (-not $ownedLeafFindings.Count) {
                    Add-Error 'SUPER_FINDING_MISMATCH' "$ReportPathPrefix.findings[$index]" `
                        "Rolled-up finding '$($finding.id)' is not owned by a matching finding from '$producerId'."
                    continue
                }
                $representedLeafFindings = @($eligibleFindings | Where-Object {
                    Test-RolledFindingRepresents $finding $_.Finding $_.ProducerId
                })
                $representedCorrections = @(
                    $representedLeafFindings |
                        Where-Object { Test-HasProperty $_.Finding 'suggested-code' } |
                        ForEach-Object { $_.Finding.'suggested-code' } |
                        Sort-Object -CaseSensitive -Unique
                )
                if ($representedCorrections.Count -gt 1) {
                    Add-Error 'SUPER_FINDING_MISMATCH' "$ReportPathPrefix.findings[$index]" `
                        "Rolled-up finding '$($finding.id)' represents leaf findings with conflicting suggested-code replacements."
                    continue
                }
                $expectedSeverityRank = ($representedLeafFindings | ForEach-Object { Get-SeverityRank $_.Finding.severity } | Measure-Object -Maximum).Maximum
                $expectedConfidenceRank = ($representedLeafFindings | ForEach-Object { Get-ConfidenceRank $_.Finding.confidence } | Measure-Object -Maximum).Maximum
                if ((Get-SeverityRank $finding.severity) -ne $expectedSeverityRank -or
                    (Get-ConfidenceRank $finding.confidence) -ne $expectedConfidenceRank) {
                    Add-Error 'SUPER_FINDING_MISMATCH' "$ReportPathPrefix.findings[$index]" `
                        "Rolled-up finding '$($finding.id)' must retain the highest severity and confidence justified by its represented leaf findings."
                }
            }

            for ($firstIndex = 0; $firstIndex -lt $findings.Count; $firstIndex++) {
                for ($secondIndex = $firstIndex + 1; $secondIndex -lt $findings.Count; $secondIndex++) {
                    if ((Test-HasProperty $findings[$firstIndex] 'location') -and
                        (Test-HasProperty $findings[$secondIndex] 'location') -and
                        (Test-LocationsOverlap $findings[$firstIndex] $findings[$secondIndex]) -and
                        (Test-SameCorrection $findings[$firstIndex] $findings[$secondIndex])) {
                        Add-Error 'SUPER_DUPLICATE_FINDINGS' "$ReportPathPrefix.findings[$secondIndex]" `
                            "Top-level findings $firstIndex and $secondIndex overlap and prescribe the same correction; they must be merged."
                    }
                }
            }

            $usedLocationlessFindings = [Collections.Generic.HashSet[int]]::new()
            foreach ($eligibleFinding in @($eligibleFindings | Where-Object { -not (Test-HasProperty $_.Finding 'location') })) {
                $matchingIndex = -1
                for ($index = 0; $index -lt $findings.Count; $index++) {
                    if (-not $usedLocationlessFindings.Contains($index) -and
                        -not (Test-HasProperty $findings[$index] 'location') -and
                        (Test-RolledFindingRepresents $findings[$index] $eligibleFinding.Finding $eligibleFinding.ProducerId)) {
                        $matchingIndex = $index
                        break
                    }
                }
                if ($matchingIndex -lt 0) {
                    Add-Error 'SUPER_FINDING_MISSING' "$ReportPathPrefix.findings" `
                        "No distinct rolled-up finding represents a locationless finding from '$($eligibleFinding.ProducerId)'."
                }
                else {
                    $usedLocationlessFindings.Add($matchingIndex) | Out-Null
                }
            }
            for ($index = 0; $index -lt $findings.Count; $index++) {
                if ($findings[$index].'from-sub-skill' -cne 'agent' -and
                    -not (Test-HasProperty $findings[$index] 'location') -and
                    -not $usedLocationlessFindings.Contains($index)) {
                    Add-Error 'SUPER_FINDING_MISMATCH' "$ReportPathPrefix.findings[$index]" `
                        'No distinct locationless leaf finding corresponds to this rolled-up finding.'
                }
            }

            foreach ($eligibleFinding in @($eligibleFindings | Where-Object { Test-HasProperty $_.Finding 'location' })) {
                $represented = @($findings | Where-Object {
                    $_.'from-sub-skill' -cne 'agent' -and
                    (Test-RolledFindingRepresents $_ $eligibleFinding.Finding $eligibleFinding.ProducerId)
                }).Count
                if (-not $represented) {
                    Add-Error 'SUPER_FINDING_MISSING' "$ReportPathPrefix.findings" `
                        "No valid rolled-up finding represents a finding from '$($eligibleFinding.ProducerId)' at its source location."
                }
            }
        }
    }

    Test-Report $Candidate '$' $SkillKind
    if ($PermitRangeStartMismatch) {
        return @($errors | Where-Object Code -CNE 'RANGE_START_MISMATCH')
    }
    return @($errors)
}

$errors = @(Get-SemanticErrors $report)
$normalized = $false
$removedRanges = [Collections.Generic.List[object]]::new()
if ($errors.Count -and $AllowBoundedNormalization) {
    $otherErrors = @($errors | Where-Object Code -CNE 'RANGE_START_MISMATCH')
    $rangeErrors = @($errors | Where-Object Code -CEQ 'RANGE_START_MISMATCH')
    if (-not $otherErrors.Count -and $rangeErrors.Count) {
        $candidate = $report | ConvertTo-Json -Depth 100 | ConvertFrom-Json -Depth 100
        $eligible = $true
        foreach ($finding in @($candidate.findings)) {
            if (-not (Test-HasProperty $finding 'location') -or
                -not (Test-HasProperty $finding.location 'range') -or
                $finding.location.range.'start-line' -eq $finding.location.line) {
                continue
            }
            $range = $finding.location.range
            if ($range.'start-line' -gt $finding.location.line -or
                $finding.location.line -gt $range.'end-line' -or
                (Test-HasProperty $finding 'suggested-code')) {
                $eligible = $false
                break
            }
            $removedRanges.Add([pscustomobject]@{
                findingId = $finding.id
                file = $finding.location.file
                line = $finding.location.line
                startLine = $range.'start-line'
                endLine = $range.'end-line'
            }) | Out-Null
            $finding.location.PSObject.Properties.Remove('range')
        }
        if ($eligible -and -not @(Get-SemanticErrors $candidate).Count) {
            $report = $candidate
            $normalized = $true
            $errors = @()
        }
    }
}

if ($errors.Count) {
    $details = @($errors | ForEach-Object { "$($_.Code) at $($_.Path): $($_.Message)" }) -join '; '
    throw "Findings-report acceptance failed: $details"
}

return [pscustomobject][ordered]@{
    normalized = $normalized
    report = $report
    removedRanges = @($removedRanges)
}