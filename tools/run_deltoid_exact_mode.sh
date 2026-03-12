#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_EXACT_MODE_$(date +%Y%m%d_%H%M%S).md"
PDF="sources/geometry/deltoid/source.pdf"
IMG_DIR="worksheets/deltoid/exact_assets"
PAGE_DIR="worksheets/deltoid/exact_pages"
CSS_FILE="styles/exact-facsimile.css"
PY_FILE="tools/build_deltoid_exact_pages.py"
TEST_FILE="tests/deltoid-exact-pages.test.mjs"
SITE_BUILD_SH="tools/build-site-termux.sh"

mkdir -p "$IMG_DIR" "$PAGE_DIR" tools tests styles site

if [ ! -f "$PDF" ]; then
  echo "MISSING SOURCE PDF: $PDF"
  exit 1
fi

if ! command -v pdftoppm >/dev/null 2>&1; then
  pkg install -y poppler
fi

rm -f "$IMG_DIR"/page-*.png
rm -f "$PAGE_DIR"/page-*.html "$PAGE_DIR"/manifest.json

pdftoppm -png -r 220 "$PDF" "$IMG_DIR/page"

cat > "$CSS_FILE" <<'EOF'
html,body{
  margin:0;
  padding:0;
  background:#eef3f9;
}
.exact-shell{
  min-height:100vh;
  display:flex;
  justify-content:center;
  align-items:flex-start;
  padding:24px 12px;
}
.a4-page.exact-page{
  width:210mm;
  min-height:297mm;
  height:297mm;
  margin:0 auto;
  padding:0;
  background:#fff;
  overflow:hidden;
  box-shadow:0 10px 30px rgba(0,0,0,.08);
  display:flex;
  align-items:stretch;
  justify-content:stretch;
}
.exact-image{
  width:100%;
  height:100%;
  object-fit:contain;
  display:block;
  background:#fff;
}
@media print{
  html,body{
    background:#fff;
  }
  .exact-shell{
    padding:0;
    min-height:auto;
  }
  .a4-page.exact-page{
    margin:0;
    box-shadow:none;
  }
}
EOF

cat > "$PY_FILE" <<'PYEOF'
from __future__ import annotations
import json
from pathlib import Path

img_dir = Path("worksheets/deltoid/exact_assets")
page_dir = Path("worksheets/deltoid/exact_pages")
page_dir.mkdir(parents=True, exist_ok=True)

pngs = sorted(img_dir.glob("page-*.png"))
manifest = {
    "topic": "דלתון",
    "mode": "exact-facsimile",
    "source": "sources/geometry/deltoid/source.pdf",
    "page_count": len(pngs),
    "pages": []
}

for i, png in enumerate(pngs, start=1):
    html = f"""<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>דלתון מדויק — עמוד {i}</title>
  <link rel="stylesheet" href="../../../styles/worksheet.css">
  <link rel="stylesheet" href="../../../styles/exact-facsimile.css">
</head>
<body>
  <div class="exact-shell">
    <main class="a4-page exact-page">
      <img class="exact-image" src="../exact_assets/{png.name}" alt="דלתון עמוד {i}">
    </main>
  </div>
</body>
</html>
"""
    out = page_dir / f"page-{i:02d}.html"
    out.write_text(html, encoding="utf-8")
    manifest["pages"].append(str(out).replace("\\", "/"))

(page_dir / "manifest.json").write_text(
    json.dumps(manifest, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

print(json.dumps(manifest, ensure_ascii=False, indent=2))
PYEOF

python "$PY_FILE" | tee deltoid_exact_manifest.out.json

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("exact deltoid png assets exist", () => {
  const dir = path.join("worksheets", "deltoid", "exact_assets");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.png$/i.test(x));
  assert.ok(files.length >= 1, "Expected exact PNG page assets");
});

test("exact deltoid html pages exist", () => {
  const dir = path.join("worksheets", "deltoid", "exact_pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.html$/i.test(x));
  assert.ok(files.length >= 1, "Expected exact HTML facsimile pages");
});

test("exact deltoid manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets", "deltoid", "exact_pages", "manifest.json")), true);
});
EOF

cat > "$SITE_BUILD_SH" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SITE="$ROOT/site"

rm -rf "$SITE"
mkdir -p "$SITE"

cp -R "$ROOT/styles" "$SITE/"
[ -d "$ROOT/assets" ] && cp -R "$ROOT/assets" "$SITE/" || true

