import json, os, sys
EGGS = r'C:\Users\RAYMO\dshcode\CCGSL\gitee_egg_repo\eggs'
bad = []
n = 0
for name in sorted(os.listdir(EGGS)):
    if not (name.startswith('egg-') and name.endswith('.json')):
        continue
    n += 1
    with open(os.path.join(EGGS, name), 'r', encoding='utf-8') as f:
        raw = f.read()
    try:
        json.loads(raw)
    except Exception as e:
        bad.append((name, str(e)[:120]))
print('eggs:', n, 'invalid:', len(bad))
for b in bad:
    print(b)
