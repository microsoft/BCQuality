# find-altool.ps1 - CURABIS-artefakt (deployes fra BCQuality, ikke genereret
# af AL-extensionen - der findes ingen VS Code-kommando til dette).
#
# Finder altool.exe dynamisk i den NYESTE installerede AL Language extension
# og videresender alle argumenter. Scriptet er cwd-agnostisk: det ligger i
# <repo>\.vscode\ og kan derfor selv udlede repo-roden ($PSScriptRoot\..).
#
# Specialargument 'auto': erstattes med alle AL-projektmapper fundet under
# repoets apps-mappe (.apps/Apps/apps - mapper med app.json). Dermed er
# .mcp.json-entryen identisk paa tvaers af alle repos:
#   ... find-altool.ps1 launchmcpserver auto --transport stdio
#
# BEMAERK: altool launchmcpserver KRAEVER projektstier - uden doer serveren.

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

if ($args -contains 'auto') {
    $repo = Split-Path $PSScriptRoot
    $projects = @()
    foreach ($appsName in @('.apps', 'Apps', 'apps')) {
        $appsDir = Join-Path $repo $appsName
        if (Test-Path $appsDir) {
            $projects += Get-ChildItem $appsDir -Directory |
                Where-Object { Test-Path (Join-Path $_.FullName 'app.json') } |
                ForEach-Object { $_.FullName }
        }
    }
    if (-not $projects) {
        Write-Error "Ingen AL-projektmapper (med app.json) fundet under $repo\.apps|Apps|apps."
        exit 1
    }
    $resolved = @()
    foreach ($a in $args) {
        if ($a -eq 'auto') { $resolved += $projects } else { $resolved += $a }
    }
    & $altool @resolved
} else {
    & $altool @args
}
