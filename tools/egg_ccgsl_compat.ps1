# CCGSL egg compatibility edit: adds `ccgsl` blocks (direct download for
# non-anonymous Steam apps), SERVER_PORT variables, renames egg-252 to
# egg-terraria, refreshes icons and rebuilds bundle/manifest.
$ErrorActionPreference = 'Stop'
$repo = 'C:\Users\RAYMO\dshcode\CCGSL\gitee_egg_repo'
$eggsDir = Join-Path $repo 'eggs'
$iconsDir = Join-Path $repo 'SteamIcons'
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8([string]$p) { [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8) }
function Write-Utf8([string]$p, [string]$t) { [System.IO.File]::WriteAllText($p, $t, $utf8) }

# 1) Terraria vanilla: rename egg-252.json -> egg-terraria.json, ccgsl block,
#    SERVER_PORT variable, update meta.update_url.
$p = Join-Path $eggsDir 'egg-252.json'
$c = Read-Utf8 $p
$ccgsl = @'
    "ccgsl": {
        "appid": "105600",
        "download_url": "https://terraria.org/api/download/pc-dedicated-server/terraria-server-1458.zip",
        "flatten_suffix": "Windows",
        "expected": "TerrariaServer.exe"
    },
'@
$c = [regex]::Replace($c, '(\r?\n\s*"scripts":\s*\{)', "`r`n$ccgsl`$1", 1)
$serverPort = @'
        {
            "name": "服务器端口",
            "description": "游戏连接端口（默认 7777）。修改后请同步修改 serverconfig.txt 中的 port。",
            "env_variable": "SERVER_PORT",
            "default_value": "7777",
            "user_viewable": true,
            "user_editable": true,
            "rules": "required|numeric|max:65535",
            "field_type": "text"
        },
'@
$c = [regex]::Replace($c, '("variables":\s*\[\s*\{)', "`$1`r`n$serverPort", 1)
$c = $c.Replace('https://eggs.pterodactyl.top/eggs/252/download/egg-terraria-vanilla.json',
                'https://eggs.pterodactyl.top/eggs/252/download/egg-terraria.json')
if ($c -match '"ccgsl"' -and $c -match 'SERVER_PORT') {
    Write-Utf8 $p $c
    Write-Host 'egg-252.json: ccgsl + SERVER_PORT inserted'
} else {
    throw 'egg-252.json edit anchors not found'
}

# 2) tShock: ccgsl block + SERVER_PORT variable.
$p = Join-Path $eggsDir 'egg-tshock.json'
$c = Read-Utf8 $p
$ccgsl = @'
    "ccgsl": {
        "appid": "105600",
        "download_url": "https://github.com/Pryaxis/TShock/releases/download/v6.1.0/TShock-6.1.0-for-Terraria-1.4.5.6-win-x64-Release.zip",
        "expected": "TShock.Server.exe"
    },
'@
$c = [regex]::Replace($c, '(\r?\n\s*"scripts":\s*\{)', "`n$ccgsl`$1", 1)
$serverPort = @'
        {
            "name": "服务器端口",
            "description": "游戏连接端口（默认 7777）。",
            "env_variable": "SERVER_PORT",
            "default_value": "7777",
            "user_viewable": true,
            "user_editable": true,
            "rules": "required|numeric|max:65535",
            "field_type": "text"
        },
'@
$c = [regex]::Replace($c, '("variables":\s*\[\s*\{)', "`$1`n$serverPort", 1)
if ($c -match '"ccgsl"' -and $c -match 'SERVER_PORT') {
    Write-Utf8 $p $c
    Write-Host 'egg-tshock.json: ccgsl + SERVER_PORT inserted'
} else {
    throw 'egg-tshock.json edit anchors not found'
}

# 3) tModLoader: ccgsl block (GitHub latest stable asset name) + program
#    override (start-tModLoaderServer.bat) + SERVER_PORT variable.
$p = Join-Path $eggsDir 'egg-tmodloader.json'
$c = Read-Utf8 $p
$ccgsl = @'
    "ccgsl": {
        "appid": "1281930",
        "download_url": "https://github.com/tModLoader/tModLoader/releases/latest/download/tModLoader.zip",
        "program": "start-tModLoaderServer.bat",
        "expected": "start-tModLoaderServer.bat"
    },
