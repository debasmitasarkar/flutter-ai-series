# R08 survey: top web-supporting pub.dev packages by likes, latest version, which still import
# dart:html / dart:js / dart:js_util / package:js, and whether only via conditional imports.
import json, os, re, sys, tarfile, io, urllib.request, datetime
WORK = sys.argv[1]; N = int(sys.argv[2]) if len(sys.argv) > 2 else 100
os.makedirs(WORK, exist_ok=True)
import subprocess
def get(u):
    return subprocess.run(['curl', '-sSfL', '--max-time', '120', u], check=True, capture_output=True).stdout
names, page = [], 1
while len(names) < N:
    d = json.loads(get(f'https://pub.dev/api/search?q=platform%3Aweb&sort=like&page={page}'))
    names += [p['package'] for p in d['packages']]; page += 1
    if not d.get('next'): break
names = names[:N]
LIBS = ['dart:html', 'dart:js', 'dart:js_util', 'package:js/']
imp = re.compile(r"""^\s*(import|export)\s+['"]([^'"]+)['"]([^;]*);""", re.M | re.S)
cond = re.compile(r"""if\s*\(\s*dart\.library\.(\w+)\s*\)\s*['"]([^'"]+)['"]""")
rows = []
for n in names:
    info = json.loads(get(f'https://pub.dev/api/packages/{n}'))
    v = info['latest']; ver = v['version']; pub = v.get('published', '')
    tgz = get(v['archive_url']); direct, condl = set(), set()
    with tarfile.open(fileobj=io.BytesIO(tgz)) as t:
        for m in t.getmembers():
            if not (m.name.startswith('lib/') and m.name.endswith('.dart')): continue
            src = t.extractfile(m).read().decode('utf8', 'ignore')
            for kind, uri, rest in imp.findall(src):
                for L in LIBS:
                    if uri == L or uri.startswith(L) and L.endswith('/'):
                        direct.add((L.rstrip('/'), m.name))
                for lib, target in cond.findall(rest):
                    if lib in ('html', 'js', 'js_util'): condl.add(('dart.library.' + lib, m.name))
    rows.append(dict(package=n, version=ver, published=pub, direct=sorted(direct), conditional=sorted(condl)))
    print(n, ver, len(direct), len(condl), flush=True)
json.dump(dict(taken=datetime.datetime.now().isoformat(), rows=rows), open(os.path.join(WORK, 'survey.json'), 'w'), indent=1)
