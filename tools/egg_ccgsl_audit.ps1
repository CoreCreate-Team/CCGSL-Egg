# CCGSL egg audit: mimics CCGSLSteamEgg::extractAppid (variables first,
# then install-script +app_update) using UTF-8 file reading.
param([string]$Repo = 'C:\Users\RAYMO\dshcode\CCGSL\gitee_egg_repo')
$ErrorActionPreference = 'SilentlyContinue'
$eggsDir = Join-Path $Repo 'eggs'

$rows = @()
Get-ChildItem $eggsDir -Filter 'egg-*.json' | ForEach-Object {
    $file = $_.Name
    $c = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $raw = $c | ConvertFrom-Json
    if (-not $raw) { Write-Host "PARSE FAIL: $file"; return }

    # extractAppid: variables first (env contains APPID / APP_ID / STEAM_ID)
    $appid = ''
    foreach ($v in @($raw.variables)) {
        if ($v -and $v.env_variable) {
            $env = $v.env_variable.ToUpper()
            if ($env.Contains('APPID') -or $env.Contains('APP_ID') -or $env.Contains('STEAM_ID')) {
                $appid = "$($v.default_value)".Trim()
                break
            }
        }
    }
    if (-not $appid) {
        $script = ''
        if ($raw.scripts -and $raw.scripts.installation) { $script = "$($raw.scripts.installation.script)" }
        $m = [regex]::Match($script, '\+app_update\s+(\d+)')
        if ($m.Success) { $appid = $m.Groups[1].Value }
    }
    # new: ccgsl block appid
    if (-not $appid) { if ($raw.ccgsl -and $raw.ccgsl.appid) { $appid = "$($raw.ccgsl.appid)" } }

    $ccgslUrl = ''
    if ($raw.ccgsl -and $raw.ccgsl.download_url) { $ccgslUrl = "$($raw.ccgsl.download_url)" }

    $rows += [pscustomobject]@{ File=$file; Name=$raw.name; Appid=$appid; Direct=$ccgslUrl }
}

Write-Host "total eggs: $($rows.Count)"
$withAppid = @($rows | Where-Object { $_.Appid })
Write-Host "with appid: $($withAppid.Count)"
$noAppid = @($rows | Where-Object { -not $_.Appid })
Write-Host "no appid: $($noAppid.Count)"
$withDirect = @($rows | Where-Object { $_.Direct })
Write-Host "with ccgsl direct: $($withDirect.Count)"
Write-Host ''
Write-Host '--- duplicate appids (variants legitimately sharing an appid) ---'
$rows | Where-Object { $_.Appid } | Group-Object Appid | Where-Object { $_.Count -gt 1 } | Sort-Object Name | ForEach-Object {
    Write-Host ("{0}: {1}" -f $_.Name, (($_.Group | ForEach-Object { "$($_.File)[$($_.Name)]" }) -join ', '))
}
Write-Host ''
Write-Host '--- eggs with appid=1007 (placeholder) ---'
$rows | Where-Object { $_.Appid -eq '1007' } | ForEach-Object { Write-Host "$($_.File) [$($_.Name)]" }
Write-Host ''
Write-Host '--- no-appid eggs (skipped today) ---'
$noAppid | ForEach-Object { Write-Host "$($_.File) [$($_.Name)]" }
$rows | ConvertTo-Json -Depth 3 | Set-Content (Join-Path $Repo 'tools\egg_ccgsl_audit.json') -Encoding UTF8
