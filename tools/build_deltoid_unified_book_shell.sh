#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_UNIFIED_BOOK_SHELL_$(date +%Y%m%d_%H%M%S).md"
OUT_DIR="worksheets/deltoid/unified_book"
ASSETS_DIR="$OUT_DIR/assets"
JSON_OUT="$OUT_DIR/book-shell.json"
HOME_OUT="$OUT_DIR/index.html"
BOOK_OUT="$OUT_DIR/book.html"
CSS_OUT="$ASSETS_DIR/theme.css"
TEST_FILE="tests/deltoid-unified-book-shell.test.mjs"

mkdir -p "$OUT_DIR" "$ASSETS_DIR" tests tools

python - <<'PYEOF'
from __future__ import annotations
import json
from pathlib import Path

out_dir = Path("worksheets/deltoid/unified_book")
assets_dir = out_dir / "assets"
assets_dir.mkdir(parents=True, exist_ok=True)

chapters = [
    {
        "id": "chapter_01_done_pages",
        "title": "פרק 1 — עמודים מטופלים",
        "index": "worksheets/deltoid/chapters/chapter_01_done_pages/index.html",
        "book": "worksheets/deltoid/chapters/chapter_01_done_pages/chapter-book.html",
        "description": "עמודים 9, 38, 41, 42, 56 שכבר טופלו והפכו לבסיס האיכותי של הספר."
    },
    {
        "id": "chapter_02_vector_next",
        "title": "פרק 2 — vector-next",
        "index": "worksheets/deltoid/chapters/chapter_02_vector_next/index.html",
        "book": "worksheets/deltoid/chapters/chapter_02_vector_next/chapter-book.html",
        "description": "עמודים בעלי ערך גיאומטרי גבוה שהוגדרו כשלב הבא לשחזור שיטתי."
    },
    {
        "id": "chapter_03_image_first",
        "title": "פרק 3 — image-first",
        "index": "worksheets/deltoid/chapters/chapter_03_image_first/index.html",
        "book": "worksheets/deltoid/chapters/chapter_03_image_first/chapter-book.html",
        "description": "עמודים גרפיים חזקים שנעטפו בגישת image-first כדי לסגור מהר חלק גדול מהספר."
    },
]

summary = {
    "project": "parabula2",
    "topic": "דלתון",
    "title": "ספר דלתון — מעטפת מאוחדת",
    "chapter_count": len(chapters),
    "chapters": chapters
}

