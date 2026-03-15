#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_CHAPTER02_VECTOR_NEXT_$(date +%Y%m%d_%H%M%S).md"
PLAN_JSON="worksheets/deltoid/rebuild_plan/normalized_rebuild_plan.json"
OUT_DIR="worksheets/deltoid/chapters/chapter_02_vector_next"
PAGES_DIR="$OUT_DIR/pages"
JSON_OUT="$OUT_DIR/manifest.json"
INDEX_OUT="$OUT_DIR/index.html"
BOOK_OUT="$OUT_DIR/chapter-book.html"
TEST_FILE="tests/deltoid-chapter02-vector-next.test.mjs"

mkdir -p "$PAGES_DIR" tests tools

if [ ! -f "$PLAN_JSON" ]; then
  echo "MISSING: $PLAN_JSON"
  exit 1
fi

python - <<'PYEOF'
from __future__ import annotations
import json
from pathlib import Path

plan = json.loads(Path("worksheets/deltoid/rebuild_plan/normalized_rebuild_plan.json").read_text(encoding="utf-8"))
out_dir = Path("worksheets/deltoid/chapters/chapter_02_vector_next")
pages_dir = out_dir / "pages"
pages_dir.mkdir(parents=True, exist_ok=True)

vector_next_pages = [int(x) for x in plan["buckets"].get("vector-next", [])]

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
for page in vector_next_pages:
    kind, src = pick_source(page)
    target = pages_dir / f"page-{page:02d}.html"
    title = f"עמוד {page:02d} — פרק 02 vector-next"

    body = []
    if kind in ("vector-html", "exact-html") and src is not None:
        body += [
            "<!DOCTYPE html>",
            '<html lang="he" dir="rtl">',
            "<head>",
            '<meta charset="utf-8">',
            '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
            f"<title>{title}</title>",
            '<style>body{margin:0;background:#f8fafc}iframe{width:100%;height:100vh;border:0;display:block}</style>',
            "</head>",
            "<body>",
            f'<iframe src="../../../{src.as_posix()}"></iframe>',
            "</body>",
            "</html>",
        ]
    elif kind in ("enhanced-png", "inventory-png") and src is not None:
        body += [
            "<!DOCTYPE html>",
            '<html lang="he" dir="rtl">',
            "<head>",
            '<meta charset="utf-8">',
            '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
            f"<title>{title}</title>",
            '<style>body{margin:0;background:#f8fafc;font-family:Arial,sans-serif}main{max-width:1100px;margin:0 auto;padding:24px}img{width:100%;height:auto;display:block;border:1px solid #cbd5e1;border-radius:16px;box-shadow:0 4px 14px rgba(0,0,0,.05)}h1{margin:0 0 16px 0}.meta{color:#334155;margin-bottom:16px}</style>',
            "</head>",
            "<body>",
            "<main>",
            f"<h1>{title}</h1>",
            f'<div class="meta">source_kind: {kind}<br>source_path: {src.as_posix()}</div>',
            f'<img src="../../../{src.as_posix()}" alt="{title}">',
            "</main>",
            "</body>",
            "</html>",
        ]
    else:
        body += [
            "<!DOCTYPE html>",
            '<html lang="he" dir="rtl">',
            "<head><meta charset='utf-8'><title>Missing</title></head>",
            "<body><p>Missing source page.</p></body></html>",
        ]

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
    "chapter": "chapter_02_vector_next",
    "page_count": len(records),
    "source_bucket": "vector-next",
    "records": records,
}

