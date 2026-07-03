# find-altool.ps1 - CURABIS-artefakt (deployes fra BCQuality, ikke genereret
# af AL-extensionen - der findes ingen VS Code-kommando til dette).
#
# Finder altool.exe dynamisk i den NYESTE installerede AL Language extension,
# uanset version, og videresender alle argumenter. Bruges af .mcp.json til at
# starte AL MCP-serveren - BEMÆRK: launchmcpserver KRÆVER projektstierne som
# argumenter, ellers dør serveren straks:
#   powershell -ExecutionPolicy Bypass -File .vscode/find-altool.ps1 launchmcpserver .apps/MinApp .apps/MinApp.Test --transport stdio

$ext = Get-ChildItem "$env:USERPROFILE\.vscode\extensions" -Filter "ms-dynamics-smb.al-*" -Directory |
       Sort-Object { [version]($_.Name -replace '^ms-dynamics-smb\.al-', '' -replace '-.*$', '') } -Descending |
       Select-Object -First 1

if (-not $ext) {
    Write-Error "AL Language extension ikke fundet. Installer ms-dynamics-smb.al fra VS Code Marketplace."
    exit 1
}

$altool = Join-Path $ext.FullName "bin\win32\altool.exe"

if (-not (Test-Path $altool)) {
    Write-Error "altool.exe ikke fundet i $($ext.FullName) - opdater AL-extensionen (MCP-serveren kraever en nyere version)."
    exit 1
}

& $altool @args