find "$ROOT" -maxdepth 1 -type f -name 'עמוד-*.html' -exec cp {} "$SITE/" \;

if [ -d "$ROOT/worksheets" ]; then
  while IFS= read -r -d "" file; do
    rel="${file#$ROOT/}"
    mkdir -p "$SITE/$(dirname "$rel")"
    cp "$file" "$SITE/$rel"
  done < <(find "$ROOT/worksheets" -type f \( -name 'page-*.html' -o -name '*.png' -o -name 'manifest.json' \) -print0)
fi

ROOT_LINKS="$(find "$SITE" -maxdepth 1 -type f -name 'עמוד-*.html' | sort | sed "s#^$SITE/##" | awk "{print \"<li><a href='\''\" \$0 \"'\''>\" \$0 \"</a></li>\"}")"
TOPIC_LINKS="$(find "$SITE/worksheets" -type f -name 'page-*.html' 2>/dev/null | sort | sed "s#^$SITE/##" | awk "{print \"<li><a href='\''\" \$0 \"'\''>\" \$0 \"</a></li>\"}")"

cat > "$SITE/index.html" <<HTML
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>parabula2</title>
<link rel="stylesheet" href="styles/worksheet.css">
</head>
<body>
<main class="a4-page">
<header class="worksheet-header">
<h1 class="page-title">parabula2</h1>
<div class="page-number">1</div>
</header>
<section class="questions">
<div class="question"><span class="q-bullet"></span><div>דפי שורש</div></div>
<ul>
$ROOT_LINKS
</ul>
<div class="question"><span class="q-bullet"></span><div>דפי worksheets</div></div>
<ul>
$TOPIC_LINKS
</ul>
</section>
</main>
</body>
</html>
HTML

: > "$SITE/.nojekyll"
echo "site built"
EOF

chmod +x "$SITE_BUILD_SH"

if ! grep -q "Deltoid exact facsimile contract" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deltoid exact facsimile contract

- כאשר נדרש דיוק מלא של השרטוטים והציורים, מותר ליצור עמודי facsimile מדויקים מתוך:
  `sources/geometry/deltoid/source.pdf`
- הפלט נשמר תחת:
  `worksheets/deltoid/exact_pages/`
- נכסי התמונה המדויקים נשמרים תחת:
  `worksheets/deltoid/exact_assets/`
- במצב זה אין לבצע שחזור ידני של השרטוטים; שומרים את עמוד המקור בדיוק חזותי מלא.
- גם במצב זה HTML חייב להישאר ללא style inline, והעיצוב חייב להישען על CSS חיצוני בלבד.
EOF
fi

if ! grep -q "דלתון במצב facsimile מדויק" RULES.md; then
cat >> RULES.md <<'EOF'

---

## דלתון במצב facsimile מדויק

- כאשר המטרה היא דיוק מלא של השרטוטים, עובדים מול:
  `worksheets/deltoid/exact_pages/`
- התמונות נשמרות תחת:
  `worksheets/deltoid/exact_assets/`
- אסור לשחזר שרטוטים ידנית אם נדרש דיוק חזותי מלא
- גם במצב זה אין להכניס CSS פנימי לתוך HTML
EOF
fi

npm test | tee deltoid_exact_test_output.txt
bash "$SITE_BUILD_SH" | tee deltoid_exact_site_build_output.txt

{
  echo "# Deltoid exact mode report"
  echo
  echo "- time: $(date -Iseconds)"
  echo "- source: $PDF"
  echo
  echo "## exact assets"
  find worksheets/deltoid/exact_assets -maxdepth 1 -type f | sort
  echo
  echo "## exact pages"
  find worksheets/deltoid/exact_pages -maxdepth 1 -type f | sort
  echo
  echo "## npm test"
  cat deltoid_exact_test_output.txt
  echo
  echo "## local site build"
  cat deltoid_exact_site_build_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$CSS_FILE" "$PY_FILE" "$SITE_BUILD_SH" "$TEST_FILE" PROJECT_RULES.md RULES.md worksheets/deltoid/exact_assets worksheets/deltoid/exact_pages deltoid_exact_manifest.out.json deltoid_exact_test_output.txt deltoid_exact_site_build_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: add exact deltoid facsimile pages with full drawing fidelity"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "EXACT PAGE COUNT:"
find worksheets/deltoid/exact_pages -maxdepth 1 -type f -name "page-*.html" | wc -l
