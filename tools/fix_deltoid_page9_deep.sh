#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_PAGE9_DEEP_FIX_$(date +%Y%m%d_%H%M%S).md"
PDF="sources/geometry/deltoid/source.pdf"
ASSET_DIR="worksheets/deltoid/exact_assets"
PAGE_DIR="worksheets/deltoid/exact_pages"
CSS="styles/exact-facsimile.css"
TEST="tests/deltoid-page9.test.mjs"

mkdir -p "$ASSET_DIR" "$PAGE_DIR" tests styles tools

if [ ! -f "$PDF" ]; then
  echo "MISSING SOURCE PDF: $PDF"
  exit 1
fi

if ! command -v pdftoppm >/dev/null 2>&1; then
  pkg install -y poppler
fi

if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
  pkg install -y imagemagick
fi

# 1) Extract page 9 at higher DPI
pdftoppm -f 9 -l 9 -png -r 400 "$PDF" "$ASSET_DIR/p9-hires"

# normalize filename
if [ -f "$ASSET_DIR/p9-hires-09.png" ]; then
  mv -f "$ASSET_DIR/p9-hires-09.png" "$ASSET_DIR/page-09-hires.png"
elif [ -f "$ASSET_DIR/p9-hires-9.png" ]; then
  mv -f "$ASSET_DIR/p9-hires-9.png" "$ASSET_DIR/page-09-hires.png"
fi

# 2) Create enhanced version
IMGTOOL=""
if command -v magick >/dev/null 2>&1; then
  IMGTOOL="magick"
else
  IMGTOOL="convert"
fi

"$IMGTOOL" "$ASSET_DIR/page-09-hires.png" \
  -colorspace sRGB \
  -strip \
  -filter Lanczos \
  -resize 2480x3508 \
  -unsharp 0x1.2+1.4+0.03 \
  -brightness-contrast 8x18 \
  -sigmoidal-contrast 4,55% \
  "$ASSET_DIR/page-09-enhanced.png"

# 3) Backup old page-09 html if exists
if [ -f "$PAGE_DIR/page-09.html" ]; then
  cp -f "$PAGE_DIR/page-09.html" "$PAGE_DIR/page-09.backup.html"
fi

# 4) Rebuild page-09.html to use enhanced asset
cat > "$PAGE_DIR/page-09.html" <<'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>דלתון מדויק — עמוד 9</title>
  <link rel="stylesheet" href="../../../styles/worksheet.css">
  <link rel="stylesheet" href="../../../styles/exact-facsimile.css">
</head>
<body>
  <div class="exact-shell">
    <main class="a4-page exact-page exact-page-enhanced">
      <img class="exact-image exact-image-enhanced" src="../exact_assets/page-09-enhanced.png" alt="דלתון עמוד 9 משופר">
    </main>
  </div>
</body>
</html>
EOF

# 5) Ensure CSS has special page 9 quality hooks
if ! grep -q "exact-page-enhanced" "$CSS"; then
cat >> "$CSS" <<'EOF'

.exact-page-enhanced{
  image-rendering:auto;
}

.exact-image-enhanced{
  image-rendering:auto;
}
EOF
fi

# 6) Add project rules note
if ! grep -q "Page 9 deep enhancement" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Page 9 deep enhancement

- עמוד 9 של דלתון עבר extraction מחדש ברזולוציה גבוהה יותר ושיפור חזותי ייעודי.
- הקבצים:
  - `worksheets/deltoid/exact_assets/page-09-hires.png`
  - `worksheets/deltoid/exact_assets/page-09-enhanced.png`
- `worksheets/deltoid/exact_pages/page-09.html` חייב להצביע לגרסה המשופרת.
- זהו שיפור חזותי מבוסס מקור, לא שרטוט SVG חדש.
EOF
fi

if ! grep -q "עמוד 9 של דלתון שופר חזותית" RULES.md; then
cat >> RULES.md <<'EOF'

---

## עמוד 9 של דלתון שופר חזותית

- עמוד 9 משתמש בגרסת source משופרת:
  `worksheets/deltoid/exact_assets/page-09-enhanced.png`
- זהו שיפור עומק חזותי מתוך המקור
- אין להציג זאת כווקטור נקי חדש
EOF
fi

# 7) Add targeted test
cat > "$TEST" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("page 9 enhanced asset exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","exact_assets","page-09-enhanced.png")), true);
});

test("page 9 html points to enhanced asset", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","exact_pages","page-09.html"), "utf8");
  assert.ok(html.includes("page-09-enhanced.png"));
});
EOF

npm test | tee deltoid_page9_test_output.txt

{
  echo "# Deltoid page 9 deep fix"
  echo
  echo "- time: $(date -Iseconds)"
  echo "- source: $PDF"
  echo
  echo "## page 9 assets"
  ls -lh "$ASSET_DIR"/page-09*.png
  echo
  echo "## tests"
  cat deltoid_page9_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$ASSET_DIR/page-09-hires.png" "$ASSET_DIR/page-09-enhanced.png" "$PAGE_DIR/page-09.html" "$PAGE_DIR/page-09.backup.html" "$CSS" PROJECT_RULES.md RULES.md "$TEST" deltoid_page9_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "fix: deeply enhance deltoid exact page 9 from source"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "OPEN:"
echo "http://127.0.0.1:5179/preview?file=worksheets/deltoid/exact_pages/page-09.html"
