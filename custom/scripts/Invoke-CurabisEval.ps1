# Invoke-CurabisEval.ps1
#
# Generel "hill climbing"-eval for ETHVERT CURABIS AL-projekt.
# Maaler det objektive signal paa succesfuld udfoersel: kompilerer koden, og er
# cop-analyzerne rene -> en score 0..1, logget over tid.
#
# Ingen projektspecifik logik:
#  - app-projekter auto-opdages via app.json
#  - analyzere + ruleset laeses fra projektets EGEN .vscode\settings.json
#    (saa scoren maales mod projektets bar, ikke harness'ens mening)
#
# Score:
#  - kompilerer ikke (errors > 0) -> 0.0  (du kan ikke klatre foer den bygger)
#  - ellers: 1 / (1 + WarnWeight * warnings)   (falder bloedt, floorer ikke)
#  Koer den, aendr EN ting, koer igen, og se trenden i .eval\history.jsonl.
#
# Brug:
#   pwsh -File scripts\Invoke-CurabisEval.ps1
#   pwsh -File scripts\Invoke-CurabisEval.ps1 -FailUnder 0.5      # CI-gate
#   pwsh -File scripts\Invoke-CurabisEval.ps1 -AppPath ".apps\summatim"

[CmdletBinding()]
param(
    # Repo-rod. Default: foraelder til scripts-mappen (altsaa projektroden).
    [string]$ProjectRoot,

    # Et eller flere app-projekter (mappe med app.json). Default: auto-opdag.
    [string[]]$AppPath,

    # Override af analyzere. Default: laes projektets egen al.codeAnalyzers.
    [ValidateSet('AppSourceCop', 'CodeCop', 'UICop', 'PerTenantExtensionCop')]
    [string[]]$Analyzers,

    # Vaegt pr. warning i scoren. errors er altid hard-fail -> 0.
    [double]$WarnWeight = 0.01,

    # Hvis sat: exit 1 naar samlet score < dette tal (til CI).
    [Nullable[double]]$FailUnder,

    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'

function Write-Line([string]$msg, [string]$color = 'Gray') {
    if (-not $Quiet) { Write-Host $msg -ForegroundColor $color }
}

# --- Find projektrod ---
if (-not $ProjectRoot) { $ProjectRoot = Split-Path -Parent $PSScriptRoot }
$ProjectRoot = (Resolve-Path $ProjectRoot).Path

# --- Find AL-compiler + analyzere i nyeste AL Language extension ---
$ext = Get-ChildItem "$env:USERPROFILE\.vscode\extensions" -Filter 'ms-dynamics-smb.al-*' -ErrorAction SilentlyContinue |
       Sort-Object Name -Descending | Select-Object -First 1
if (-not $ext) { throw 'AL Language extension ikke fundet. Installer ms-dynamics-smb.al.' }

$alc = Join-Path $ext.FullName 'bin\win32\alc.exe'
if (-not (Test-Path $alc)) { throw "alc.exe ikke fundet i $($ext.FullName)" }
$analyzerDir = Join-Path $ext.FullName 'bin\Analyzers'

# Map fra token/navn -> analyzer-DLL. Tager baade '${CodeCop}' og 'CodeCop'.
$analyzerDll = @{
    appsourcecop          = 'Microsoft.Dynamics.Nav.AppSourceCop.dll'
    codecop               = 'Microsoft.Dynamics.Nav.CodeCop.dll'
    uicop                 = 'Microsoft.Dynamics.Nav.UICop.dll'
    pertenantextensioncop = 'Microsoft.Dynamics.Nav.PerTenantExtensionCop.dll'
}

function Read-JsonC([string]$path) {
    # Laes JSON med // linje-kommentarer (VS Code settings er JSONC).
    $lines = Get-Content $path | Where-Object { $_.TrimStart() -notlike '//*' }
    ($lines -join "`n") | ConvertFrom-Json
}

function Resolve-AnalyzerEntry([string]$entry, [string]$appDir) {
    # Oversaetter en al.codeAnalyzers-entry til en DLL-sti. Haandterer:
    #  - kendte tokens: ${CodeCop} / CodeCop / ${AppSourceCop} osv.
    #  - custom DLL'er: ${analyzerFolder}BusinessCentral.LinterCop.dll
    #  - relative/absolutte stier til en .dll
    $key = ($entry -replace '[${}]', '').ToLower()
    if ($analyzerDll.ContainsKey($key)) { return (Join-Path $analyzerDir $analyzerDll[$key]) }
    $p = $entry -replace '\$\{analyzerFolder\}', ($analyzerDir + '\')
    if ($p -match '\$\{') { Write-Line "  !! kan ikke resolve analyzer: $entry" 'Yellow'; return $null }
    if (-not [System.IO.Path]::IsPathRooted($p)) { $p = Join-Path $appDir $p }
    return $p
}

function Resolve-Analyzers([string]$appDir) {
    # Praeferer projektets egen .vscode\settings.json; ellers -Analyzers/default.
    $entries = @()
    $settings = Join-Path $appDir '.vscode\settings.json'
    if (-not $Analyzers -and (Test-Path $settings)) {
        $s = Read-JsonC $settings
        $entries = @($s.'al.codeAnalyzers')
    }
    if (-not $entries -or $entries.Count -eq 0) {
        $entries = if ($Analyzers) { $Analyzers } else { @('${AppSourceCop}', '${CodeCop}', '${UICop}') }
    }
    $dlls = @()
    foreach ($e in $entries) {
        if (-not $e) { continue }
        $dll = Resolve-AnalyzerEntry $e $appDir
        if ($dll) {
            if (Test-Path $dll) { $dlls += $dll } else { Write-Line "  !! analyzer-DLL findes ikke: $dll" 'Yellow' }
        }
    }
    return ($dlls | Select-Object -Unique)
}

function Resolve-Ruleset([string]$appDir) {
    $settings = Join-Path $appDir '.vscode\settings.json'
    if (Test-Path $settings) {
        $s = Read-JsonC $settings
        $rs = $s.'al.ruleSetPath'
        if ($rs) {
            $p = if ([System.IO.Path]::IsPathRooted($rs)) { $rs } else { Join-Path $appDir $rs }
            if (Test-Path $p) { return (Resolve-Path $p).Path }
        }
    }
    return $null
}

# --- Find app-projekter ---
if (-not $AppPath) {
    $AppPath = Get-ChildItem -Path $ProjectRoot -Recurse -Filter 'app.json' -ErrorAction SilentlyContinue |
               Where-Object { $_.FullName -notmatch '\\\.alpackages\\' } |
               ForEach-Object { Split-Path $_.FullName -Parent }
}
else {
    $AppPath = $AppPath | ForEach-Object {
        if ([System.IO.Path]::IsPathRooted($_)) { $_ } else { Join-Path $ProjectRoot $_ }
    }
}
if (-not $AppPath) { throw "Ingen app.json fundet under $ProjectRoot" }

Write-Line "AL compiler : $alc" 'DarkGray'
Write-Line ''

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("curabis-eval-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

$appResults = @()

foreach ($app in $AppPath) {
    $app = (Resolve-Path $app).Path
    $manifest = Join-Path $app 'app.json'
    if (-not (Test-Path $manifest)) { Write-Line "  Springer over (ingen app.json): $app" 'Yellow'; continue }
    $appJson = Get-Content $manifest -Raw | ConvertFrom-Json
    $name = $appJson.name

    $analyzerDlls = Resolve-Analyzers $app
    $ruleset = Resolve-Ruleset $app
    $analyzerNames = $analyzerDlls | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) -replace '^Microsoft\.Dynamics\.Nav\.', '' }

    Write-Line "-> $name" 'Cyan'
    Write-Line ("   analyzere: {0}{1}" -f ($analyzerNames -join ', '), $(if ($ruleset) { " | ruleset: $(Split-Path $ruleset -Leaf)" } else { '' })) 'DarkGray'

    $errorLog = Join-Path $tmp ((Split-Path $app -Leaf) + '.json')
    $pkgCache = Join-Path $app '.alpackages'

    $alcArgs = @(
        "/project:$app",
        "/packagecachepath:$pkgCache",
        "/outfolder:$tmp",
        "/errorlog:$errorLog",
        '/loglevel:Warning'
    )
    foreach ($d in $analyzerDlls) { $alcArgs += "/analyzer:$d" }
    if ($ruleset) { $alcArgs += "/ruleset:$ruleset" }

    & $alc @alcArgs 2>&1 | Out-Null
    $alcExit = $LASTEXITCODE

    # --- Parse diagnostik ---
    # alc /errorlog skriver legacy-format (version 0.2): { issues: [ { ruleId,
    # properties.severity } ] }. Nyere compilere kan skrive SARIF 2.x
    # (runs[].results[].level). Vi haandterer begge.
    $errors = 0; $warnings = 0; $byRule = @{}
    if (Test-Path $errorLog) {
        $log = Get-Content $errorLog -Raw | ConvertFrom-Json
        $diags = @()
        if ($log.PSObject.Properties.Name -contains 'issues') {
            foreach ($i in $log.issues) { $diags += [PSCustomObject]@{ rule = "$($i.ruleId)"; sev = "$($i.properties.severity)" } }
        }
        elseif ($log.PSObject.Properties.Name -contains 'runs') {
            foreach ($run in $log.runs) { foreach ($r in $run.results) { $diags += [PSCustomObject]@{ rule = "$($r.ruleId)"; sev = "$($r.level)" } } }
        }
        foreach ($d in $diags) {
            $sev = $d.sev.ToLower()
            if ($sev -ne 'error' -and $sev -ne 'warning') { continue }   # spring Info over
            if ($sev -eq 'error') { $errors++ } else { $warnings++ }
            if ($d.rule) { if ($byRule.ContainsKey($d.rule)) { $byRule[$d.rule]++ } else { $byRule[$d.rule] = 1 } }
        }
    }
    elseif ($alcExit -ne 0) { $errors = 1 }

    # --- Score: errors = hard fail (0). Ellers bloed warning-kurve. ---
    if ($errors -gt 0) { $score = 0.0 }
    else { $score = [Math]::Round(1.0 / (1.0 + $WarnWeight * $warnings), 3) }

    $color = if ($errors -gt 0) { 'Red' } elseif ($warnings -gt 0) { 'Yellow' } else { 'Green' }
    Write-Line ("   errors={0}  warnings={1}  score={2}" -f $errors, $warnings, $score) $color

    # Top-overtraedelser (hjaelper med at vide hvad man skal fixe foerst)
    if (-not $Quiet -and $byRule.Count -gt 0) {
        $top = $byRule.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 5
        Write-Line ("   top: " + (($top | ForEach-Object { "$($_.Key)x$($_.Value)" }) -join '  ')) 'DarkGray'
    }

    $appResults += [PSCustomObject]@{
        app       = $name
        path      = $app
        analyzers = $analyzerNames
        ruleset   = $(if ($ruleset) { Split-Path $ruleset -Leaf } else { $null })
        errors    = $errors
        warnings  = $warnings
        byRule    = $byRule
        score     = $score
    }
}

# --- Samlet score = gennemsnit over apps ---
$overall = if ($appResults.Count -gt 0) { [Math]::Round(($appResults | Measure-Object -Property score -Average).Average, 3) } else { 0.0 }

$run = [PSCustomObject]@{
    timestamp = (Get-Date).ToString('o')
    overall   = $overall
    apps      = $appResults
}

# --- Skriv resultat + historik ---
$evalDir = Join-Path $ProjectRoot '.eval'
New-Item -ItemType Directory -Path $evalDir -Force | Out-Null
$run | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $evalDir 'last-run.json') -Encoding UTF8
($run | ConvertTo-Json -Depth 10 -Compress) | Add-Content (Join-Path $evalDir 'history.jsonl') -Encoding UTF8

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

Write-Line ''
Write-Line ("=== SAMLET SCORE: {0} ===" -f $overall) $(if ($overall -ge 0.9) { 'Green' } elseif ($overall -ge 0.5) { 'Yellow' } else { 'Red' })
Write-Line "Historik: $($evalDir)\history.jsonl" 'DarkGray'

# --- CI-gate ---
if ($null -ne $FailUnder -and $overall -lt $FailUnder) {
    Write-Line ("FAIL: score {0} < taerskel {1}" -f $overall, $FailUnder) 'Red'
    exit 1
}
exit 0