(out_dir / "manifest.json").write_text(
    json.dumps(summary, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

index_html = []
index_html += [
    "<!DOCTYPE html>",
    '<html lang="he" dir="rtl">',
    "<head>",
    '<meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
    "<title>Deltoid Chapter 02</title>",
    "<style>",
    "body{font-family:Arial,sans-serif;background:#f8fafc;margin:0;padding:24px}",
    "h1{margin:0 0 24px 0}",
    ".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px}",
    ".card{background:#fff;border:1px solid #cbd5e1;border-radius:16px;padding:16px;box-shadow:0 4px 14px rgba(0,0,0,.05)}",
    ".card h2{margin:0 0 10px 0;font-size:18px}",
    ".meta{font-size:14px;color:#334155;line-height:1.6}",
    "a{color:#1d4ed8;text-decoration:none}",
    "</style>",
    "</head>",
    "<body>",
    "<h1>Deltoid Chapter 02 — Vector Next</h1>",
    '<div class="grid">',
]
for r in records:
    index_html += [
        '<div class="card">',
        f'<h2>עמוד {r["page"]:02d}</h2>',
        f'<div class="meta">source_kind: {r["source_kind"]}<br>source_path: {r["source_path"]}<br><a href="pages/page-{r["page"]:02d}.html" target="_blank">פתח עמוד פרק</a></div>',
        "</div>",
    ]
index_html += ["</div>", "</body>", "</html>"]
(out_dir / "index.html").write_text("\n".join(index_html) + "\n", encoding="utf-8")

book_html = []
book_html += [
    "<!DOCTYPE html>",
    '<html lang="he" dir="rtl">',
    "<head>",
    '<meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
    "<title>Deltoid Chapter 02 Book</title>",
    '<style>body{font-family:Arial,sans-serif;background:#f8fafc;margin:0;padding:24px}section{background:#fff;border:1px solid #cbd5e1;border-radius:16px;padding:16px;margin-bottom:20px;box-shadow:0 4px 14px rgba(0,0,0,.05)}h1{margin:0 0 24px 0}h2{margin:0 0 12px 0}a{color:#1d4ed8;text-decoration:none}</style>',
    "</head>",
    "<body>",
    "<h1>Deltoid Chapter 02 Book — Vector Next</h1>",
]
for r in records:
    book_html += [
        "<section>",
        f'<h2>עמוד {r["page"]:02d}</h2>',
        f'<p>source_kind: {r["source_kind"]}</p>',
        f'<p><a href="pages/page-{r["page"]:02d}.html" target="_blank">פתח עמוד</a></p>',
        "</section>",
    ]
book_html += ["</body>", "</html>"]
(out_dir / "chapter-book.html").write_text("\n".join(book_html) + "\n", encoding="utf-8")

print(json.dumps({
    "page_count": len(records),
    "pages": [r["page"] for r in records],
    "source_bucket": "vector-next"
}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("chapter 02 manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_02_vector_next","manifest.json")), true);
});

test("chapter 02 index exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_02_vector_next","index.html")), true);
});

test("chapter 02 book exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_02_vector_next","chapter-book.html")), true);
});

test("chapter 02 contains wrapped pages", () => {
  const dir = path.join("worksheets","deltoid","chapters","chapter_02_vector_next","pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.html$/i.test(x));
  assert.ok(files.length > 0);
});

test("chapter 02 manifest has vector-next bucket", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","chapters","chapter_02_vector_next","manifest.json"), "utf8"));
  assert.equal(data.source_bucket, "vector-next");
  assert.ok(data.page_count > 0);
});
EOF

if ! grep -q "Deltoid chapter 02 vector next" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deltoid chapter 02 vector next

- יש לבנות פרק שני מתוך bucket:
  `vector-next`
- הפרק נשמר תחת:
  `worksheets/deltoid/chapters/chapter_02_vector_next/`
- כל עמוד פרק עוטף את המקור הטוב ביותר הזמין
EOF
fi

if ! grep -q "פרק שני vector-next לדלתון" RULES.md; then
cat >> RULES.md <<'EOF'

---

## פרק שני vector-next לדלתון

- אחרי פרק 01 חייבים לבנות פרק 02 מתוך vector-next
- זהו המעבר הראשון לשחזור שיטתי של עמודים עתירי גיאומטריה
EOF
fi

npm test | tee deltoid_chapter02_vector_next_test_output.txt

{
  echo "# Deltoid chapter 02 vector-next build"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## chapter summary"
  cat "$JSON_OUT"
  echo
  echo "## tests"
  cat deltoid_chapter02_vector_next_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md deltoid_chapter02_vector_next_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: build second deltoid chapter from vector-next bucket"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "CHAPTER INDEX: $INDEX_OUT"
echo "NEXT HIGH PRIORITY: build chapter 03 from image-first-next bucket"
