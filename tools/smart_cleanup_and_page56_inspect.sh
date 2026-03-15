#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_SMART_CLEANUP_PAGE56_$(date +%Y%m%d_%H%M%S).md"
PDF="sources/geometry/deltoid/source.pdf"
EXACT_DIR="worksheets/deltoid/exact_pages"
ARCHIVE_DIR="worksheets/deltoid/exact_pages_archive"
STATUS_JSON="worksheets/deltoid/graphics-status.json"
QA_MD="worksheets/deltoid/VECTOR_QA.md"
PAGE56_DIR="worksheets/deltoid/page56_inspection"
TEST_FILE="tests/deltoid-repo-qa.test.mjs"

mkdir -p tools tests "$EXACT_DIR" "$ARCHIVE_DIR" "$PAGE56_DIR"

if [ ! -f "$PDF" ]; then
  echo "MISSING SOURCE PDF: $PDF"
  exit 1
fi

if ! command -v pdftoppm >/dev/null 2>&1 || ! command -v pdftotext >/dev/null 2>&1 || ! command -v pdfimages >/dev/null 2>&1 || ! command -v pdfinfo >/dev/null 2>&1; then
  pkg install -y poppler
fi

if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
  pkg install -y imagemagick
fi

IMGTOOL="convert"
if command -v magick >/dev/null 2>&1; then
  IMGTOOL="magick"
fi

# 1) Move non-canonical exact pages to archive, never delete
find "$EXACT_DIR" -maxdepth 1 -type f -name 'page-*.html' | while read -r f; do
  base="$(basename "$f")"
  if ! printf '%s' "$base" | grep -Eq '^page-[0-9]{2}\.html$'; then
    mv -f "$f" "$ARCHIVE_DIR/$base"
  fi
done

# 2) Build precise graphics status
cat > tools/rebuild_graphics_status_precise.py <<'PYEOF'
from __future__ import annotations
import json
import re
from pathlib import Path

PDF_PAGES = 60

exact_dir = Path("worksheets/deltoid/exact_pages")
enhanced_dir = Path("worksheets/deltoid/exact_assets")
vector_pages_dir = Path("worksheets/deltoid/vector_pages")
vector_assets_dir = Path("worksheets/deltoid/vector_assets")
status_path = Path("worksheets/deltoid/graphics-status.json")
qa_path = Path("worksheets/deltoid/VECTOR_QA.md")

def page_id_from_name(name: str):
    m = re.search(r'^page-(\d+)(?:-vector)?\.html$|^page-(\d+)(?:-enhanced)?\.png$', name)
    if not m:
        return None
    g1 = m.group(1) or m.group(2)
    return g1.zfill(2) if g1 else None

exact_pages = sorted([p for p in exact_dir.glob("page-*.html") if re.match(r"^page-\d{2}\.html$", p.name)])
enhanced_assets = sorted([p for p in enhanced_dir.glob("page-*-enhanced.png") if page_id_from_name(p.name)])
vector_pages = sorted([p for p in vector_pages_dir.glob("page-*.html") if page_id_from_name(p.name)])
vector_assets = sorted(vector_assets_dir.glob("*.svg"))

exact_ids = {page_id_from_name(p.name) for p in exact_pages}
enhanced_ids = {page_id_from_name(p.name) for p in enhanced_assets}
vector_ids = {page_id_from_name(p.name) for p in vector_pages}

records = []
for n in range(1, PDF_PAGES + 1):
    pid = str(n).zfill(2)
    state = "exact"
    verified = False
    notes = []

    if pid in enhanced_ids:
        state = "enhanced"
        notes.append("enhanced asset exists")

    if pid in vector_ids:
        state = "vector"
        notes.append("vector page exists")

    if pid in {"09", "38", "42"}:
        verified = True
        notes.append("manually advanced in repo")

    priority = "normal"
    if pid in {"56", "63", "72", "78", "84", "91", "41", "05"}:
        priority = "high"
    if pid in {"09", "38", "42"}:
        priority = "done"

    records.append({
        "page": int(pid),
        "page_id": pid,
        "state": state,
        "verified": verified,
        "priority": priority,
        "notes": notes
    })

status = {
    "topic": "דלתון",
    "source": "sources/geometry/deltoid/source.pdf",
    "source_pdf_page_count": PDF_PAGES,
    "exact_page_count": len(exact_pages),
    "enhanced_asset_count": len(enhanced_assets),
    "vector_page_count": len(vector_pages),
    "vector_asset_count": len(vector_assets),
    "records": records
}

status_path.write_text(json.dumps(status, ensure_ascii=False, indent=2), encoding="utf-8")

lines = []
lines.append("# VECTOR_QA — דלתון")
lines.append("")
lines.append(f"- source pdf pages: {PDF_PAGES}")
lines.append(f"- exact pages: {len(exact_pages)}")
lines.append(f"- enhanced assets: {len(enhanced_assets)}")
lines.append(f"- vector pages: {len(vector_pages)}")
lines.append("")
lines.append("## Completed / advanced pages")
for pid in sorted(vector_ids, key=lambda x: int(x)):
    lines.append(f"- page {int(pid)} — vector page exists")
