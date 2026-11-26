#Requires -Version 7.5
<#
.SYNOPSIS
    Converts a BCQuality findings-report into a SARIF 2.1.0 log.

.DESCRIPTION
    Reads one findings-report (leaf or super-skill), validates it against
    schemas/findings-report.schema.json, and writes a SARIF 2.1.0 log that code
    scanning hosts such as GitHub and Azure DevOps can display as annotations.

    The converter is a presentation step. It does not replace the DO acceptance
    gate: run tools/Validate-FindingsReport.ps1 first and convert only accepted
    reports. The report is not modified.

    Mapping:
      - Only top-level findings are converted. A super-skill already copies
        accepted leaf findings to its top-level findings[], so converting
        sub-results as well would duplicate them.
      - findings[].id becomes the SARIF ruleId. Knowledge-backed IDs are article
        paths; their rule links to the article. Agent findings (agent:...) get a
        rule without a help link.
      - severity blocker/major -> error, minor -> warning, info -> note.
      - location.file/line/range -> physicalLocation relative to SRCROOT, prefixed
        with -SourcePathPrefix when the reviewed app is a sub-folder of the
        repository that the SARIF consumer analyzes.
      - severity, confidence, domain, references, from-sub-skill, and the code
        suggestion fields are kept in result.properties.
      - Findings without a location become tool execution notifications, not
        results, so GitHub code scanning can accept every emitted result.
        Notifications retain the finding ID, message, severity, and properties;
        run.properties.locationlessFindingCount records their count.
      - A partial or failed outcome sets executionSuccessful = false and is
        reported as a tool execution notification, so the log is never mistaken
        for a clean result.

.EXAMPLE
    pwsh ./tools/ConvertTo-Sarif.ps1 -ReportPath ./report.json -OutputPath ./bcquality.sarif
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $ReportPath,
    [string] $OutputPath,
    [string] $BCQualityRoot,
    [string] $SourcePathPrefix = '',
    [string] $KnowledgeBaseUrl = 'https://github.com/microsoft/BCQuality/blob/main/'
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
    $report = $raw | ConvertFrom-Json -Depth 100 -DateKind String
}
catch {
    throw "Invalid findings-report JSON or schema: $($_.Exception.Message)"
}

function Get-OptionalValue {
    param([object] $Object, [string] $Name)
    if ($null -ne $Object -and $Object.PSObject.Properties.Name -contains $Name) {
        return $Object.$Name
    }
    return $null
}

function Get-SarifLevel {
    param([string] $Severity)
    switch ($Severity) {
        'blocker' { 'error' }
        'major' { 'error' }
        'minor' { 'warning' }
        default { 'note' }
    }
}

function Get-ArticleTitle {
    param([string] $ArticlePath)
    $fullPath = Join-Path $BCQualityRoot $ArticlePath
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
        return $null
    }
    foreach ($line in Get-Content -LiteralPath $fullPath) {
        if ($line -match '^#\s+(.+)$') {
            return $Matches[1].Trim()
        }
    }
    return $null
}

