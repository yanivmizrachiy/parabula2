#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_DEEP_GRAPHICS_UPGRADE_$(date +%Y%m%d_%H%M%S).md"
PDF="sources/geometry/deltoid/source.pdf"
ASSET_DIR="worksheets/deltoid/exact_assets"
PAGE_DIR="worksheets/deltoid/exact_pages"
CSS="styles/exact-facsimile.css"
PY="tools/deep_graphics_upgrade.py"
TEST="tests/deltoid-deep-graphics.test.mjs"
ANALYSIS_JSON="worksheets/deltoid/exact_assets/graphics_analysis.json"

mkdir -p tools tests "$ASSET_DIR" "$PAGE_DIR"

if [ ! -f "$PDF" ]; then
  echo "MISSING SOURCE PDF: $PDF"
  exit 1
fi

if ! command -v pdfimages >/dev/null 2>&1 || ! command -v pdftoppm >/dev/null 2>&1 || ! command -v pdfinfo >/dev/null 2>&1; then
  pkg install -y poppler
fi

if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
  pkg install -y imagemagick
fi

cat > "$PY" <<'PYEOF'
from __future__ import annotations
import json
import subprocess
from pathlib import Path

pdf = "sources/geometry/deltoid/source.pdf"
report_json = Path("worksheets/deltoid/exact_assets/graphics_analysis.json")

raw = subprocess.check_output(["pdfimages", "-list", pdf], text=True)
lines = raw.strip().splitlines()[2:]

per_page = {}
for ln in lines:
    parts = ln.split()
    if len(parts) < 14:
        continue
    try:
        page = int(parts[0])
        xppi = int(parts[12])
        yppi = int(parts[13])
    except ValueError:
        continue
    dpi = min(xppi, yppi)
    per_page.setdefault(page, []).append(dpi)

summary = []
for page in sorted(per_page):
    dpis = per_page[page]
    summary.append({
        "page": page,
        "image_count": len(dpis),
        "min_dpi": min(dpis),
        "max_dpi": max(dpis),
        "avg_dpi": round(sum(dpis) / len(dpis), 2),
        "upgrade": min(dpis) <= 100
    })

report_json.write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps(summary, ensure_ascii=False, indent=2))
PYEOF

python "$PY"

UPGRADE_PAGES="$(python - <<'PYEOF'
import json
from pathlib import Path
data = json.loads(Path("worksheets/deltoid/exact_assets/graphics_analysis.json").read_text(encoding="utf-8"))
pages = [str(x["page"]) for x in data if x["upgrade"]]
print(" ".join(pages))
PYEOF
)"

IMGTOOL=""
if command -v magick >/dev/null 2>&1; then
  IMGTOOL="magick"
else
  IMGTOOL="convert"
fi

for p in $UPGRADE_PAGES; do
  pp=$(printf '%02d' "$p")
  echo "Upgrading page $pp"

  rm -f "$ASSET_DIR"/rebuild-"$p"-*.png
  pdftoppm -f "$p" -l "$p" -png -r 400 "$PDF" "$ASSET_DIR/rebuild-$p"

  src=""
  if [ -f "$ASSET_DIR/rebuild-$p-$p.png" ]; then
    src="$ASSET_DIR/rebuild-$p-$p.png"
  elif [ -f "$ASSET_DIR/rebuild-$p-$pp.png" ]; then
    src="$ASSET_DIR/rebuild-$p-$pp.png"
  else
    found="$(find "$ASSET_DIR" -maxdepth 1 -type f -name "rebuild-$p-*.png" | head -n 1 || true)"
    if [ -n "$found" ]; then
      src="$found"
    fi
  fi

  if [ -z "$src" ]; then
    echo "FAILED to locate rebuilt PNG for page $p"
    exit 1
  fi

  cp -f "$src" "$ASSET_DIR/page-$pp-enhanced.png"

  "$IMGTOOL" "$ASSET_DIR/page-$pp-enhanced.png" \
    -colorspace sRGB \
    -strip \
    -filter Lanczos \
    -resize 2480x3508 \
    -unsharp 0x1.2+1.4+0.03 \
    -brightness-contrast 8x18 \
    -sigmoidal-contrast 4,55% \
    "$ASSET_DIR/page-$pp-enhanced.png"

  cat > "$PAGE_DIR/page-$pp.html" <<EOF
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>דלתון מדויק — עמוד $p</title>
  <link rel="stylesheet" href="../../../styles/worksheet.css">
  <link rel="stylesheet" href="../../../styles/exact-facsimile.css">
</head>
<body>
  <div class="exact-shell">
    <main class="a4-page exact-page exact-page-enhanced">
      <img class="exact-image exact-image-enhanced" src="../exact_assets/page-$pp-enhanced.png" alt="דלתון עמוד $p משופר">
    </main>
  </div>
</body>
</html>
EOF
done

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

if ! grep -q "Deep graphics upgrade for low-DPI source pages" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deep graphics upgrade for low-DPI source pages

- כאשר עמודי מקור ב-PDF מכילים שרטוטים ברזולוציה נמוכה, מותר לבצע extraction מחדש ב-DPI גבוה יותר וליצור:
  `page-XX-enhanced.png`
- דפי exact הרלוונטיים חייבים להצביע לקובץ המשופר.
- זהו שיפור חזותי מבוסס מקור, לא שרטוט SVG חדש.
- יש לשמור דוח ניתוח שמסמן אילו עמודים הוגדרו low-DPI ואילו שופרו.
EOF
fi

if ! grep -q "שיפור גרפי עמוק לעמודי מקור חלשים" RULES.md; then
cat >> RULES.md <<'EOF'

---

## שיפור גרפי עמוק לעמודי מקור חלשים

- אם מקור ה-PDF חלש ברזולוציה, מותר ליצור קבצי:
  `page-XX-enhanced.png`
- דפי exact המתאימים חייבים להשתמש בגרסה המשופרת
- זהו שיפור חזותי מתוך המקור, לא הצגה כווקטור חדש
EOF
fi

cat > "$TEST" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("graphics analysis file exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","exact_assets","graphics_analysis.json")), true);
});

test("at least one enhanced page exists", () => {
  const dir = path.join("worksheets","deltoid","exact_assets");
  const files = fs.readdirSync(dir).filter(x => x.endsWith("-enhanced.png"));
  assert.ok(files.length >= 1, "Expected enhanced PNG assets");
});
EOF

npm test | tee deltoid_deep_graphics_test_output.txt

{
  echo "# Deltoid deep graphics upgrade"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## upgraded pages"
  echo "$UPGRADE_PAGES"
  echo
  echo "## graphics analysis"
  cat "$ANALYSIS_JSON"
  echo
  echo "## enhanced assets"
  find worksheets/deltoid/exact_assets -maxdepth 1 -type f -name '*-enhanced.png' | sort
  echo
  echo "## tests"
  cat deltoid_deep_graphics_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$PY" "$TEST" "$CSS" PROJECT_RULES.md RULES.md worksheets/deltoid/exact_assets worksheets/deltoid/exact_pages deltoid_deep_graphics_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: perform deep graphics upgrade for low-dpi deltoid source pages"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "UPGRADED PAGES: $UPGRADE_PAGES"
