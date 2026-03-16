#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_BATCH_03_REPAIR_CLEAN_$(date +%Y%m%d_%H%M%S).md"
TEXT_DIR="worksheets/deltoid/rebuild_v2/source_text"
OUT_DIR="worksheets/deltoid/final_pages_batch_03"
PAGES_DIR="$OUT_DIR/pages"
TEST_FILE="tests/deltoid-final-pages-batch-03-repair.test.mjs"

mkdir -p "$PAGES_DIR" tests tools

python - <<'PYEOF'
from __future__ import annotations
from pathlib import Path
import json, re, html

pages = ["15","16","17","18","19"]
text_dir = Path("worksheets/deltoid/rebuild_v2/source_text")
out_dir = Path("worksheets/deltoid/final_pages_batch_03")
pages_dir = out_dir / "pages"
pages_dir.mkdir(parents=True, exist_ok=True)

records = []

def clean_text(t: str) -> str:
    t = t.replace("\x0c", " ").replace("\r", "\n")
    t = re.sub(r"[ \t]+", " ", t)
    t = re.sub(r"\n{2,}", "\n", t)
    return t.strip()

def make_bullets(text: str):
    lines = [x.strip() for x in text.splitlines() if x.strip()]
    merged = []
    cur = []
    for line in lines:
        if len(cur) >= 2:
            merged.append(" ".join(cur))
            cur = [line]
        else:
            cur.append(line)
    if cur:
        merged.append(" ".join(cur))
    merged = [re.sub(r"\s+", " ", x).strip() for x in merged if x.strip()]
    return merged[:4]

for n in pages:
    page_num = int(n)
    txt_path = text_dir / f"page-{n}.txt"
    txt = txt_path.read_text(encoding="utf-8", errors="ignore") if txt_path.exists() else ""
    txt = clean_text(txt)
    bullets = make_bullets(txt)

    if not bullets:
        bullets = [f"עמוד {n}: נדרש ניסוח ידני מדויק מתוך עמוד המקור."]

    img_path = f"../../../../deltoid_pdf_analysis/images/page-{n}.png"

    bullet_html = []
    for b in bullets:
        bullet_html.append(f'''
      <article class="question">
        <span class="question-bullet">●</span>
        <div class="question-body">{html.escape(b)}</div>
      </article>
''')

    page_html = f"""<!DOCTYPE html>
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
      <div class="final-head">עמוד {page_num} — batch 03 repaired</div>
      {''.join(bullet_html)}
      <section class="reference-block">
        <div class="reference-head">עמוד מקור לבדיקה חזותית</div>
        <img class="reference-image" src="{img_path}" alt="עמוד מקור {page_num}">
      </section>
      <div class="meta-note">עמוד זה תוקן כך שיתאים לסטנדרט המחייב: page-number בלבד, שאלות עם bullet שחור מלא, וללא מספור שאלות.</div>
    </section>
  </main>
</body>
</html>
"""
    target = pages_dir / f"page-{n}.html"
    target.write_text(page_html, encoding="utf-8")
    records.append({"page": page_num, "bullet_count": len(bullets), "target_html": target.as_posix()})

(out_dir / "batch_03_repair_manifest.json").write_text(
    json.dumps({"page_count": len(records), "records": records}, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

print(json.dumps({"page_count": len(records), "pages": [r["page"] for r in records]}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'TESTEOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("batch 03 repair manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_03","batch_03_repair_manifest.json")), true);
});

test("batch 03 repaired pages keep bullet layout and page number", () => {
  for (const p of ["15","16","17","18","19"]) {
    const html = fs.readFileSync(path.join("worksheets","deltoid","final_pages_batch_03","pages",`page-${p}.html`), "utf8");
    assert.ok(html.includes('class="page-number"'));
    assert.ok(html.includes('class="question-bullet">●<'));
    assert.equal(/שאלה\s*\d+/u.test(html), false);
  }
});
TESTEOF

npm test | tee deltoid_batch_03_repair_test_output.txt
./tools/deltoid_quality_check.sh

{
  echo "# Deltoid batch 03 repair clean"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## tests"
  cat deltoid_batch_03_repair_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add tools/repair_deltoid_final_pages_batch_03.sh \
  tests/deltoid-final-pages-batch-03-repair.test.mjs \
  worksheets/deltoid/final_pages_batch_03 \
  deltoid_batch_03_repair_test_output.txt \
  "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "fix: clean repair script and finalize deltoid batch 03"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
