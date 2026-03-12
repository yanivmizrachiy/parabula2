#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

PDF="sources/geometry/deltoid/source.pdf"
OUT="worksheets/deltoid/page42_inspection"
ASSET_DIR="worksheets/deltoid/exact_assets"
PAGE_DIR="worksheets/deltoid/exact_pages"
REPORT="DELTOID_PAGE42_INSPECT_AND_UPGRADE_$(date +%Y%m%d_%H%M%S).md"

mkdir -p "$OUT" "$ASSET_DIR" "$PAGE_DIR"

command -v pdftoppm >/dev/null 2>&1 || pkg install -y poppler
if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then pkg install -y imagemagick; fi

IMGTOOL="convert"
command -v magick >/dev/null 2>&1 && IMGTOOL="magick"

rm -f "$OUT"/page42-*.png "$OUT"/page-42* "$ASSET_DIR"/page-42-enhanced.png

pdftoppm -f 42 -l 42 -png -r 500 "$PDF" "$OUT/page42"
pdftotext -f 42 -l 42 "$PDF" "$OUT/page-42.txt"
pdfimages -f 42 -l 42 -list "$PDF" > "$OUT/page-42-images.txt"

RAW="$(find "$OUT" -maxdepth 1 -type f -name 'page42-*.png' | head -n 1)"
cp -f "$RAW" "$OUT/page-42-raw.png"

"$IMGTOOL" "$OUT/page-42-raw.png" \
  -colorspace sRGB -strip -filter Lanczos -resize 2480x3508 \
  -unsharp 0x1.4+1.8+0.03 -brightness-contrast 12x22 \
  -sigmoidal-contrast 5,55% "$OUT/page-42-enhanced.png"

"$IMGTOOL" "$OUT/page-42-raw.png" \
  -colorspace Gray -contrast-stretch 0.5%x0.5% -threshold 62% \
  "$OUT/page-42-lines.png"

cp -f "$OUT/page-42-enhanced.png" "$ASSET_DIR/page-42-enhanced.png"

cat > "$PAGE_DIR/page-42.html" <<'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>דלתון מדויק — עמוד 42</title>
  <link rel="stylesheet" href="../../../styles/worksheet.css">
  <link rel="stylesheet" href="../../../styles/exact-facsimile.css">
</head>
<body>
  <div class="exact-shell">
    <main class="a4-page exact-page exact-page-enhanced">
      <img class="exact-image exact-image-enhanced" src="../exact_assets/page-42-enhanced.png" alt="דלתון עמוד 42 משופר">
    </main>
  </div>
</body>
</html>
EOF

cat > tests/deltoid-page42.test.mjs <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("page 42 enhanced asset exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","exact_assets","page-42-enhanced.png")), true);
});

test("page 42 html points to enhanced asset", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","exact_pages","page-42.html"), "utf8");
  assert.ok(html.includes("page-42-enhanced.png"));
});
EOF

if ! grep -q "Page 42 deep enhancement" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Page 42 deep enhancement

- עמוד 42 של דלתון עבר extraction מחדש ברזולוציה גבוהה ושיפור חזותי ייעודי.
- הקבצים:
  - `worksheets/deltoid/exact_assets/page-42-enhanced.png`
  - `worksheets/deltoid/exact_pages/page-42.html`
- זהו שיפור חזותי מבוסס מקור, לא שרטוט SVG חדש.
EOF
fi

if ! grep -q "עמוד 42 של דלתון שופר חזותית" RULES.md; then
cat >> RULES.md <<'EOF'

---

## עמוד 42 של דלתון שופר חזותית

- עמוד 42 משתמש בגרסת source משופרת:
  `worksheets/deltoid/exact_assets/page-42-enhanced.png`
- זהו שיפור עומק חזותי מתוך המקור
- אין להציג זאת כווקטור נקי חדש
EOF
fi

npm test | tee deltoid_page42_test_output.txt

{
  echo "# Deltoid page 42 inspect and upgrade"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## files"
  find "$OUT" -maxdepth 1 -type f | sort
  echo
  echo "## image list"
  cat "$OUT/page-42-images.txt"
  echo
  echo "## extracted text"
  cat "$OUT/page-42.txt" || true
  echo
  echo "## tests"
  cat deltoid_page42_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT" "$ASSET_DIR/page-42-enhanced.png" "$PAGE_DIR/page-42.html" tests/deltoid-page42.test.mjs PROJECT_RULES.md RULES.md deltoid_page42_test_output.txt "$REPORT"
if ! git diff --cached --quiet; then
  git commit -m "fix: deeply enhance deltoid exact page 42 from source"
  git push
fi

echo "DONE"
echo "REPORT: $REPORT"
