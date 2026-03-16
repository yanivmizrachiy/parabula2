#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_FINAL_PAGES_BATCH_01_$(date +%Y%m%d_%H%M%S).md"
OUT_DIR="worksheets/deltoid/final_pages_batch_01"
PAGES_DIR="$OUT_DIR/pages"
INDEX_HTML="$OUT_DIR/index.html"
TEST_FILE="tests/deltoid-final-pages-batch-01.test.mjs"
CSS_FILE="styles/deltoid-rebuild-v2.css"

mkdir -p "$PAGES_DIR" tests tools

BATCH_PAGES=(09 38 41 42 56)

python - <<'PYEOF'
from __future__ import annotations
from pathlib import Path
import json
import html
import re

out_dir = Path("worksheets/deltoid/final_pages_batch_01")
pages_dir = out_dir / "pages"
pages_dir.mkdir(parents=True, exist_ok=True)

batch_pages = ["09","38","41","42","56"]
records = []

def clean_lines(text: str):
    text = text.replace("\x0c", " ")
    text = text.replace("\r", "\n")
    lines = [re.sub(r"\s+", " ", x).strip() for x in text.splitlines()]
    lines = [x for x in lines if x]
    return lines

def group_to_bullets(lines):
    bullets = []
    current = []
    for line in lines:
        if len(current) >= 3:
            bullets.append(" ".join(current).strip())
            current = [line]
        else:
            current.append(line)
    if current:
        bullets.append(" ".join(current).strip())
    return bullets[:6]

for n in batch_pages:
    page_num = int(n)
    txt_path = Path(f"worksheets/deltoid/rebuild_v2/source_text/page-{n}.txt")
    img_path = f"../../../../deltoid_pdf_analysis/images/page-{n}.png"

    raw = txt_path.read_text(encoding="utf-8", errors="ignore") if txt_path.exists() else ""
    lines = clean_lines(raw)
    bullets = group_to_bullets(lines)

    if not bullets:
        bullets = [f"טקסט המקור של עמוד {n} לא זוהה היטב. יש לבצע ניסוח ידני מדויק מתוך עמוד המקור."]

    blocks = []
    for bullet in bullets:
        blocks.append(f"""
      <article class="question">
        <span class="question-bullet">●</span>
        <div class="question-body">
          {html.escape(bullet)}
        </div>
      </article>
""")

    page_html = f"""<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>עמוד {page_num}</title>
  <link rel="stylesheet" href="../../../../styles/deltoid-rebuild-v2.css">
  <style>
    .final-head {{
      font-weight: 700;
      font-size: 18px;
      margin-bottom: 4mm;
    }}
    .reference-block {{
      margin-top: 8mm;
      border: 1px solid #dbe4ee;
      border-radius: 14px;
      padding: 5mm;
      background: #fff;
    }}
    .reference-head {{
      font-weight: 700;
      margin-bottom: 3mm;
    }}
    .reference-image {{
      width: 100%;
      height: auto;
      display: block;
      border: 1px solid #cbd5e1;
      border-radius: 10px;
    }}
    .meta-note {{
      margin-top: 4mm;
      color: #475569;
      font-size: 11.5pt;
      line-height: 1.6;
    }}
  </style>
</head>
<body>
  <main class="book-page">
    <div class="page-number">{page_num}</div>

    <section class="page-content">
      <div class="final-head">עמוד {page_num} — גרסת batch 01 סופית</div>

{''.join(blocks)}

      <section class="reference-block">
        <div class="reference-head">עמוד מקור לבדיקה חזותית</div>
        <img class="reference-image" src="{img_path}" alt="עמוד מקור {page_num}">
      </section>

      <div class="meta-note">
        העמוד הזה נבנה לפי חוקי הספר החדשים: אין מספור שאלות, יש מספור עמוד בלבד,
        וכל שאלה מתחילה בבולט שחור מלא.
      </div>
    </section>
  </main>
</body>
</html>
"""
    target = pages_dir / f"page-{n}.html"
    target.write_text(page_html, encoding="utf-8")

    records.append({
        "page": page_num,
        "source_text": txt_path.as_posix(),
        "target_html": target.as_posix(),
        "bullet_count": len(bullets)
    })

index = []
index += [
    "<!DOCTYPE html>",
    '<html lang="he" dir="rtl">',
    "<head>",
    '<meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
    "<title>Deltoid final pages batch 01</title>",
    '<link rel="stylesheet" href="../../../styles/deltoid-rebuild-v2.css">',
    "</head>",
    "<body>",
    '<div class="index-shell">',
    '<section class="index-hero">',
    '<h1>Deltoid final pages — batch 01</h1>',
    '<p>קבוצת העמודים הסופיים הראשונה שנבנתה מתוך טקסט מקור שחולץ ועם מבנה העיצוב החדש.</p>',
    '</section>',
    '<section class="index-grid">'
]
for r in records:
    n = r["page"]
    index += [
        '<article class="index-card">',
        f'<div class="index-page-no">{n}</div>',
        f'<h2>עמוד {n:02d}</h2>',
        f'<div class="index-meta">bullets: {r["bullet_count"]}</div>',
        f'<div class="index-actions"><a href="pages/page-{n:02d}.html" target="_blank">פתח עמוד</a></div>',
        '</article>'
    ]
index += ["</section>", "</div>", "</body>", "</html>"]
(out_dir / "index.html").write_text("\n".join(index) + "\n", encoding="utf-8")

(out_dir / "batch_01_manifest.json").write_text(
    json.dumps({"page_count": len(records), "records": records}, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

print(json.dumps({"page_count": len(records), "pages": [r["page"] for r in records]}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("final batch 01 index exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_01","index.html")), true);
});

test("final batch 01 manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_01","batch_01_manifest.json")), true);
});

test("final batch 01 has 5 pages", () => {
  const dir = path.join("worksheets","deltoid","final_pages_batch_01","pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.html$/i.test(x));
  assert.equal(files.length, 5);
});

test("final page has blue page number and no numbered question labels", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","final_pages_batch_01","pages","page-09.html"), "utf8");
  assert.ok(html.includes('class="page-number"'));
  assert.equal(/שאלה\s*\d+/u.test(html), false);
  assert.ok(html.includes('class="question-bullet">●<'));
});
EOF

if ! grep -q "Deltoid final pages batch 01" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deltoid final pages batch 01

- יש לבנות קבוצה ראשונה של עמודים סופיים תחת:
  `worksheets/deltoid/final_pages_batch_01/`
- batch_01 כולל:
  09, 38, 41, 42, 56
- כל העמודים ב-batch בנויים לפי page-number-only ו-bullet layout
EOF
fi

if ! grep -q "batch 01 סופי לדלתון" RULES.md; then
cat >> RULES.md <<'EOF'

---

## batch 01 סופי לדלתון

- הקבוצה הראשונה לעיבוד סופי כוללת:
  09, 38, 41, 42, 56
- כל עמוד חייב להציג ניסוח מקור משופר בלי מספור שאלות
EOF
fi

npm test | tee deltoid_final_pages_batch_01_test_output.txt

{
  echo "# Deltoid final pages batch 01"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## tests"
  cat deltoid_final_pages_batch_01_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md deltoid_final_pages_batch_01_test_output.txt "$REPORT" tools/build_deltoid_final_pages_batch_01.sh

if ! git diff --cached --quiet; then
  git commit -m "feat: build deltoid final pages batch 01"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "INDEX: $INDEX_HTML"

if command -v termux-open-url >/dev/null 2>&1; then
  termux-open-url "http://127.0.0.1:5179/worksheets/deltoid/final_pages_batch_01/index.html"
fi
