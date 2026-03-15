#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_GRAPHICS_SYSTEM_ADVANCE_FIX_$(date +%Y%m%d_%H%M%S).md"
PDF="sources/geometry/deltoid/source.pdf"
STATUS_JSON="worksheets/deltoid/graphics-status.json"
QA_MD="worksheets/deltoid/VECTOR_QA.md"
PAGE56_DIR="worksheets/deltoid/page56_inspection"
TEST_FILE="tests/deltoid-graphics-system.test.mjs"

mkdir -p tools tests worksheets/deltoid "$PAGE56_DIR"

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

cat > tools/build_deltoid_graphics_status.py <<'PYEOF'
from __future__ import annotations
import json
import re
from pathlib import Path

status_path = Path("worksheets/deltoid/graphics-status.json")
qa_path = Path("worksheets/deltoid/VECTOR_QA.md")

exact_pages = sorted(Path("worksheets/deltoid/exact_pages").glob("page-*.html"))
enhanced_assets = sorted(Path("worksheets/deltoid/exact_assets").glob("page-*-enhanced.png"))
vector_pages = sorted(Path("worksheets/deltoid/vector_pages").glob("page-*.html"))
vector_assets = sorted(Path("worksheets/deltoid/vector_assets").glob("*.svg"))

def extract_page_id(name: str) -> str | None:
    m = re.search(r'page-(\d+)', name)
    if m:
        return m.group(1).zfill(2)
    return None

enhanced_nums = {extract_page_id(p.stem) for p in enhanced_assets}
enhanced_nums = {x for x in enhanced_nums if x}

vector_nums = {extract_page_id(p.stem) for p in vector_pages}
vector_nums = {x for x in vector_nums if x}

exact_nums = {extract_page_id(p.stem) for p in exact_pages}
exact_nums = {x for x in exact_nums if x}

all_nums = sorted(exact_nums, key=lambda x: int(x))

records = []
for num in all_nums:
    state = "exact"
    verified = False
    notes = []

    if num in enhanced_nums:
        state = "enhanced"
        notes.append("enhanced asset exists")

    if num in vector_nums:
        state = "vector"
        notes.append("vector page exists")

    if num in {"09", "38", "42"}:
        verified = True
        notes.append("manually advanced in repo")

    priority = "normal"
    if num in {"56", "63", "72", "78", "84", "91"}:
        priority = "high"
    if num in {"09", "38", "42"}:
        priority = "done"

    records.append({
        "page": int(num),
        "page_id": num,
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

status_path.write_text(json.dumps(status, ensure_ascii=False, indent=2), encoding="utf-8")

lines = []
lines.append("# VECTOR_QA — דלתון")
lines.append("")
lines.append(f"- exact pages: {len(exact_pages)}")
lines.append(f"- enhanced assets: {len(enhanced_assets)}")
lines.append(f"- vector pages: {len(vector_pages)}")
lines.append("")
lines.append("## Completed / advanced pages")
for n in sorted(vector_nums, key=lambda x: int(x)):
    lines.append(f"- page {int(n)} — vector or advanced treatment exists")
lines.append("")
lines.append("## High-priority next pages")
for n in ["56","63","72","78","84","91"]:
    state = next((r["state"] for r in records if r["page_id"] == n), "missing")
    lines.append(f"- page {int(n)} — current state: {state}")
lines.append("")
lines.append("## QA rules")
lines.append("- no inline CSS in vector HTML pages")
lines.append("- external SVG preferred for rebuilt geometry")
lines.append("- every rebuilt page must have a matching test")
lines.append("- every significant change must update graphics-status.json")

qa_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(json.dumps({
    "status_json": str(status_path),
    "qa_md": str(qa_path),
    "exact_pages": len(exact_pages),
    "enhanced_assets": len(enhanced_assets),
    "vector_pages": len(vector_pages)
}, ensure_ascii=False, indent=2))
PYEOF

python tools/build_deltoid_graphics_status.py | tee worksheets/deltoid/graphics-status-build.out.json

rm -f "$PAGE56_DIR"/*
pdftoppm -f 56 -l 56 -png -r 600 "$PDF" "$PAGE56_DIR/page56"
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

if ! grep -q "Graphics status registry" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Graphics status registry

- כל מצב גרפי של דפי דלתון חייב להירשם בקובץ:
  `worksheets/deltoid/graphics-status.json`
- לכל עמוד חייב להיות state ברור:
  `exact` / `enhanced` / `vector`
- עמודים מועמדים לשדרוג חייבים להופיע גם ב:
  `worksheets/deltoid/VECTOR_QA.md`
- כל שיפור גרפי משמעותי חייב לעדכן את שני הקבצים.
EOF
fi

if ! grep -q "מרשם מצב גרפי" RULES.md; then
cat >> RULES.md <<'EOF'

---

## מרשם מצב גרפי

- לכל עמוד בדלתון חייב להיות מצב גרפי ברור:
  exact / enhanced / vector
- מקור האמת הוא:
  `worksheets/deltoid/graphics-status.json`
- תיעוד QA נשמר ב:
  `worksheets/deltoid/VECTOR_QA.md`
- לפני rebuild וקטורי חדש, חייב להיות inspection לעמוד הרלוונטי
EOF
fi

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
EOF

npm test | tee deltoid_graphics_system_test_output.txt

{
  echo "# Deltoid graphics system advance"
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
  cat deltoid_graphics_system_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add tools/build_deltoid_graphics_status.py "$STATUS_JSON" "$QA_MD" "$PAGE56_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md worksheets/deltoid/graphics-status-build.out.json deltoid_graphics_system_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: add graphics status registry and page 56 deep inspection"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "NEXT HIGH PRIORITY: page 56 vector rebuild"
