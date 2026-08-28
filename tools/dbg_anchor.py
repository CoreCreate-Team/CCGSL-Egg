import re, urllib.request, json
RAW='https://gitee.com/shanghai-xinchuang-and-network/ccgsl-egg/raw/master/eggs/'
req=urllib.request.Request(RAW+'egg-252.json', headers={'User-Agent':'Mozilla/5.0'})
text=urllib.request.urlopen(req, timeout=60).read().decode('utf-8')

def eol_of(t): return '\r\n' if '\r\n' in t else '\n'

block = '''{
    "appid": "105600",
    "download_url": "https://terraria.org/api/download/pc-dedicated-server/terraria-server-1458.zip",
    "flatten_suffix": "Windows",
    "expected": "TerrariaServer.exe"
}'''
eol = eol_of(text)
m = re.search(r'(?m)^(\s*)"scripts":', text)
indent = m.group(1)
inner = eol.join((indent + '    ' + line) if line.strip() else ''
                 for line in block.strip().splitlines())
out = text[:m.start()] + indent + '"ccgsl": {' + eol + inner + eol + indent + '},' + eol + text[m.start():]
for i, l in enumerate(out.splitlines()[20:36], start=21):
    print(i, repr(l))
print('---')
try:
    json.loads(out)
    print('VALID')
except json.JSONDecodeError as e:
    print('ERROR:', e)
    print(repr(out[e.pos-80:e.pos+80]))
