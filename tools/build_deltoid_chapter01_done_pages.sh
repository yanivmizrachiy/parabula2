#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_CHAPTER01_DONE_PAGES_$(date +%Y%m%d_%H%M%S).md"
OUT_DIR="worksheets/deltoid/chapters/chapter_01_done_pages"
PAGES_DIR="$OUT_DIR/pages"
JSON_OUT="$OUT_DIR/manifest.json"
INDEX_OUT="$OUT_DIR/index.html"
BOOK_OUT="$OUT_DIR/chapter-book.html"
TEST_FILE="tests/deltoid-chapter01-done-pages.test.mjs"

mkdir -p "$PAGES_DIR" tests tools

python - <<'PYEOF'
from __future__ import annotations
import json
from pathlib import Path

root = Path(".")
out_dir = Path("worksheets/deltoid/chapters/chapter_01_done_pages")
pages_dir = out_dir / "pages"
pages_dir.mkdir(parents=True, exist_ok=True)

done_pages = [9, 38, 41, 42, 56]

def pick_source(page: int):
    candidates = [
        ("vector-html", Path(f"worksheets/deltoid/vector_pages/page-{page:02d}-vector.html")),
        ("vector-html", Path(f"worksheets/deltoid/vector_pages/page-{page:02d}-precise.html")),
        ("vector-html", Path(f"worksheets/deltoid/vector_pages/page-{page:02d}.html")),
        ("exact-html", Path(f"worksheets/deltoid/exact_pages/page-{page:02d}.html")),
        ("enhanced-png", Path(f"worksheets/deltoid/exact_assets/page-{page:02d}-enhanced.png")),
        ("inventory-png", Path(f"worksheets/deltoid/image_inventory/pages/page-{page:02d}.png")),
    ]
    for kind, p in candidates:
        if p.exists():
            return kind, p
    return "missing", None

records = []
for page in done_pages:
    kind, src = pick_source(page)
    target = pages_dir / f"page-{page:02d}.html"

    title = f"עמוד {page:02d} — גרסה מטופלת"
    body = []

    if kind == "vector-html" and src is not None:
        rel = Path("../../..") / src
        body.append("<!DOCTYPE html>")
        body.append('<html lang="he" dir="rtl">')
        body.append("<head>")
        body.append('<meta charset="utf-8">')
        body.append('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
        body.append(f"<title>{title}</title>")
        body.append('<style>body{margin:0;background:#f8fafc}iframe{width:100%;height:100vh;border:0;display:block}</style>')
        body.append("</head>")
        body.append("<body>")
        body.append(f'<iframe src="../../../{src.as_posix()}"></iframe>')
        body.append("</body>")
        body.append("</html>")
    elif kind in ("enhanced-png", "inventory-png") and src is not None:
        body.append("<!DOCTYPE html>")
        body.append('<html lang="he" dir="rtl">')
        body.append("<head>")
        body.append('<meta charset="utf-8">')
        body.append('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
        body.append(f"<title>{title}</title>")
        body.append('<style>body{margin:0;background:#f8fafc;font-family:Arial,sans-serif}main{max-width:1100px;margin:0 auto;padding:24px}img{width:100%;height:auto;display:block;border:1px solid #cbd5e1;border-radius:16px;box-shadow:0 4px 14px rgba(0,0,0,.05)}h1{margin:0 0 16px 0}</style>')
        body.append("</head>")
        body.append("<body>")
        body.append("<main>")
        body.append(f"<h1>{title}</h1>")
        body.append(f'<img src="../../../{src.as_posix()}" alt="{title}">')
        body.append("</main>")
        body.append("</body>")
        body.append("</html>")
    else:
        body.append("<!DOCTYPE html>")
        body.append('<html lang="he" dir="rtl">')
        body.append("<head><meta charset='utf-8'><title>Missing</title></head>")
        body.append("<body><p>Missing source page.</p></body></html>")

    target.write_text("\n".join(body) + "\n", encoding="utf-8")

    records.append({
        "page": page,
        "title": title,
        "source_kind": kind,
        "source_path": src.as_posix() if src else None,
        "chapter_page": target.as_posix(),
    })

summary = {
    "project": "parabula2",
    "topic": "דלתון",
    "chapter": "chapter_01_done_pages",
    "page_count": len(records),
    "records": records,
}
(out_dir / "manifest.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")

html = []
html.append("<!DOCTYPE html>")
html.append('<html lang="he" dir="rtl">')
html.append("<head>")
html.append('<meta charset="utf-8">')
html.append('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
html.append("<title>Deltoid Chapter 01</title>")
html.append("<style>")
html.append("body{font-family:Arial,sans-serif;background:#f8fafc;margin:0;padding:24px}")
html.append("h1{margin:0 0 24px 0}")
html.append(".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px}")
html.append(".card{background:#fff;border:1px solid #cbd5e1;border-radius:16px;padding:16px;box-shadow:0 4px 14px rgba(0,0,0,.05)}")
html.append(".card h2{margin:0 0 10px 0;font-size:18px}")
html.append(".meta{font-size:14px;color:#334155;line-height:1.6}")
html.append("a{color:#1d4ed8;text-decoration:none}")
html.append("</style>")
html.append("</head>")
html.append("<body>")
html.append("<h1>Deltoid Chapter 01 — Done Pages</h1>")
html.append('<div class="grid">')
for r in records:
    html.append('<div class="card">')
    html.append(f'<h2>עמוד {r["page"]:02d}</h2>')
    html.append(f'<div class="meta">source_kind: {r["source_kind"]}<br>source_path: {r["source_path"]}<br><a href="pages/page-{r["page"]:02d}.html" target="_blank">פתח עמוד פרק</a></div>')
    html.append("</div>")
html.append("</div>")
html.append("</body>")
html.append("</html>")
(out_dir / "index.html").write_text("\n".join(html) + "\n", encoding="utf-8")

book = []
book.append("<!DOCTYPE html>")
book.append('<html lang="he" dir="rtl">')
book.append("<head>")
book.append('<meta charset="utf-8">')
book.append('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
book.append("<title>Deltoid Chapter Book</title>")
book.append('<style>body{font-family:Arial,sans-serif;background:#f8fafc;margin:0;padding:24px}section{background:#fff;border:1px solid #cbd5e1;border-radius:16px;padding:16px;margin-bottom:20px;box-shadow:0 4px 14px rgba(0,0,0,.05)}h1{margin:0 0 24px 0}h2{margin:0 0 12px 0}a{color:#1d4ed8;text-decoration:none}</style>')
book.append("</head>")
book.append("<body>")
book.append("<h1>Deltoid Chapter Book — Done Pages</h1>")
for r in records:
    book.append("<section>")
    book.append(f'<h2>עמוד {r["page"]:02d}</h2>')
    book.append(f'<p>source_kind: {r["source_kind"]}</p>')
    book.append(f'<p><a href="pages/page-{r["page"]:02d}.html" target="_blank">פתח עמוד</a></p>')
    book.append("</section>")
book.append("</body>")
book.append("</html>")
(out_dir / "chapter-book.html").write_text("\n".join(book) + "\n", encoding="utf-8")

print(json.dumps({"page_count": len(records), "pages": [r["page"] for r in records]}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("chapter manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_01_done_pages","manifest.json")), true);
});

test("chapter index exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_01_done_pages","index.html")), true);
});

