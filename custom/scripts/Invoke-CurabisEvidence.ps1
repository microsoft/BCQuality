# Invoke-CurabisEvidence.ps1
#
# Validerer at hver citation i en gemt review/audit/triage-rapport peger paa noget
# der FAKTISK findes - hegnet mod hallucinerede henvisninger (jf. CURABIS-TRIAGE-005
# "cite or flag" og ALDC's validate_evidence.py).
#
# Tjekker to slags citationer:
#   1. Knowledge-filer  - BCQuality-URL'er eller relative stier (custom/.., microsoft/..)
#                         -> skal resolve mod en lokal BCQuality-klon eller via HTTP.
#   2. CURABIS-regelkoder - CURABIS-ARCH/TRIAGE/COMPLEXITY-NNN
#                         -> skal vaere defineret i .github\.agents\*.agent.md.
# (AL-diagnostikkoder som AS0084/AA0218 er Microsofts og valideres ikke her.)
#
# Exit 1 hvis en eneste citation ikke kan resolves (egnet til CI / PR-gate).
#
# Brug:
#   pwsh -File scripts\Invoke-CurabisEvidence.ps1 -ReportPath review.md
#   "AL Triage cited CURABIS-ARCH-002" | pwsh -File scripts\Invoke-CurabisEvidence.ps1

[CmdletBinding()]
param(
    # Rapportfil der skal valideres. Kan ogsaa pipes ind paa stdin.
    [Parameter(ValueFromPipeline = $true)]
    [string]$ReportPath,

    [string]$ProjectRoot,

    # Lokal BCQuality-klon. Default: proev ..\bcquality og .\.bcquality.
    [string]$BCQualityHome,

    # Bruges naar der ikke er en lokal klon: knowledge-filer HTTP-tjekkes herfra.
    [string]$RawBase = 'https://raw.githubusercontent.com/Curabis/BCQuality/main',

    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function Write-Line([string]$msg, [string]$color = 'Gray') {
    if (-not $Quiet) { Write-Host $msg -ForegroundColor $color }
}

# --- Projektrod ---
if (-not $ProjectRoot) { $ProjectRoot = Split-Path -Parent $PSScriptRoot }
$ProjectRoot = (Resolve-Path $ProjectRoot).Path

# --- Hent rapport-tekst (fil eller stdin) ---
$report = $null
if ($ReportPath -and (Test-Path $ReportPath)) {
    $report = Get-Content $ReportPath -Raw
}
elseif ($ReportPath) {
    # Ikke en sti -> behandl som raa tekst (fx pipet ind)
    $report = $ReportPath
}
if (-not $report) { throw "Ingen rapport. Angiv -ReportPath <fil> eller pipe tekst ind." }

# --- Find lokal BCQuality-klon ---
if (-not $BCQualityHome) {
    foreach ($c in @((Join-Path $ProjectRoot '..\bcquality'), (Join-Path $ProjectRoot '.bcquality'))) {
        if (Test-Path $c) { $BCQualityHome = (Resolve-Path $c).Path; break }
    }
}
$useLocal = [bool]$BCQualityHome -and (Test-Path $BCQualityHome)
Write-Line ("Validering: {0}" -f $(if ($useLocal) { "lokal klon $BCQualityHome" } else { "HTTP mod $RawBase" })) 'DarkGray'

# --- Udtraek citationer ---
# Knowledge-stier: fra URL'er (efter .../main/) og relative custom|microsoft|community-stier.
$paths = New-Object System.Collections.Generic.HashSet[string]
foreach ($m in [regex]::Matches($report, '(?<=BCQuality/(?:main|master)/)[^\s)\"''<>]+\.md')) { [void]$paths.Add($m.Value) }
foreach ($m in [regex]::Matches($report, '(?<![\w/])((?:custom|microsoft|community)/[^\s)\"''<>]+\.md)')) { [void]$paths.Add($m.Groups[1].Value) }

# CURABIS-regelkoder
$codes = New-Object System.Collections.Generic.HashSet[string]
foreach ($m in [regex]::Matches($report, 'CURABIS-[A-Z]+-\d+')) { [void]$codes.Add($m.Value) }

# --- Byg saet af gyldige regelkoder fra agent-filerne ---
$validCodes = New-Object System.Collections.Generic.HashSet[string]
$agentDir = Join-Path $ProjectRoot '.github\.agents'
if (Test-Path $agentDir) {
    foreach ($f in Get-ChildItem $agentDir -Filter '*.agent.md') {
        $txt = Get-Content $f.FullName -Raw
        foreach ($m in [regex]::Matches($txt, 'CURABIS-[A-Z]+-\d+')) { [void]$validCodes.Add($m.Value) }
    }
}

$results = @()

# --- Valider knowledge-filer ---
foreach ($p in $paths) {
    $ok = $false
    if ($useLocal) {
        $ok = Test-Path (Join-Path $BCQualityHome ($p -replace '/', '\'))
    }
    else {
        try {
            $resp = Invoke-WebRequest -Uri "$RawBase/$p" -Method Head -UseBasicParsing -TimeoutSec 15
            $ok = ($resp.StatusCode -eq 200)
        } catch { $ok = $false }
    }
    $results += [PSCustomObject]@{ kind = 'file'; citation = $p; resolved = $ok }
}

# --- Valider regelkoder ---
foreach ($c in $codes) {
    $results += [PSCustomObject]@{ kind = 'rule'; citation = $c; resolved = $validCodes.Contains($c) }
}

# --- Rapport ---
Write-Line ''
if ($results.Count -eq 0) {
    Write-Line 'Ingen citationer fundet i rapporten.' 'Yellow'
    exit 0
}

$missing = 0
foreach ($r in ($results | Sort-Object kind, citation)) {
    if ($r.resolved) { Write-Line ("  OK      [{0}] {1}" -f $r.kind, $r.citation) 'Green' }
    else { Write-Line ("  MISSING [{0}] {1}" -f $r.kind, $r.citation) 'Red'; $missing++ }
}

Write-Line ''
$total = $results.Count
if ($missing -gt 0) {
    Write-Line ("FAIL: {0}/{1} citationer kunne ikke resolves (hallucineret?)." -f $missing, $total) 'Red'
    exit 1
}
Write-Line ("OK: alle {0} citationer resolver." -f $total) 'Green'
exit 0
