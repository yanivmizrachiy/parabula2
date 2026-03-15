#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_IMAGE_INVENTORY_$(date +%Y%m%d_%H%M%S).md"
PDF="sources/geometry/deltoid/source.pdf"
OUT_DIR="worksheets/deltoid/image_inventory"
PAGE_DIR="$OUT_DIR/pages"
THUMB_DIR="$OUT_DIR/thumbs"
JSON_OUT="$OUT_DIR/image_inventory.json"
HTML_OUT="$OUT_DIR/gallery.html"
TEST_FILE="tests/deltoid-image-inventory.test.mjs"

mkdir -p "$PAGE_DIR" "$THUMB_DIR" tests tools

if [ ! -f "$PDF" ]; then
  echo "MISSING PDF: $PDF"
  exit 1
fi

if ! command -v pdfinfo >/dev/null 2>&1 || ! command -v pdftoppm >/dev/null 2>&1; then
  pkg install -y poppler
fi

if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
  pkg install -y imagemagick
fi

IMGTOOL="convert"
if command -v magick >/dev/null 2>&1; then
  IMGTOOL="magick"
fi

PAGES="$(pdfinfo "$PDF" | awk -F: "/Pages/ {gsub(/ /, \"\", \$2); print \$2}")"
if [ -z "${PAGES:-}" ]; then
  echo "FAILED TO DETECT PAGE COUNT"
  exit 1
fi

rm -f "$PAGE_DIR"/*.png "$THUMB_DIR"/*.png

pdftoppm -png -r 220 "$PDF" "$PAGE_DIR/page"

for f in "$PAGE_DIR"/page-*.png; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  "$IMGTOOL" "$f" -resize 360x "$THUMB_DIR/$base"
done

python - <<'PYEOF'
from __future__ import annotations
import json
from pathlib import Path

out_dir = Path("worksheets/deltoid/image_inventory")
page_dir = out_dir / "pages"
thumb_dir = out_dir / "thumbs"

page_files = sorted(page_dir.glob("page-*.png"))
records = []

for p in page_files:
    thumb = thumb_dir / p.name
    records.append({
        "page": int(p.stem.split("-")[-1]),
        "image": str(p).replace("\\","/"),
        "thumb": str(thumb).replace("\\","/"),
        "size_bytes": p.stat().st_size,
        "thumb_exists": thumb.exists()
    })

summary = {
    "project": "parabula2",
    "topic": "דלתון",
    "source_pdf": "sources/geometry/deltoid/source.pdf",
    "page_count": len(records),
    "records": records
}

(out_dir / "image_inventory.json").write_text(
    json.dumps(summary, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

html = []
html.append("<!DOCTYPE html>")
html.append('<html lang="he" dir="rtl">')
html.append("<head>")
html.append('<meta charset="utf-8">')
html.append('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
html.append("<title>Deltoid Image Inventory</title>")
html.append("<style>")
html.append("body{font-family:Arial,sans-serif;background:#f8fafc;margin:0;padding:24px}")
html.append("h1{margin:0 0 24px 0}")
html.append(".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:16px}")
html.append(".card{background:#fff;border:1px solid #cbd5e1;border-radius:16px;padding:12px;box-shadow:0 4px 14px rgba(0,0,0,.05)}")
html.append(".card img{width:100%;height:auto;display:block;border-radius:10px;border:1px solid #e2e8f0}")
html.append(".meta{margin-top:10px;font-size:14px;color:#334155}")
html.append(".meta a{word-break:break-all}")
html.append("</style>")
html.append("</head>")
html.append("<body>")
html.append("<h1>Deltoid Image Inventory</h1>")
html.append('<div class="grid">')
for r in records:
    html.append('<div class="card">')
    html.append(f'<a href="{Path(r["image"]).name}" target="_blank"><img src="thumbs/{Path(r["thumb"]).name}" alt="page {r["page"]}"></a>')
    html.append(f'<div class="meta">עמוד {r["page"]:02d}<br>גודל: {r["size_bytes"]} bytes<br><a href="pages/{Path(r["image"]).name}" target="_blank">פתח עמוד מלא</a></div>')
    html.append("</div>")
html.append("</div>")
html.append("</body>")
html.append("</html>")

(out_dir / "gallery.html").write_text("\n".join(html) + "\n", encoding="utf-8")

print(json.dumps({
    "page_count": len(records),
    "first_page": records[0]["image"] if records else None,
    "last_page": records[-1]["image"] if records else None
}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("image inventory json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","image_inventory","image_inventory.json")), true);
});

test("image gallery exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","image_inventory","gallery.html")), true);
});

test("all 60 page images exist", () => {
  const dir = path.join("worksheets","deltoid","image_inventory","pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.png$/i.test(x));
  assert.equal(files.length, 60);
});

test("all 60 thumbnails exist", () => {
  const dir = path.join("worksheets","deltoid","image_inventory","thumbs");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.png$/i.test(x));
  assert.equal(files.length, 60);
});
EOF

if ! grep -q "Deltoid image inventory" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deltoid image inventory

- הקובץ נחשב image-first PDF
- יש לשמור inventory גרפי מלא תחת:
  `worksheets/deltoid/image_inventory/`
- לכל עמוד חייבים להיות:
  - page png
  - thumb png
- gallery.html הוא כלי העבודה הראשי למיפוי ויזואלי של הספר
EOF
fi

if ! grep -q "אינדקס גרפי לדלתון" RULES.md; then
cat >> RULES.md <<'EOF'

---

## אינדקס גרפי לדלתון

- כאשר חילוץ הטקסט חלש, עובדים מתוך תמונות העמודים
- יש להפיק לכל 60 העמודים תמונת PNG ותמונה מוקטנת
- העבודה על שחזור הספר תתבסס קודם על gallery חזותי ולא על text extraction
EOF
fi

npm test | tee deltoid_image_inventory_test_output.txt

{
  echo "# Deltoid image inventory build"
  echo
  echo "- time: $(date -Iseconds)"
  echo "- source: $PDF"
  echo
  echo "## image inventory summary"
  cat "$JSON_OUT"
  echo
  echo "## tests"
  cat deltoid_image_inventory_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md deltoid_image_inventory_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: build full deltoid image inventory and gallery for 60 pages"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "GALLERY: $HTML_OUT"
echo "NEXT HIGH PRIORITY: build visual page map from image inventory"