lines.append("")
lines.append("## High-priority next pages")
for pid in ["56","41","05","63","72","78","84","91"]:
    rec = next((r for r in records if r["page_id"] == pid), None)
    state = rec["state"] if rec else "missing"
    lines.append(f"- page {int(pid)} — current state: {state}")
lines.append("")
lines.append("## QA rules")
lines.append("- no inline CSS in vector HTML pages")
lines.append("- external SVG preferred for rebuilt geometry")
lines.append("- every rebuilt page must have a matching test")
lines.append("- exact pages count must equal source PDF page count (60)")
qa_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(json.dumps({
    "source_pdf_page_count": PDF_PAGES,
    "exact_pages": len(exact_pages),
    "enhanced_assets": len(enhanced_assets),
    "vector_pages": len(vector_pages),
    "vector_assets": len(vector_assets)
}, ensure_ascii=False, indent=2))
PYEOF

python tools/rebuild_graphics_status_precise.py | tee worksheets/deltoid/graphics-status-build.out.json

# 3) Deep inspection for page 56
rm -f "$PAGE56_DIR"/*
pdftoppm -f 56 -l 56 -png -r 700 "$PDF" "$PAGE56_DIR/page56"
pdftotext -f 56 -l 56 "$PDF" "$PAGE56_DIR/page-56.txt"
pdfimages -f 56 -l 56 -list "$PDF" > "$PAGE56_DIR/page-56-images.txt"

RAW56="$(find "$PAGE56_DIR" -maxdepth 1 -type f -name 'page56-*.png' | head -n 1)"
cp -f "$RAW56" "$PAGE56_DIR/page-56-raw.png"

"$IMGTOOL" "$PAGE56_DIR/page-56-raw.png" \
  -colorspace sRGB -strip -filter Lanczos -resize 2480x3508 \
  -unsharp 0x1.4+1.8+0.03 -brightness-contrast 12x22 \
  -sigmoidal-contrast 5,55% "$PAGE56_DIR/page-56-enhanced.png"

"$IMGTOOL" "$PAGE56_DIR/page-56-raw.png" \
  -colorspace Gray -contrast-stretch 0.5%x0.5% -threshold 62% \
  "$PAGE56_DIR/page-56-lines.png"

# 4) Rules
if ! grep -q "Exact pages count integrity" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Exact pages count integrity

- דפי exact תחת `worksheets/deltoid/exact_pages/` חייבים לייצג את דפי המקור בלבד.
- הספירה הצפויה לקובץ הדלתון היא 60 עמודים.
- דפי vector אינם נספרים כ-exact pages.
- כל שינוי במצב הגרפי חייב לעדכן את:
  `worksheets/deltoid/graphics-status.json`
EOF
fi

if ! grep -q "שלמות ספירת exact" RULES.md; then
cat >> RULES.md <<'EOF'

---

## שלמות ספירת exact

- exact pages = דפי מקור בלבד
- vector pages = קטגוריה נפרדת
- אסור לערבב ביניהם
- לפני rebuild חדש חובה לבדוק שהספירה נשארת תקינה
EOF
fi

# 5) Strong QA tests
cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("graphics status json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","graphics-status.json")), true);
});

test("vector qa markdown exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","VECTOR_QA.md")), true);
});

test("page 56 inspection assets exist", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page56_inspection","page-56-raw.png")), true);
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page56_inspection","page-56-enhanced.png")), true);
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page56_inspection","page-56-lines.png")), true);
});

test("exact page count is 60", () => {
  const dir = path.join("worksheets","deltoid","exact_pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.html$/i.test(x));
  assert.equal(files.length, 60);
});

test("all vector html files have no inline style", () => {
  const dir = path.join("worksheets","deltoid","vector_pages");
  if (!fs.existsSync(dir)) return;
  const files = fs.readdirSync(dir).filter(x => /^page-.*\.html$/i.test(x));
  for (const file of files) {
    const html = fs.readFileSync(path.join(dir, file), "utf8");
    assert.equal(html.includes('style="'), false, `${file} has inline style attribute`);
    assert.equal(html.includes('<style'), false, `${file} has inline style block`);
  }
});
EOF

npm test | tee deltoid_power_upgrade_test_output.txt

{
  echo "# Deltoid smart cleanup and page 56 inspection"
  echo
  echo "- time: $(date -Iseconds)"
  echo "- source: $PDF"
  echo
  echo "## graphics status"
  cat "$STATUS_JSON"
  echo
  echo "## vector qa"
  cat "$QA_MD"
  echo
  echo "## archived exact pages"
  find "$ARCHIVE_DIR" -maxdepth 1 -type f | sort || true
  echo
  echo "## page 56 inspection files"
  find "$PAGE56_DIR" -maxdepth 1 -type f | sort
  echo
  echo "## tests"
  cat deltoid_power_upgrade_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add tools/rebuild_graphics_status_precise.py "$STATUS_JSON" "$QA_MD" "$PAGE56_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md worksheets/deltoid/graphics-status-build.out.json deltoid_power_upgrade_test_output.txt "$REPORT" "$ARCHIVE_DIR"

if ! git diff --cached --quiet; then
  git commit -m "feat: clean exact pages registry and prepare page 56 vector work"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "NEXT HIGH PRIORITY: page 56 vector rebuild"
