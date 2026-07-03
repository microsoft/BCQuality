# CURABIS maskin-onboarding v2 (GIT-BASERET, privat repo) - goer en frisk
# udviklermaskine CURABIS-klar. Idempotent; sikker at koere igen.
#
# Onboarding paa en ny maskine er TO linjer (GCM-login i browseren ved
# foerste git-kontakt ER autentificeringen):
#
#   git clone --branch stable --single-branch https://github.com/Curabis/BCQuality.git "$env:USERPROFILE\.claude\BCQuality"
#   powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\BCQuality\custom\setup\machine\Install-CurabisMachine.ps1"
#
# Alt kopieres fra kanal-klonen (filsystem-kopi = raa bytes; ingen raw-URLs).
#
# Haandteres IKKE her (personligt/manuelt):
#  - din client secret i ~/.bc-mcp.config.json (templaten laegges, du udfylder)
#  - VS Code + AL Language-extensionen (ms-dynamics-smb.al fra Marketplace)
param(
    [string]$FullName,
    [string]$UserName
)

$ErrorActionPreference = 'Stop'
$claude = Join-Path $env:USERPROFILE '.claude'
$clone  = Join-Path $env:USERPROFILE '.claude\BCQuality'
New-Item -ItemType Directory -Force $claude | Out-Null

# Kilde: scriptet ligger i <klon>\custom\setup\machine → klonrod tre niveauer op
$src = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path

# Sikr kanal-klonen paa den kanoniske placering (scriptet KAN vaere koert fra en anden klon)
if (-not (Test-Path (Join-Path $clone '.git'))) {
    if ($src -ne $clone) {
        git clone --branch stable --single-branch 'https://github.com/Curabis/BCQuality.git' $clone
        if ($LASTEXITCODE -ne 0) { throw 'git clone af kanal-klonen fejlede - tjek adgang/GCM.' }
    }
}

if (-not $FullName) { $FullName = (git config user.name 2>$null) }
if (-not $UserName) { $UserName = $env:USERNAME }
if (-not $FullName) { $FullName = Read-Host 'Dit fulde navn' }

$done = @()
$todo = @()

# 1. Global CLAUDE.md (fra template i klonen; overskriver ALDRIG en eksisterende)
$gcm = Join-Path $claude 'CLAUDE.md'
if (Test-Path $gcm) {
    $done += 'CLAUDE.md fandtes allerede - ikke roert'
} else {
    Copy-Item (Join-Path $src 'custom\setup\machine\CLAUDE.md') $gcm
    $t = [System.IO.File]::ReadAllText($gcm)
    $t = $t.Replace('[Your Name]', $FullName).Replace('[your-username]', $UserName)
    $t = $t -replace '<!-- Replace the two lines below with your own details -->\r?\n', ''
    [System.IO.File]::WriteAllText($gcm, $t, [System.Text.UTF8Encoding]::new($false))
    $done += "CLAUDE.md installeret ($FullName / $UserName)"
}

# 2. BC MCP bridge (stable er autoritativ - overskriv)
Copy-Item (Join-Path $src 'custom\setup\bc-mcp-bridge.js') (Join-Path $claude 'bc-mcp-bridge.js') -Force
$done += 'bc-mcp-bridge.js installeret'

# 3. BC MCP config-template (personlig secret - aldrig overskrive)
$cfg = Join-Path $env:USERPROFILE '.bc-mcp.config.json'
if (Test-Path $cfg) {
    $done += 'bc-mcp.config.json fandtes allerede - ikke roert'
} else {
    Copy-Item (Join-Path $src 'custom\setup\machine\bc-mcp.config.template.json') $cfg
    $todo += "Aabn $cfg og indsaet din personlige client secret"
}

# 4. Sync-script til maskinen + koer det (bygger mirror + saetter versionsmarkoer)
Copy-Item (Join-Path $src 'custom\setup\sync-bcquality-knowledge.ps1') (Join-Path $claude 'sync-bcquality-knowledge.ps1') -Force
& powershell -ExecutionPolicy Bypass -File (Join-Path $claude 'sync-bcquality-knowledge.ps1')
$done += 'bcquality-knowledge mirror synkroniseret (git-baseret)'

Write-Host ''
Write-Host '=== CURABIS maskin-onboarding faerdig ===' -ForegroundColor Green
$done | ForEach-Object { Write-Host "  OK  $_" }
if ($todo) {
    Write-Host ''
    Write-Host 'Mangler (manuelt):' -ForegroundColor Yellow
    $todo | ForEach-Object { Write-Host "  !!  $_" -ForegroundColor Yellow }
}
Write-Host ''
Write-Host 'Pr. repo herefter: sig "Opdater CURABIS Standard fra BCQuality" i Claude'
Write-Host 'Code - den henter alt fra kanal-klonen. Genstart Claude Code foerst.'