$prefix = $SourcePathPrefix.Replace('\', '/').Trim('/')
$knowledgePattern = '^(microsoft|community|custom)/knowledge/[^/]+/[^/]+\.md$'

$rules = [Collections.Generic.List[object]]::new()
$ruleIndex = [Collections.Generic.Dictionary[string, int]]::new([StringComparer]::Ordinal)
$results = [Collections.Generic.List[object]]::new()
$notifications = [Collections.Generic.List[object]]::new()
$locationlessFindingCount = 0

foreach ($finding in @($report.findings)) {
    $ruleId = [string]$finding.id
    if (-not $ruleIndex.ContainsKey($ruleId)) {
        $rule = [ordered]@{ id = $ruleId }
        if ($ruleId -match $knowledgePattern) {
            $rule.name = [IO.Path]::GetFileNameWithoutExtension($ruleId)
            $title = Get-ArticleTitle $ruleId
            if ($title) {
                $rule.shortDescription = [ordered]@{ text = $title }
            }
            $rule.helpUri = $KnowledgeBaseUrl + $ruleId
        }
        else {
            $rule.name = 'agent-finding'
            $rule.shortDescription = [ordered]@{ text = 'Advisory finding without a BCQuality knowledge article.' }
        }
        $ruleIndex[$ruleId] = $rules.Count
        $rules.Add($rule) | Out-Null
    }

    $result = [ordered]@{
        ruleId = $ruleId
        ruleIndex = $ruleIndex[$ruleId]
        level = Get-SarifLevel ([string]$finding.severity)
        message = [ordered]@{ text = [string]$finding.message }
    }

    $location = Get-OptionalValue $finding 'location'
    if ($null -ne $location) {
        $file = ([string]$location.file).Replace('\', '/').TrimStart('/')
        if ($prefix) {
            $file = "$prefix/$file"
        }
        $fileUri = (($file.Split('/') | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/')
        $region = [ordered]@{ startLine = [int]$location.line }
        $range = Get-OptionalValue $location 'range'
        if ($null -ne $range) {
            $region.startLine = [int]$range.'start-line'
            $region.endLine = [int]$range.'end-line'
        }
        $result.locations = @(
            [ordered]@{
                physicalLocation = [ordered]@{
                    artifactLocation = [ordered]@{ uri = $fileUri; uriBaseId = 'SRCROOT' }
                    region = $region
                }
            }
        )
    }

    $properties = [ordered]@{
        severity = [string]$finding.severity
        confidence = [string]$finding.confidence
        references = @(@($finding.references) | ForEach-Object { [string]$_.path })
    }
    foreach ($name in 'domain', 'from-sub-skill', 'suggested-code', 'suggested-code-omission-reason') {
        $value = Get-OptionalValue $finding $name
        if ($null -ne $value) {
            $properties[$name] = [string]$value
        }
    }
    if ($null -eq $location) {
        $notifications.Add([ordered]@{
            level = $result.level
            message = [ordered]@{ text = "${ruleId}: $($finding.message)" }
            associatedRule = [ordered]@{ id = $ruleId; index = $ruleIndex[$ruleId] }
            properties = $properties
        }) | Out-Null
        $locationlessFindingCount++
    }
    else {
        $result.properties = $properties
        $results.Add($result) | Out-Null
    }
}

function Add-OutcomeNotifications {
    param([object] $SkillReport)
    $outcome = [string]$SkillReport.outcome
    if ($outcome -in @('partial', 'failed')) {
        $reason = [string](Get-OptionalValue $SkillReport 'outcome-reason')
        $notifications.Add([ordered]@{
            level = if ($outcome -eq 'failed') { 'error' } else { 'warning' }
            message = [ordered]@{ text = "$($SkillReport.skill.id) v$($SkillReport.skill.version): $outcome. $reason".Trim() }
        }) | Out-Null
    }
    foreach ($subResult in @(Get-OptionalValue $SkillReport 'sub-results')) {
        if ($null -ne $subResult) {
            Add-OutcomeNotifications $subResult
        }
    }
}
Add-OutcomeNotifications $report

$invocation = [ordered]@{
    executionSuccessful = ([string]$report.outcome) -in @('completed', 'not-applicable', 'no-knowledge')
}
if ($notifications.Count -gt 0) {
    $invocation.toolExecutionNotifications = @($notifications)
}

$sarif = [ordered]@{
    '$schema' = 'https://json.schemastore.org/sarif-2.1.0.json'
    version = '2.1.0'
    runs = @(
        [ordered]@{
            tool = [ordered]@{
                driver = [ordered]@{
                    name = 'BCQuality'
                    informationUri = 'https://github.com/microsoft/BCQuality'
                    rules = @($rules)
                }
            }
            invocations = @($invocation)
            originalUriBaseIds = [ordered]@{
                SRCROOT = [ordered]@{ description = [ordered]@{ text = 'Root of the analyzed source repository.' } }
            }
            results = @($results)
            properties = [ordered]@{
                skill = [ordered]@{ id = [string]$report.skill.id; version = [int]$report.skill.version }
                outcome = [string]$report.outcome
                locationlessFindingCount = $locationlessFindingCount
                suppressed = @(@($report.suppressed) | ForEach-Object {
                    [ordered]@{ path = [string]$_.reference.path; reason = [string]$_.reason }
                })
            }
        }
    )
}

$json = $sarif | ConvertTo-Json -Depth 30
if ($OutputPath) {
    Set-Content -LiteralPath $OutputPath -Value $json -Encoding utf8NoBOM
}
else {
    $json
}
