# CCGSL Egg 资源仓库

CCGSL(CoreCreateGameServerLauncher)的 Steam 游戏 egg 定义与 Steam 图标资源。

- `eggs/`  Pterodactyl egg JSON(游戏定义、启动命令、变量、RCON 信息)
  - `eggs/eggs-full-bundle.json`  全部 egg 的合并包(应用单请求加载,加载失败时回退逐个拉取)
- `SteamIcons/`  游戏图标(egg 风格头图,460×215)
- `SteamIcons-list.json`  图标清单(文件名数组)

应用启动后从本仓库 raw 地址按需拉取,不进行本地存储:
`https://gitee.com/shanghai-xinchuang-and-network/ccgsl-egg/raw/master/eggs/<file>.json`

## CCGSL 专属兼容块(ccgsl)

部分服务器不支持 SteamCMD 匿名下载(泰拉瑞亚、tShock、tModLoader 等),
egg 顶层可声明 `ccgsl` 块让 CCGSL 走直链下载部署(zip 解压安装):

```json
"ccgsl": {
    "appid": "105600",
    "download_url": "https://terraria.org/api/download/pc-dedicated-server/terraria-server-1458.zip",
    "flatten_suffix": "Windows",
    "expected": "TerrariaServer.exe",
    "program": "start-tModLoaderServer.bat"
}
```

- `appid`  用于卡片展示/图标匹配(可复用同款游戏的 AppID;同一 AppID
  允许多个变体 egg 并存,如 Palworld 与 Palworld Proton)
- `download_url`  直链 zip 地址(必填,存在即走直链部署,不走 SteamCMD)
- `flatten_suffix`  解压后要提升到安装根目录的子目录名(如 Terraria 的
  `1458/Windows` → `Windows`);留空且压缩包只有一个顶层目录时自动提升
- `expected`  安装完成后必须存在的启动程序文件名(部署产物校验)
- `program` / `args`  启动程序与参数覆盖(如 tModLoader 的
  `start-tModLoaderServer.bat`)
