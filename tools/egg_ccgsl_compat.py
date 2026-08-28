# -*- coding: utf-8 -*-
# CCGSL egg compatibility edit (Python): refetch originals from gitee master,
# insert `ccgsl` blocks + SERVER_PORT, rename egg-252 -> egg-terraria,
# validate everything, rebuild eggs-full-bundle.json + SteamIcons-list.json.
import json, re, urllib.request, os, sys

REPO = r'C:\Users\RAYMO\dshcode\CCGSL\gitee_egg_repo'
EGGS = os.path.join(REPO, 'eggs')
ICONS = os.path.join(REPO, 'SteamIcons')
RAW = 'https://gitee.com/shanghai-xinchuang-and-network/ccgsl-egg/raw/master/eggs/'

def fetch(name):
    req = urllib.request.Request(RAW + name, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read().decode('utf-8')

def eol_of(text):
    return '\r\n' if '\r\n' in text else '\n'

def insert_ccgsl(text, block):
    eol = eol_of(text)
    m = re.search(r'(?m)^(\s*)"scripts":', text)
    if not m:
        raise SystemExit('scripts anchor not found')
    indent = m.group(1)
    inner = eol.join(indent + line for line in block.strip().splitlines())
    return text[:m.start()] + indent + '"ccgsl": ' + inner + ',' + eol + text[m.start():]

def insert_server_port(text):
    eol = eol_of(text)
    var = ('        {' + eol +
           '            "name": "服务器端口",' + eol +
           '            "description": "游戏连接端口（默认 7777）。修改后请同步修改 serverconfig.txt 中的 port。",' + eol +
           '            "env_variable": "SERVER_PORT",' + eol +
           '            "default_value": "7777",' + eol +
           '            "user_viewable": true,' + eol +
           '            "user_editable": true,' + eol +
           '            "rules": "required|numeric|max:65535",' + eol +
           '            "field_type": "text"' + eol +
           '        },')
    m = re.search(r'("variables":\s*\[)', text)
    if not m:
        raise SystemExit('variables anchor not found')
    return text[:m.end()] + eol + var + text[m.end():]

# ---- 1) Terraria vanilla (egg-252 -> egg-terraria.json) ----
text = fetch('egg-252.json')
text = text.replace(
    'https://eggs.pterodactyl.top/eggs/252/download/egg-terraria-vanilla.json',
    'https://eggs.pterodactyl.top/eggs/252/download/egg-terraria.json')
text = insert_ccgsl(text, '''{
    "appid": "105600",
    "download_url": "https://terraria.org/api/download/pc-dedicated-server/terraria-server-1458.zip",
    "flatten_suffix": "Windows",
    "expected": "TerrariaServer.exe"
}''')
text = insert_server_port(text)
json.loads(text)  # validate
with open(os.path.join(EGGS, 'egg-terraria.json'), 'w', encoding='utf-8', newline='') as f:
    f.write(text)
print('egg-terraria.json ok')

# ---- 2) tShock ----
text = fetch('egg-tshock.json')
text = insert_ccgsl(text, '''{
    "appid": "105600",
    "download_url": "https://github.com/Pryaxis/TShock/releases/download/v6.1.0/TShock-6.1.0-for-Terraria-1.4.5.6-win-x64-Release.zip",
    "expected": "TShock.Server.exe"
}''')
text = insert_server_port(text)
json.loads(text)
with open(os.path.join(EGGS, 'egg-tshock.json'), 'w', encoding='utf-8', newline='') as f:
    f.write(text)
print('egg-tshock.json ok')

# ---- 3) tModLoader ----
text = fetch('egg-tmodloader.json')
text = insert_ccgsl(text, '''{
    "appid": "1281930",
    "download_url": "https://github.com/tModLoader/tModLoader/releases/latest/download/tModLoader.zip",
    "program": "start-tModLoaderServer.bat",
    "expected": "start-tModLoaderServer.bat"
}''')
text = insert_server_port(text)
json.loads(text)
with open(os.path.join(EGGS, 'egg-tmodloader.json'), 'w', encoding='utf-8', newline='') as f:
    f.write(text)
print('egg-tmodloader.json ok')

# ---- 4) remove the old numeric name (renamed) ----
old = os.path.join(EGGS, 'egg-252.json')
if os.path.exists(old):
    os.remove(old)
    print('egg-252.json removed (renamed to egg-terraria.json)')

# ---- 5) validate every egg + build bundle from RAW text ----
names = sorted(n for n in os.listdir(EGGS) if n.startswith('egg-') and n.endswith('.json'))
parts = []
for n in names:
    with open(os.path.join(EGGS, n), 'r', encoding='utf-8') as f:
        raw = f.read()
    json.loads(raw)  # every egg must stay valid JSON
    parts.append(json.dumps(n, ensure_ascii=False) + ':' + raw)
bundle = '{"files":{' + ','.join(parts) + '}}'
json.loads(bundle)
with open(os.path.join(REPO, 'eggs-full-bundle.json'), 'w', encoding='utf-8', newline='') as f:
    f.write(bundle)
with open(os.path.join(EGGS, 'eggs-full-bundle.json'), 'w', encoding='utf-8', newline='') as f:
    f.write(bundle)
print('eggs-full-bundle.json ok: %d eggs' % len(names))

# ---- 6) manifest ----
icons = sorted(n for n in os.listdir(ICONS) if n.lower().endswith('.jpg'))
manifest = json.dumps({'icons': icons}, ensure_ascii=False, indent=0)
with open(os.path.join(REPO, 'SteamIcons-list.json'), 'w', encoding='utf-8', newline='') as f:
    f.write(manifest)
print('SteamIcons-list.json ok: %d icons' % len(icons))

print('ALL DONE')
