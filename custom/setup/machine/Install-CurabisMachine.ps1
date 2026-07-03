# CURABIS maskin-onboarding - goer en frisk udviklermaskine klar til
# CURABIS Standard. Koeres EEN gang pr. maskine; er idempotent (sikker at
# koere igen). Alt hentes som raa bytes fra stable-kanalen.
#
# Torsten (eller enhver ny udvikler) koerer:
#   powershell -ExecutionPolicy Bypass -File Install-CurabisMachine.ps1
#
# Eller direkte fra BCQuality:
#   powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/Curabis/BCQuality/stable/custom/setup/machine/Install-CurabisMachine.ps1 -OutFile $env:TEMP\icm.ps1; & $env:TEMP\icm.ps1"
#
# Hvad der IKKE haandteres her (personligt/manuel):
#  - din client secret i ~/.bc-mcp.config.json (scriptet lægger templaten
#    og siger til)
#  - VS Code + AL Language-extensionen (ms-dynamics-smb.al fra Marketplace)
param(
    [string]$FullName,
    [string]$UserName
)

$ErrorActionPreference = 'Stop'
$raw    = 'https://raw.githubusercontent.com/Curabis/BCQuality/stable/custom/setup'
$claude = Join-Path $env:USERPROFILE '.claude'
New-Item -ItemType Directory -Force $claude | Out-Null

# Identitet: default fra git config, ellers spoerg
if (-not $FullName) { $FullName = (git config user.name 2>$null) }
if (-not $UserName) { $UserName = $env:USERNAME }
if (-not $FullName) { $FullName = Read-Host 'Dit fulde navn' }

$done = @()
$todo = @()

# 1. Global CLAUDE.md (fra template; overskriver ALDRIG en eksisterende)
$gcm = Join-Path $claude 'CLAUDE.md'
if (Test-Path $gcm) {
    $done += "CLAUDE.md fandtes allerede - ikke roert"
} else {
    Invoke-WebRequest -UseBasicParsing "$raw/machine/CLAUDE.md" -OutFile $gcm
    $t = [System.IO.File]::ReadAllText($gcm)
    $t = $t.Replace('[Your Name]', $FullName).Replace('[your-username]', $UserName)
    $t = $t -replace '<!-- Replace the two lines below with your own details -->\r?\n', ''
    [System.IO.File]::WriteAllText($gcm, $t, [System.Text.UTF8Encoding]::new($false))
    $done += "CLAUDE.md installeret ($FullName / $UserName)"
}

# 2. BC MCP bridge (stable er autoritativ - overskriv)
Invoke-WebRequest -UseBasicParsing "$raw/bc-mcp-bridge.js" -OutFile (Join-Path $claude 'bc-mcp-bridge.js')
$done += "bc-mcp-bridge.js installeret"

# 3. BC MCP config-template (personlig secret - aldrig overskrive)
$cfg = Join-Path $env:USERPROFILE '.bc-mcp.config.json'
if (Test-Path $cfg) {
    $done += "bc-mcp.config.json fandtes allerede - ikke roert"
} else {
    Invoke-WebRequest -UseBasicParsing "$raw/machine/bc-mcp.config.template.json" -OutFile $cfg
    $todo += "Aabn $cfg og indsaet din personlige client secret"
}

# 4. Knowledge-sync-script + mirror
Invoke-WebRequest -UseBasicParsing "$raw/sync-bcquality-knowledge.ps1" -OutFile (Join-Path $claude 'sync-bcquality-knowledge.ps1')
& powershell -ExecutionPolicy Bypass -File (Join-Path $claude 'sync-bcquality-knowledge.ps1')
$done += "bcquality-knowledge mirror synkroniseret"

# 5. Versionsmarkoer (stable-SHA)
try {
    $sha = (Invoke-RestMethod 'https://api.github.com/repos/Curabis/BCQuality/commits?sha=stable&per_page=1')[0].sha
    Set-Content -Path (Join-Path $claude '.bcquality-version') -Value $sha -Encoding ascii
    $done += "versionsmarkoer sat ($($sha.Substring(0,7)))"
} catch { $todo += "Kunne ikke saette versionsmarkoer (GitHub API) - foerste session goer det selv" }

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
Write-Host 'Code - den deployer selv .vscode/find-altool.ps1 og AL MCP-opsaetningen.'
Write-Host 'Genstart Claude Code efter foerste onboarding.'
