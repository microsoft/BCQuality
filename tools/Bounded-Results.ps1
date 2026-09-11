# Shared deterministic paging. Callers build the complete immutable result first.
#requires -Version 7.2
Set-StrictMode -Version Latest

function Get-ResultSnapshot {
    param([Parameter(Mandatory)] $Value)

    $json = ConvertTo-Json -InputObject $Value -Depth 30 -Compress
    return [Convert]::ToHexString(
        [Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($json))
    ).ToLowerInvariant()
}

function Get-SerializedByteCount {
    param([Parameter(Mandatory)] [string] $Json)

    # PowerShell writes one platform newline after the returned JSON string.
    return [Text.Encoding]::UTF8.GetByteCount($Json) +
        [Text.Encoding]::UTF8.GetByteCount([Environment]::NewLine)
}

function ConvertTo-BoundedPage {
    param(
        [Parameter(Mandatory)] [Collections.IDictionary] $Header,
        [Parameter(Mandatory)] [Collections.IDictionary] $Groups,
        [ValidateRange(0, 2147483647)] [int] $Offset = 0,
        [string] $Snapshot,
        [ValidateRange(1024, 16000)] [int] $MaxBytes = 16000
    )

    $total = 0
    foreach ($name in $Groups.Keys) {
        $total += $Groups[$name].Count
    }
    if (($total -eq 0 -and $Offset -ne 0) -or ($total -gt 0 -and $Offset -ge $total)) {
        throw "Invalid Offset=$Offset for totalCount=$total; no rows were returned."
    }
    if ($Offset -gt 0 -and -not $Snapshot) {
        throw 'Continuation requires Snapshot from the preceding page.'
    }
    if ($Snapshot -and $Snapshot -cne $Header.snapshot) {
        throw 'Snapshot changed or continuation belongs to another request. Discard partial results and restart at Offset=0.'
    }

    $page = [ordered]@{}
    foreach ($key in $Header.Keys) {
        $page[$key] = $Header[$key]
    }
    $page.offset = $Offset
    $page.returnedCount = 0
    $page.totalCount = $total
    $page.remainingCount = $total - $Offset
    $page.complete = ($total -eq 0)
    $page.continuation = if ($total) {
        [ordered]@{ offset = $Offset; snapshot = $Header.snapshot }
    }
    else {
        $null
    }
    foreach ($name in $Groups.Keys) {
        $page[$name] = [Collections.Generic.List[object]]::new()
    }

    $json = ConvertTo-Json -InputObject $page -Depth 30 -Compress
    if ((Get-SerializedByteCount -Json $json) -gt $MaxBytes) {
        throw "Page envelope exceeds MaxBytes=$MaxBytes. Use READ's path-discovery fallback; never truncate."
    }

    $position = 0
    foreach ($name in $Groups.Keys) {
        foreach ($row in $Groups[$name]) {
            if ($position++ -lt $Offset) {
                continue
            }

            $page[$name].Add($row)
            $page.returnedCount++
            $page.remainingCount--
            $page.complete = ($page.remainingCount -eq 0)
            $page.continuation = if ($page.complete) {
                $null
            }
            else {
                [ordered]@{
                    offset = $Offset + $page.returnedCount
                    snapshot = $Header.snapshot
                }
            }

            $next = ConvertTo-Json -InputObject $page -Depth 30 -Compress
            if ((Get-SerializedByteCount -Json $next) -gt $MaxBytes) {
                $page[$name].RemoveAt($page[$name].Count - 1)
                $page.returnedCount--
                $page.remainingCount++
                $page.complete = $false
                $page.continuation = [ordered]@{
                    offset = $Offset + $page.returnedCount
                    snapshot = $Header.snapshot
                }
                if ($page.returnedCount -eq 0) {
                    $rowPath = $null
                    if ($row -is [Collections.IDictionary]) {
                        if ($row.Contains('path')) { $rowPath = $row['path'] }
                    }
                    elseif ($null -ne $row -and $row.PSObject.Properties['path']) {
                        $rowPath = $row.PSObject.Properties['path'].Value
                    }
                    $identity = if ($rowPath) { " at $rowPath" } else { " at Offset=$Offset" }
                    throw "One complete $name row plus envelope exceeds MaxBytes=$MaxBytes$identity. No row was clipped."
                }
                return $json
            }
            $json = $next
        }
    }
    return $json
}