(out_dir / "book-shell.json").write_text(
    json.dumps(summary, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

css = """
:root{
  --bg:#f4f7fb;
  --card:#ffffff;
  --text:#0f172a;
  --muted:#475569;
  --line:#dbe4ee;
  --blue:#1d4ed8;
  --blue2:#0f3ea9;
  --shadow:0 12px 30px rgba(15,23,42,.08);
  --radius:22px;
}
*{box-sizing:border-box}
body{
  margin:0;
  font-family:Arial,sans-serif;
  background:linear-gradient(180deg,#eef4fb 0%,#f8fbff 100%);
  color:var(--text);
}
.shell{
  max-width:1200px;
  margin:0 auto;
  padding:24px 16px 48px;
}
.hero{
  background:linear-gradient(135deg,#173b8f 0%,#2563eb 55%,#4f8df7 100%);
  color:#fff;
  border-radius:28px;
  padding:28px 22px;
  box-shadow:var(--shadow);
}
.hero h1{
  margin:0 0 10px 0;
  font-size:34px;
}
.hero p{
  margin:0;
  font-size:17px;
  line-height:1.7;
  opacity:.96;
}
.stats{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(180px,1fr));
  gap:14px;
  margin-top:20px;
}
.stat{
  background:rgba(255,255,255,.14);
  border:1px solid rgba(255,255,255,.18);
  border-radius:18px;
  padding:14px;
}
.stat .label{font-size:13px;opacity:.9}
.stat .value{font-size:26px;font-weight:700;margin-top:6px}
.section-title{
  margin:28px 0 16px;
  font-size:24px;
}
.grid{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(280px,1fr));
  gap:18px;
}
.card{
  background:var(--card);
  border:1px solid var(--line);
  border-radius:var(--radius);
  padding:18px;
  box-shadow:var(--shadow);
}
.card h2{
  margin:0 0 10px 0;
  font-size:20px;
}
.card p{
  margin:0 0 14px 0;
  color:var(--muted);
  line-height:1.7;
  font-size:15px;
}
.actions{
  display:flex;
  flex-wrap:wrap;
  gap:10px;
}
.btn{
  display:inline-flex;
  align-items:center;
  justify-content:center;
  min-height:42px;
  padding:0 14px;
  border-radius:14px;
  text-decoration:none;
  font-weight:700;
  border:1px solid transparent;
}
.btn-primary{
  background:var(--blue);
  color:#fff;
}
.btn-primary:active{background:var(--blue2)}
.btn-secondary{
  background:#fff;
  color:var(--blue);
  border-color:#bfdbfe;
}
.book-frame{
  margin-top:26px;
  background:#fff;
  border:1px solid var(--line);
  border-radius:26px;
  box-shadow:var(--shadow);
  overflow:hidden;
}
.book-frame iframe{
  width:100%;
  height:78vh;
  border:0;
  display:block;
}
.note{
  margin-top:18px;
  color:var(--muted);
  font-size:14px;
  line-height:1.7;
}
@media (max-width:700px){
  .hero h1{font-size:28px}
  .book-frame iframe{height:68vh}
}
"""
(assets_dir / "theme.css").write_text(css.strip() + "\n", encoding="utf-8")

home = []
home += [
    "<!DOCTYPE html>",
    '<html lang="he" dir="rtl">',
    "<head>",
    '<meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
    "<title>ספר דלתון — מעטפת מאוחדת</title>",
    '<link rel="stylesheet" href="assets/theme.css">',
    "</head>",
    "<body>",
    '<div class="shell">',
    '<section class="hero">',
    '<h1>ספר דלתון — מעטפת מאוחדת</h1>',
    '<p>מעטפת צפייה וניווט חזקה, אחידה ונוחה לכל מה שכבר נבנה בפרויקט. מכאן אפשר לעבור בין פרקים, לבדוק דפים, ולהתחיל לעצב את הספר לפי הדרישות שלך.</p>',
    '<div class="stats">',
    '<div class="stat"><div class="label">פרקים שנבנו</div><div class="value">3</div></div>',
    '<div class="stat"><div class="label">עמודי בסיס מטופלים</div><div class="value">17+</div></div>',
    '<div class="stat"><div class="label">בדיקות פעילות</div><div class="value">62</div></div>',
    '</div>',
    '</section>',
    '<h2 class="section-title">פרקי הספר</h2>',
    '<div class="grid">',
]
for ch in chapters:
    home += [
        '<article class="card">',
        f'<h2>{ch["title"]}</h2>',
        f'<p>{ch["description"]}</p>',
        '<div class="actions">',
        f'<a class="btn btn-primary" href="../../{ch["index"]}" target="_blank">פתח אינדקס פרק</a>',
        f'<a class="btn btn-secondary" href="../../{ch["book"]}" target="_blank">פתח ספר פרק</a>',
        '</div>',
        '</article>',
    ]
home += [
    '</div>',
    '<div class="note">השלב הבא: להפוך את המעטפת הזו לספר עריך באמת, עם theme מרכזי, TOC מסודר, ועמודי תוכן שניתן לשנות לפי הדרישות שלך.</div>',
    '</div>',
    '</body>',
    '</html>',
]
(out_dir / "index.html").write_text("\n".join(home) + "\n", encoding="utf-8")

book = []
book += [
    "<!DOCTYPE html>",
    '<html lang="he" dir="rtl">',
    "<head>",
    '<meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">',
    "<title>ספר דלתון — ספר מאוחד</title>",
    '<link rel="stylesheet" href="assets/theme.css">',
    "</head>",
    "<body>",
    '<div class="shell">',
    '<section class="hero">',
    '<h1>ספר דלתון — ספר מאוחד</h1>',
    '<p>מעטפת ספר אחת לצפייה בכל החומר שנבנה עד עכשיו. בחר פרק לפתיחה נפרדת, או השתמש בעמוד הזה כמרכז שליטה עיצובי.</p>',
    '</section>',
    '<h2 class="section-title">ניווט מהיר</h2>',
    '<div class="grid">',
]
for ch in chapters:
    book += [
        '<article class="card">',
        f'<h2>{ch["title"]}</h2>',
        f'<p>{ch["description"]}</p>',
        '<div class="actions">',
        f'<a class="btn btn-primary" href="../../{ch["book"]}" target="_blank">פתח ספר פרק</a>',
        f'<a class="btn btn-secondary" href="../../{ch["index"]}" target="_blank">פתח אינדקס</a>',
        '</div>',
        '</article>',
    ]
book += [
    '</div>',
    '<div class="note">המעטפת הזו היא שכבת העיצוב המאוחדת הראשונה של הספר. מכאן אפשר לעבור לשלב עריכה אחידה לפי הדרישות שלך.</div>',
    '</div>',
    '</body>',
    '</html>',
]
(out_dir / "book.html").write_text("\n".join(book) + "\n", encoding="utf-8")

print(json.dumps({"chapter_count": len(chapters), "chapters": [c["id"] for c in chapters]}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("unified book shell json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","unified_book","book-shell.json")), true);
});

test("unified book index exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","unified_book","index.html")), true);
});

test("unified book page exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","unified_book","book.html")), true);
});

test("unified book theme exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","unified_book","assets","theme.css")), true);
});

test("unified book has 3 chapters", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","unified_book","book-shell.json"), "utf8"));
  assert.equal(data.chapter_count, 3);
});
EOF

if ! grep -q "Deltoid unified book shell" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deltoid unified book shell

- יש לבנות מעטפת ספר מאוחדת תחת:
  `worksheets/deltoid/unified_book/`
- המעטפת חייבת לכלול:
  - book-shell.json
  - index.html
  - book.html
  - assets/theme.css
- זו שכבת העיצוב המרכזית הראשונה של הספר
EOF
fi

if ! grep -q "מעטפת ספר מאוחדת לדלתון" RULES.md; then
cat >> RULES.md <<'EOF'

---

## מעטפת ספר מאוחדת לדלתון

- אחרי בניית פרקים 01–03 חייבת להיבנות מעטפת ספר מאוחדת
- המעטפת משמשת בסיס לעיצוב חזק ואחיד של כל הספר
EOF
fi

npm test | tee deltoid_unified_book_shell_test_output.txt

{
  echo "# Deltoid unified book shell build"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## unified shell summary"
  cat "$JSON_OUT"
  echo
  echo "## tests"
  cat deltoid_unified_book_shell_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md deltoid_unified_book_shell_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: build unified deltoid book shell with strong visual design"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "HOME: $HOME_OUT"
echo "BOOK: $BOOK_OUT"
echo "NEXT HIGH PRIORITY: build editable book shell"
