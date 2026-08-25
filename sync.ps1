# 从本地 CCGSL 目录同步 eggs/SteamIcons 并推送到本仓库。
param(
    [string] = 'C:\Users\RAYMO\dshcode\CoreCreateGameServerLauncher-1.0.10-x64\CCGSL'
)
robocopy (Join-Path  'eggs') (Join-Path  'eggs') /E /NFL /NDL /NJH /NP | Out-Null
robocopy (Join-Path  'SteamIcons') (Join-Path  'SteamIcons') /E /NFL /NDL /NJH /NP | Out-Null
git add -A
git commit -m ('sync assets ' + (Get-Date -Format 'yyyy-MM-dd HH:mm'))
git push
Write-Output '已同步并推送'
