#!/usr/bin/env python3
"""Build a fully self-contained copy of the dashboard (no external network needed).

Reads  : /home/user/dashboard/index.html  (with CDN script/link tags)
Writes : /home/user/uploads/dye_house_dashboard.html  (everything inlined)

Inlines: Tailwind JIT script, SheetJS (XLSX) script, Font Awesome CSS (+woff2 data-URIs),
         Inter font CSS (latin subset, woff2 data-URIs).
"""
import base64, re, subprocess, sys, pathlib, tempfile, os

V = pathlib.Path('/home/user/dashboard/vendor')
SRC = pathlib.Path('/home/user/dashboard/index.html')
OUT = pathlib.Path('/home/user/uploads/dye_house_dashboard.html')

def b64(p):
    return base64.b64encode(p.read_bytes()).decode()

def fetch(url, dest):
    if not dest.exists():
        r = subprocess.run(['curl', '-sL', '-A',
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            url], capture_output=True)
        if r.returncode != 0 or len(r.stdout) < 500:
            raise SystemExit(f'failed to fetch {url}')
        dest.write_bytes(r.stdout)

page = SRC.read_text()

# --- 1. Tailwind (inline the JIT compiler) ---
tw = (V / 'tailwind.js').read_text()
if '</script' in tw.lower():
    tw = tw.replace('</script', r'<\/script')
old = '<script src="vendor/tailwind.js"></script>' if '<script src="vendor/tailwind.js"></script>' in page else '<script src="https://cdn.tailwindcss.com"></script>'
assert page.count(old) == 1, 'tailwind tag not found'
page = page.replace(old, '<script>' + tw + '</script>')

# --- 2. SheetJS / XLSX (inline) ---
xl = (V / 'xlsx.full.min.js').read_text()
if '</script' in xl.lower():
    xl = xl.replace('</script', r'<\/script')
old = '<script src="vendor/xlsx.full.min.js"></script>' if '<script src="vendor/xlsx.full.min.js"></script>' in page else '<script src="https://cdn.sheetjs.com/xlsx-0.20.2/package/dist/xlsx.full.min.js"></script>'
assert page.count(old) == 1, 'xlsx tag not found'
page = page.replace(old, '<script>' + xl + '</script>')

# --- 3. Font Awesome CSS with data-URI woff2 ---
fa = (V / 'fa-all.css').read_text()
def _fa_url(m):
    fname = m.group(1)
    if fname.endswith('.ttf'):  # woff2 covers all modern browsers; drop the ttf payload
        fname = fname[:-4] + '.woff2'
    p = V / fname
    if not p.exists():
        raise SystemExit('missing FA font file: ' + fname)
    return 'url(data:font/woff2;base64,' + b64(p) + ')'
# replace 'url(woff2) format("woff2"),url(ttf) format("truetype")' pairs -> single woff2 data URI
def _fa_pair(m):
    woff2 = m.group(1)
    p = V / woff2
    if not p.exists():
        raise SystemExit('missing FA font file: ' + woff2)
    return 'url(data:font/woff2;base64,' + b64(p) + ')'
fa = re.sub(r'url\((?:[^)]*?/)?webfonts/([\w.-]+\.woff2)\)\s*format\(["\']woff2["\']\)\s*,\s*url\((?:[^)]*?/)?webfonts/[\w.-]+\.ttf\)\s*format\(["\']truetype["\']\)', _fa_pair, fa)
fa = re.sub(r'url\((?:[^)]*?/)?webfonts/([\w.-]+\.woff2)\)', lambda m: 'url(data:font/woff2;base64,' + b64(V / m.group(1)) + ')', fa)
assert 'webfonts/' not in fa, 'unresolved FA font url'
old = '<link rel="stylesheet" href="vendor/fa-all.css">'
assert page.count(old) == 1
page = page.replace(old, '<style>\n' + fa + '\n</style>')

# --- 4. Inter font (latin subset only, woff2 data-URIs) ---
inter_css = (V / 'inter.css').read_text()
parts = re.split(r'/\* ([a-z-]+) \*/', inter_css)
# parts[0] = preamble, then (subset, block) pairs
latin = []
for i in range(1, len(parts) - 1, 2):
    subset, block = parts[i], parts[i + 1]
    if subset == 'latin':
        latin.append(block.strip())
assert len(latin) == 5, f'expected 5 latin font-face blocks, got {len(latin)}'
urls = sorted(set(re.findall(r'url\((https://fonts\.gstatic\.com[^)]+|inter_local\.woff2)\)', ' '.join(latin))))
cache = {}
for u in urls:
    if u.startswith('http'):
        fn = 'inter_' + re.search(r'/([^/]+)\.woff2$', u).group(1)[:24] + '.woff2'
        p = V / fn
        fetch(u, p)
        cache[u] = 'data:font/woff2;base64,' + b64(p)
    else:                                     # already rewritten to the local Inter woff2
        p = V / u
        if not p.exists():
            raise SystemExit('missing local Inter font: ' + u)
        cache[u] = 'data:font/woff2;base64,' + b64(p)
for u, d in cache.items():
    for blk_i in range(len(latin)):
        latin[blk_i] = latin[blk_i].replace(f'url({u})', f'url({d})')
assert 'gstatic.com' not in ' '.join(latin), 'unresolved font url'
assert 'url(inter_local.woff2)' not in ' '.join(latin), 'unresolved local font url'
kept_css = '\n'.join('/* latin */\n' + b for b in latin)
old = '<link rel="stylesheet" href="vendor/inter.css">'
assert page.count(old) == 1
page = page.replace(old, '<style>\n' + kept_css + '\n</style>')
page = page.replace('    <link rel="preconnect" href="https://fonts.googleapis.com">\n', '')
page = page.replace('    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>\n', '')

# --- sanity: no functional external refs left ---
leftover = set(re.findall(r'(?:src|href)="(https?://[^"]+)"', page))
assert not leftover, f'unexpected external refs: {leftover}'

OUT.write_text(page)
print(f'built {OUT} ({len(page):,} bytes) — external refs left: none')
