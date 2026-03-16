#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_FINAL_PAGES_BATCH_02_$(date +%Y%m%d_%H%M%S).md"
TEXT_DIR="worksheets/deltoid/rebuild_v2/source_text"
OUT_DIR="worksheets/deltoid/final_pages_batch_02"
PAGES_DIR="$OUT_DIR/pages"
INDEX_HTML="$OUT_DIR/index.html"
TEST_FILE="tests/deltoid-final-pages-batch-02.test.mjs"

mkdir -p "$PAGES_DIR" tests tools

python - <<'PYEOF'
from __future__ import annotations
from pathlib import Path
import json, re, html

pages = ["10","11","12","13","14"]

text_dir = Path("worksheets/deltoid/rebuild_v2/source_text")
out_dir = Path("worksheets/deltoid/final_pages_batch_02")
pages_dir = out_dir / "pages"
pages_dir.mkdir(parents=True, exist_ok=True)

records = []

def clean_text(t):
    t = t.replace("\x0c"," ")
    t = re.sub(r"\s+"," ",t)
    return t.strip()

def bullets_from_text(t):
    lines=[x.strip() for x in t.split(".") if x.strip()]
    return lines[:4]

for n in pages:

    page_num=int(n)
    txt_path=text_dir/f"page-{n}.txt"
    txt=txt_path.read_text(encoding="utf-8",errors="ignore") if txt_path.exists() else ""
    txt=clean_text(txt)

    bullets=bullets_from_text(txt)

    if not bullets:
        bullets=[f"עמוד {n}: נדרש ניסוח ידני מדויק מתוך עמוד המקור."]

    img_path=f"../../../../deltoid_pdf_analysis/images/page-{n}.png"

    blocks=[]

    for b in bullets:
        blocks.append(f'''
      <article class="question">
        <span class="question-bullet">●</span>
        <div class="question-body">{html.escape(b)}</div>
      </article>
''')

    page_html=f"""<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>עמוד {page_num}</title>
<link rel="stylesheet" href="../../../../styles/deltoid-rebuild-v2.css">
<style>
.final-head{{font-weight:700;font-size:18px;margin-bottom:4mm}}
.reference-block{{margin-top:8mm;border:1px solid #dbe4ee;border-radius:14px;padding:5mm;background:#fff}}
.reference-head{{font-weight:700;margin-bottom:3mm}}
.reference-image{{width:100%;height:auto;display:block;border:1px solid #cbd5e1;border-radius:10px}}
.meta-note{{margin-top:4mm;color:#475569;font-size:11.5pt;line-height:1.6}}
</style>
</head>

<body>

<main class="book-page">

<div class="page-number">{page_num}</div>

<section class="page-content">

<div class="final-head">עמוד {page_num} — batch 02</div>

{''.join(blocks)}

<section class="reference-block">
<div class="reference-head">עמוד מקור לבדיקה חזותית</div>
<img class="reference-image" src="{img_path}" alt="עמוד מקור {page_num}">
</section>

<div class="meta-note">
עמוד זה נבנה לפי חוקי הספר: אין מספור שאלות, כל שאלה מתחילה בבולט שחור מלא.
</div>

</section>

</main>

</body>
</html>
"""

    target=pages_dir/f"page-{n}.html"
    target.write_text(page_html,encoding="utf-8")

    records.append({
        "page":page_num,
        "bullet_count":len(bullets),
        "target_html":target.as_posix()
    })

index=[
"<!DOCTYPE html>",
'<html lang="he" dir="rtl">',
"<head>",
'<meta charset="utf-8">',
'<meta name="viewport" content="width=device-width, initial-scale=1.0">',
"<title>Deltoid final pages batch 02</title>",
'<link rel="stylesheet" href="../../../styles/deltoid-rebuild-v2.css">',
"</head>",
"<body>",
'<div class="index-shell">',
'<section class="index-hero">',
'<h1>Deltoid final pages — batch 02</h1>',
'<p>קבוצת העמודים השנייה שנבנתה מתוך טקסט המקור.</p>',
'</section>',
'<section class="index-grid">'
]

for r in records:

    n=r["page"]

    index+=[
'<article class="index-card">',
f'<div class="index-page-no">{n}</div>',
f'<h2>עמוד {n:02d}</h2>',
f'<div class="index-meta">bullets: {r["bullet_count"]}</div>',
f'<div class="index-actions"><a href="pages/page-{n:02d}.html" target="_blank">פתח עמוד</a></div>',
'</article>'
]

index+=["</section>","</div>","</body>","</html>"]

(out_dir/"index.html").write_text("\n".join(index),encoding="utf-8")

(out_dir/"batch_02_manifest.json").write_text(
json.dumps({"page_count":len(records),"records":records},ensure_ascii=False,indent=2),
encoding="utf-8"
)

print(json.dumps({"page_count":len(records),"pages":[r["page"] for r in records]},ensure_ascii=False,indent=2))

PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("batch 02 index exists", () => {
assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_02","index.html")),true);
});

test("batch 02 manifest exists", () => {
assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_02","batch_02_manifest.json")),true);
});

test("batch 02 has 5 pages", () => {
const dir=path.join("worksheets","deltoid","final_pages_batch_02","pages");
const files=fs.readdirSync(dir).filter(x=>/^page-\d{2}\.html$/i.test(x));
assert.equal(files.length,5);
});
EOF

npm test | tee deltoid_final_pages_batch_02_test_output.txt

{
echo "# Deltoid final pages batch 02"
echo
echo "- time: $(date -Iseconds)"
echo
echo "## tests"
cat deltoid_final_pages_batch_02_test_output.txt
echo
echo "## git status"
git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" deltoid_final_pages_batch_02_test_output.txt "$REPORT" tools/build_deltoid_final_pages_batch_02.sh

if ! git diff --cached --quiet; then
git commit -m "feat: build deltoid final pages batch 02"
git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "INDEX: $INDEX_HTML"

if command -v termux-open-url >/dev/null 2>&1; then
termux-open-url "http://127.0.0.1:5179/worksheets/deltoid/final_pages_batch_02/index.html"
fi

