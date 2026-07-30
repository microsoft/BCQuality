# find-altool.ps1 - CURABIS-artefakt (deployes fra BCQuality, ikke genereret
# af AL-extensionen - der findes ingen VS Code-kommando til dette).
#
# v24: MASKIN-GLOBALT artefakt (%USERPROFILE%\.claude\find-altool.ps1),
# deployes af sync-bcquality-knowledge.ps1 - ligger IKKE i noget repo.
#
# Finder altool.exe dynamisk i den NYESTE installerede AL Language extension
# og videresender alle argumenter. Dette opslag er 100% maskinlokalt og har
# intet med repoet at goere.
#
# Specialargument 'auto': erstattes med alle AL-projektmapper fundet under
# det AKTUELLE repos apps-mappe (.apps/Apps/apps - mapper med app.json).
# Repo-roden findes IKKE via scriptets egen placering ($PSScriptRoot - det
# giver ~/.claude, hvilket er forkert nu scriptet er globalt) men ved at
# walke op fra cwd og lede efter en <appsName>\.AL-Go-markoer. Sessioner
# binder cwd til apps-workspace-mappen (en app-undermappe, ikke repo-roden),
# saa opslaget skal fungere uanset hvor i repoet cwd peger:
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
    # Walk op fra cwd og led efter <appsName>\.AL-Go som repo-rod-markoer.
    # Case-insensitive filsystem (Windows) betyder .apps/Apps/apps kan matche
    # den samme fysiske mappe flere gange - stop ved foerste match i stedet
    # for at tjekke alle tre ubetinget (undgaar dubletter i projektlisten).
    $d = (Get-Location).Path
    $repo = $null
    $appsFolderName = $null
    while ($d.Length -gt 3) {
        foreach ($appsName in @('.apps', 'Apps', 'apps')) {
            if (Test-Path (Join-Path $d "$appsName\.AL-Go")) {
                $repo = $d
                $appsFolderName = $appsName
                break
            }
        }
        if ($repo) { break }
        $d = Split-Path $d
    }
    if (-not $repo) {
        Write-Error "Ingen AL-Go repo-rod (<.apps|Apps|apps>\.AL-Go) fundet ved opadgaaende soegning fra $((Get-Location).Path)."
        exit 1
    }

    $appsDir = Join-Path $repo $appsFolderName
    $projects = Get-ChildItem $appsDir -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName 'app.json') } |
        ForEach-Object { $_.FullName }

    if (-not $projects) {
        Write-Error "Ingen AL-projektmapper (med app.json) fundet under $appsDir."
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
