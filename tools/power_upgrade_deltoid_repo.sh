#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_POWER_UPGRADE_$(date +%Y%m%d_%H%M%S).md"
PDF="sources/geometry/deltoid/source.pdf"
STATUS_JSON="worksheets/deltoid/graphics-status.json"
QA_MD="worksheets/deltoid/VECTOR_QA.md"
PAGE56_DIR="worksheets/deltoid/page56_inspection"
VECTOR_CSS="styles/vector-pages.css"
TEST_FILE="tests/deltoid-repo-qa.test.mjs"

mkdir -p tools tests worksheets/deltoid "$PAGE56_DIR" styles worksheets/deltoid/vector_pages

if [ ! -f "$PDF" ]; then
  echo "MISSING SOURCE PDF: $PDF"
  exit 1
fi

if ! command -v pdftoppm >/dev/null 2>&1 || ! command -v pdftotext >/dev/null 2>&1 || ! command -v pdfimages >/dev/null 2>&1; then
  pkg install -y poppler
fi

if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
  pkg install -y imagemagick
fi

IMGTOOL="convert"
if command -v magick >/dev/null 2>&1; then
  IMGTOOL="magick"
fi

# 1) Harden vector CSS
if [ ! -f "$VECTOR_CSS" ]; then
  cat > "$VECTOR_CSS" <<'EOF'
.vector-page-shell{
  display:flex;
  justify-content:center;
  align-items:flex-start;
  min-height:100vh;
  padding:24px 12px;
  background:#eef3f9;
}
.vector-page{
  width:210mm;
  min-height:297mm;
  margin:0 auto;
  background:#ffffff;
  box-shadow:0 10px 30px rgba(0,0,0,.08);
  padding:18mm 16mm;
}
.vector-figure-wrap{
  display:flex;
  justify-content:center;
  align-items:center;
  margin-top:40px;
}
.vector-figure{
  width:70%;
  max-width:100%;
  display:block;
}
.vector-notes{
  display:grid;
  grid-template-columns:1fr;
  gap:16px;
  margin-top:24px;
}
.vector-line{
  border-bottom:2px solid #111827;
  min-height:24px;
}
@media print{
  .vector-page-shell{padding:0;min-height:auto;background:#fff}
  .vector-page{margin:0;box-shadow:none}
}
EOF
else
  if ! grep -q "vector-figure-wrap" "$VECTOR_CSS"; then
    cat >> "$VECTOR_CSS" <<'EOF'

.vector-figure-wrap{
  display:flex;
  justify-content:center;
  align-items:center;
  margin-top:40px;
}
.vector-figure{
  width:70%;
  max-width:100%;
  display:block;
}
EOF
  fi
fi

# 2) Clean page 42 vector HTML (remove inline style)
if [ -f "worksheets/deltoid/vector_pages/page-42-vector.html" ]; then
cat > worksheets/deltoid/vector_pages/page-42-vector.html <<'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>דלתון — עמוד 42</title>
  <link rel="stylesheet" href="../../styles/worksheet.css">
  <link rel="stylesheet" href="../../styles/vector-pages.css">
</head>
<body>
  <div class="vector-page-shell">
    <main class="a4-page vector-page">
      <header class="worksheet-header">
        <h1 class="page-title">שאלה 78 — דלתון</h1>
        <div class="page-number">42</div>
      </header>

      <section class="questions">
        <div class="question">
          <span class="q-bullet"></span>
          <div>ABCD הוא דלתון. G,H על האלכסון BD, ונתון BG = HD.</div>
        </div>

        <div class="question">
          <span class="q-bullet"></span>
          <div>הוכיחו שהמרובע AGCH הוא דלתון.</div>
        </div>

        <div class="vector-figure-wrap">
          <img class="vector-figure" src="../vector_assets/deltoid_page42.svg" alt="שרטוט וקטורי לעמוד 42">
        </div>
      </section>
    </main>
  </div>
</body>
</html>
EOF
fi

# 3) Rebuild graphics status precisely
cat > tools/rebuild_graphics_status_precise.py <<'PYEOF'
from __future__ import annotations
import json
import re
from pathlib import Path

root = Path(".")
exact_dir = Path("worksheets/deltoid/exact_pages")
enhanced_dir = Path("worksheets/deltoid/exact_assets")
vector_pages_dir = Path("worksheets/deltoid/vector_pages")
vector_assets_dir = Path("worksheets/deltoid/vector_assets")

def page_id_from_name(name: str):
    m = re.search(r'page-(\d+)', name)
    return m.group(1).zfill(2) if m else None

exact_pages = sorted([p for p in exact_dir.glob("page-*.html") if page_id_from_name(p.name)])
enhanced_assets = sorted([p for p in enhanced_dir.glob("page-*-enhanced.png") if page_id_from_name(p.name)])
vector_pages = sorted([p for p in vector_pages_dir.glob("page-*.html") if page_id_from_name(p.name)])
vector_assets = sorted(vector_assets_dir.glob("*.svg"))

exact_ids = {page_id_from_name(p.name) for p in exact_pages}
enhanced_ids = {page_id_from_name(p.name) for p in enhanced_assets}
vector_ids = {page_id_from_name(p.name) for p in vector_pages}

records = []
for pid in sorted(exact_ids, key=lambda x: int(x)):
    state = "exact"
    verified = False
    notes = []

    if pid in enhanced_ids:
        state = "enhanced"
        notes.append("enhanced asset exists")

    if pid in vector_ids:
        state = "vector"
        notes.append("vector page exists")

    if pid in {"09","38","42"}:
        verified = True
        notes.append("manually advanced in repo")

    priority = "normal"
    if pid in {"56","63","72","78","84","91"}:
        priority = "high"
    if pid in {"09","38","42"}:
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
    "exact_page_count": len(exact_pages),
    "enhanced_asset_count": len(enhanced_assets),
    "vector_page_count": len(vector_pages),
    "vector_asset_count": len(vector_assets),
    "records": records
}

