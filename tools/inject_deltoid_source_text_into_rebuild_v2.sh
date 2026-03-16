#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_REBUILD_V2_SOURCE_TEXT_$(date +%Y%m%d_%H%M%S).md"
PDF="deltoid_pdf_analysis/book.pdf"
OUT_DIR="worksheets/deltoid/rebuild_v2"
PAGES_DIR="$OUT_DIR/pages"
TEXT_DIR="$OUT_DIR/source_text"
QUEUE_JSON="$OUT_DIR/config/content_queue.json"
TEST_FILE="tests/deltoid-rebuild-v2-source-text.test.mjs"

mkdir -p "$TEXT_DIR" tests tools

if [ ! -f "$PDF" ]; then
  echo "MISSING PDF: $PDF"
  exit 1
fi

if ! command -v pdftotext >/dev/null 2>&1; then
  pkg install -y poppler >/dev/null 2>&1 || true
fi

for i in $(seq 1 60); do
  n=$(printf "%02d" "$i")
  pdftotext -f "$i" -l "$i" "$PDF" "$TEXT_DIR/page-$n.raw.txt"
done

python - <<'PYEOF'
from __future__ import annotations
import json, re, html
from pathlib import Path

out_dir = Path("worksheets/deltoid/rebuild_v2")
pages_dir = out_dir / "pages"
text_dir = out_dir / "source_text"
queue_path = out_dir / "config" / "content_queue.json"

records = []

def clean_text(t: str) -> str:
    t = t.replace("\x0c", " ")
    t = t.replace("\r", "\n")
    t = re.sub(r"[ \t]+", " ", t)
    t = re.sub(r"\n{3,}", "\n\n", t)
    t = t.strip()
    return t

for i in range(1, 61):
    n = f"{i:02d}"
    raw_path = text_dir / f"page-{n}.raw.txt"
    txt_path = text_dir / f"page-{n}.txt"
    page_path = pages_dir / f"page-{n}.html"

    raw = raw_path.read_text(encoding="utf-8", errors="ignore") if raw_path.exists() else ""
    clean = clean_text(raw)
    txt_path.write_text(clean + ("\n" if clean else ""), encoding="utf-8")

    source_img = f"../../../../deltoid_pdf_analysis/images/page-{n}.png"

    source_text_html = html.escape(clean if clean else "לא זוהה טקסט בעמוד זה.")
    body = f"""<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>עמוד {n}</title>
  <link rel="stylesheet" href="../../../../styles/deltoid-rebuild-v2.css">
  <style>
    .source-text-wrap {{
      margin-top: 10mm;
      border: 1px solid #dbe4ee;
      border-radius: 14px;
      background: #fff;
      padding: 5mm;
    }}
    .source-text-head {{
      font-weight: 700;
      margin-bottom: 3mm;
    }}
    .source-text {{
      white-space: pre-wrap;
      line-height: 1.8;
      font-size: 12.5pt;
      color: #334155;
    }}
  </style>
</head>
<body>
  <main class="book-page">
    <div class="page-number">{i}</div>

    <section class="page-content">

      <article class="question">
        <span class="question-bullet">●</span>
        <div class="question-body">
          <div class="placeholder-title">ניסוח מקור מהעמוד</div>
          <div class="placeholder-text">
            השלב הבא הוא עריכה מתמטית מקצועית של הטקסט הזה לפי כללי הספר:
            ללא מספור שאלות, עם ניסוח אחיד, ועם חלוקה נכונה לבולטים וסעיפים.
          </div>
        </div>
      </article>

      <section class="source-text-wrap">
        <div class="source-text-head">טקסט מקור שחולץ מהעמוד</div>
        <div class="source-text">{source_text_html}</div>
      </section>

      <section class="reference-block">
        <div class="reference-head">עמוד מקור לעבודה</div>
        <img class="reference-image" src="{source_img}" alt="עמוד מקור {i}">
      </section>

    </section>
  </main>
</body>
</html>
"""
    page_path.write_text(body, encoding="utf-8")

    records.append({
        "page": i,
        "source_text_file": txt_path.as_posix(),
        "target_html": page_path.as_posix(),
        "char_count": len(clean),
        "has_text": bool(clean)
    })

queue_path.write_text(
    json.dumps({
        "page_count": len(records),
        "records": records
    }, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

print(json.dumps({
    "page_count": len(records),
    "pages_with_text": sum(1 for r in records if r["has_text"]),
    "pages_without_text": sum(1 for r in records if not r["has_text"])
}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("rebuild v2 source_text dir exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","rebuild_v2","source_text")), true);
});

test("rebuild v2 has 60 source text files", () => {
  const dir = path.join("worksheets","deltoid","rebuild_v2","source_text");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.txt$/i.test(x));
  assert.equal(files.length, 60);
});

test("content queue exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","rebuild_v2","config","content_queue.json")), true);
});

test("page 01 contains extracted source text block", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","rebuild_v2","pages","page-01.html"), "utf8");
  assert.ok(html.includes("טקסט מקור שחולץ מהעמוד"));
});
EOF

if ! grep -q "Deltoid rebuild v2 source text injection" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deltoid rebuild v2 source text injection

- יש להזריק לכל עמוד ב-rebuild_v2 טקסט מקור אמיתי שחולץ מה-PDF
- קבצי המקור נשמרים תחת:
  `worksheets/deltoid/rebuild_v2/source_text/`
- קובץ התור נשמר תחת:
  `worksheets/deltoid/rebuild_v2/config/content_queue.json`
EOF
fi

if ! grep -q "הזרקת טקסט מקור ל-rebuild_v2" RULES.md; then
cat >> RULES.md <<'EOF'

---

## הזרקת טקסט מקור ל-rebuild_v2

- כל עמוד ב-rebuild_v2 חייב לכלול טקסט מקור אמיתי מה-PDF
- הטקסט מוצג כטיוטת עריכה ולא כתוצר סופי
EOF
fi

npm test | tee deltoid_rebuild_v2_source_text_test_output.txt

{
  echo "# Deltoid rebuild v2 source text injection"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## queue"
  cat "$QUEUE_JSON"
  echo
  echo "## tests"
  cat deltoid_rebuild_v2_source_text_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md deltoid_rebuild_v2_source_text_test_output.txt "$REPORT" tools/inject_deltoid_source_text_into_rebuild_v2.sh

if ! git diff --cached --quiet; then
  git commit -m "feat: inject deltoid source text into rebuild v2 pages"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"

if command -v termux-open-url >/dev/null 2>&1; then
  termux-open-url "http://127.0.0.1:5179/worksheets/deltoid/rebuild_v2/index.html"
fi