'@
$c = [regex]::Replace($c, '(\r?\n\s*"scripts":\s*\{)', "`r`n$ccgsl`$1", 1)
$serverPort = @'
        {
            "name": "服务器端口",
            "description": "游戏连接端口（默认 7777）。修改后请同步修改 serverconfig.txt 中的 port。",
            "env_variable": "SERVER_PORT",
            "default_value": "7777",
            "user_viewable": true,
            "user_editable": true,
            "rules": "required|numeric|max:65535",
            "field_type": "text"
        },
'@
$c = [regex]::Replace($c, '("variables":\s*\[\s*\{)', "`$1`r`n$serverPort", 1)
if ($c -match '"ccgsl"' -and $c -match 'SERVER_PORT') {
    Write-Utf8 $p $c
    Write-Host 'egg-tmodloader.json: ccgsl + SERVER_PORT inserted'
} else {
    throw 'egg-tmodloader.json edit anchors not found'
}

# 4) Rename egg-252.json -> egg-terraria.json (icon key "terraria" matches
#    SteamIcons/egg-terraria.jpg).
$old = Join-Path $eggsDir 'egg-252.json'
$new = Join-Path $eggsDir 'egg-terraria.json'
if (-not (Test-Path $old)) { throw 'egg-252.json missing' }
if (Test-Path $new) { Remove-Item $new -Force }
Move-Item $old $new -Force
Write-Host 'renamed egg-252.json -> egg-terraria.json'

# 5) Icons: tModLoader header from Steam CDN (app 1281930).
$out = Join-Path $iconsDir 'egg-tmodloader.jpg'
Invoke-WebRequest -Uri 'https://cdn.cloudflare.steamstatic.com/steam/apps/1281930/header.jpg' `
    -OutFile $out -UseBasicParsing -TimeoutSec 120
Write-Host "egg-tmodloader.jpg: $((Get-Item $out).Length) bytes"

# 6) Try to fetch a distinct tShock icon; keep the current one if nothing works.
$candidates = @(
    'https://raw.githubusercontent.com/Pryaxis/TShock/master/tshock.png',
    'https://raw.githubusercontent.com/Pryaxis/TShock/master/TShockLogo.png',
    'https://tshock.co/img/tshock-logo.png'
)
$got = $false
foreach ($u in $candidates) {
    try {
        $r = Invoke-WebRequest -Uri $u -UseBasicParsing -TimeoutSec 30
        if ($r.StatusCode -eq 200 -and $r.RawContentLength -gt 2000) {
            [System.IO.File]::WriteAllBytes((Join-Path $iconsDir 'egg-tshock.jpg'), $r.Content)
            Write-Host "tshock icon replaced from $u ($($r.RawContentLength) bytes)"
            $got = $true
            break
        }
    } catch { }
}
if (-not $got) { Write-Host 'tshock icon: kept existing file' }

# 7) Rebuild eggs-full-bundle.json (root copy + eggs/ copy the app loads).
$files = @{}
Get-ChildItem $eggsDir -Filter 'egg-*.json' | Sort-Object Name | ForEach-Object {
    $files[$_.Name] = (Read-Utf8 $_.FullName | ConvertFrom-Json)  # validate JSON only
}
$bundle = @{ files = @{} }
Get-ChildItem $eggsDir -Filter 'egg-*.json' | Sort-Object Name | ForEach-Object {
    $bundle.files[$_.Name] = (Read-Utf8 $_.FullName | ConvertFrom-Json)
}
$json = $bundle | ConvertTo-Json -Depth 100
Write-Utf8 (Join-Path $repo 'eggs-full-bundle.json') $json
Write-Utf8 (Join-Path $eggsDir 'eggs-full-bundle.json') $json
Write-Host "eggs-full-bundle.json rebuilt: $($bundle.files.Count) eggs"

# 8) Rebuild SteamIcons-list.json manifest.
$icons = @(Get-ChildItem $iconsDir -Filter '*.jpg' | Sort-Object Name | ForEach-Object { $_.Name })
$manifest = @{ icons = $icons } | ConvertTo-Json
Write-Utf8 (Join-Path $repo 'SteamIcons-list.json') $manifest
Write-Host "SteamIcons-list.json rebuilt: $($icons.Count) icons"

Write-Host 'ALL DONE'