Path("worksheets/deltoid/graphics-status.json").write_text(
    json.dumps(status, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

lines = []
lines.append("# VECTOR_QA — דלתון")
lines.append("")
lines.append(f"- exact pages: {len(exact_pages)}")
lines.append(f"- enhanced assets: {len(enhanced_assets)}")
lines.append(f"- vector pages: {len(vector_pages)}")
lines.append("")
lines.append("## Completed / advanced pages")
for pid in sorted(vector_ids, key=lambda x: int(x)):
    lines.append(f"- page {int(pid)} — vector page exists")
lines.append("")
lines.append("## High-priority next pages")
for pid in ["56","63","72","78","84","91"]:
    rec = next((r for r in records if r["page_id"] == pid), None)
    state = rec["state"] if rec else "missing"
    lines.append(f"- page {int(pid)} — current state: {state}")
lines.append("")
lines.append("## QA rules")
lines.append("- no inline CSS in vector HTML pages")
lines.append("- external SVG preferred for rebuilt geometry")
lines.append("- every rebuilt page must have a matching test")
lines.append("- exact pages count should match the source PDF page count (60)")
Path("worksheets/deltoid/VECTOR_QA.md").write_text("\n".join(lines) + "\n", encoding="utf-8")

print(json.dumps({
    "exact_pages": len(exact_pages),
    "enhanced_assets": len(enhanced_assets),
    "vector_pages": len(vector_pages),
    "vector_assets": len(vector_assets)
}, ensure_ascii=False, indent=2))
PYEOF

python tools/rebuild_graphics_status_precise.py | tee worksheets/deltoid/graphics-status-build.out.json

# 4) Deep inspection for page 56
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

# 5) Rules upgrade
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

# 6) Strong QA tests
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
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.html$/i.test(x));
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
  echo "# Deltoid power upgrade"
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
  echo "## page 56 inspection files"
  find "$PAGE56_DIR" -maxdepth 1 -type f | sort
  echo
  echo "## tests"
  cat deltoid_power_upgrade_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add tools/rebuild_graphics_status_precise.py "$STATUS_JSON" "$QA_MD" "$PAGE56_DIR" "$VECTOR_CSS" "$TEST_FILE" PROJECT_RULES.md RULES.md worksheets/deltoid/graphics-status-build.out.json deltoid_power_upgrade_test_output.txt "$REPORT" worksheets/deltoid/vector_pages/page-42-vector.html

if ! git diff --cached --quiet; then
  git commit -m "feat: power-up deltoid repo integrity and page 56 inspection"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "NEXT HIGH PRIORITY: page 56 vector rebuild"