test("chapter book exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_01_done_pages","chapter-book.html")), true);
});

test("chapter contains 5 wrapped pages", () => {
  const dir = path.join("worksheets","deltoid","chapters","chapter_01_done_pages","pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.html$/i.test(x));
  assert.equal(files.length, 5);
});

test("chapter manifest page count is 5", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","chapters","chapter_01_done_pages","manifest.json"), "utf8"));
  assert.equal(data.page_count, 5);
});
EOF

if ! grep -q "Deltoid chapter 01 done pages" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deltoid chapter 01 done pages

- יש לבנות פרק ראשון אמיתי מתוך העמודים שכבר טופלו:
  9, 38, 41, 42, 56
- הפרק נשמר תחת:
  `worksheets/deltoid/chapters/chapter_01_done_pages/`
- כל עמוד פרק עוטף את המקור הטוב ביותר הזמין:
  vector / exact / enhanced / inventory
EOF
fi

if ! grep -q "פרק ראשון עמודים מטופלים לדלתון" RULES.md; then
cat >> RULES.md <<'EOF'

---

## פרק ראשון עמודים מטופלים לדלתון

- אחרי rebuild plan חייבים להתחיל לבנות פרקים אמיתיים
- פרק ראשון מבוסס על עמודים מטופלים שכבר קיימים
- המטרה היא מעבר מתשתית לבניית ספר בפועל
EOF
fi

npm test | tee deltoid_chapter01_done_pages_test_output.txt

{
  echo "# Deltoid chapter 01 done pages build"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## chapter summary"
  cat "$JSON_OUT"
  echo
  echo "## tests"
  cat deltoid_chapter01_done_pages_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md deltoid_chapter01_done_pages_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: build first real deltoid chapter from treated pages"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "CHAPTER INDEX: $INDEX_OUT"
echo "NEXT HIGH PRIORITY: build chapter 02 from vector-next bucket"
