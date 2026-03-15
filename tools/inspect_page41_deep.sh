#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_PAGE41_DEEP_INSPECTION_$(date +%Y%m%d_%H%M%S).md"
PDF="sources/geometry/deltoid/source.pdf"
OUT="worksheets/deltoid/page41_inspection"
TEST_FILE="tests/deltoid-page41-inspection.test.mjs"

mkdir -p "$OUT" tests

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

rm -f "$OUT"/*

pdftoppm -f 41 -l 41 -png -r 700 "$PDF" "$OUT/page41"
pdftotext -f 41 -l 41 "$PDF" "$OUT/page-41.txt"
pdfimages -f 41 -l 41 -list "$PDF" > "$OUT/page-41-images.txt"

RAW="$(find "$OUT" -maxdepth 1 -type f -name 'page41-*.png' | head -n 1)"
cp -f "$RAW" "$OUT/page-41-raw.png"

"$IMGTOOL" "$OUT/page-41-raw.png" \
  -colorspace sRGB -strip -filter Lanczos -resize 2480x3508 \
  -unsharp 0x1.4+1.8+0.03 -brightness-contrast 12x22 \
  -sigmoidal-contrast 5,55% "$OUT/page-41-enhanced.png"

"$IMGTOOL" "$OUT/page-41-raw.png" \
  -colorspace Gray -contrast-stretch 0.5%x0.5% -threshold 62% \
  "$OUT/page-41-lines.png"

python - <<'PYEOF'
from pathlib import Path
import json

out = Path("worksheets/deltoid/page41_inspection")
summary = {
    "page": 41,
    "files": sorted([p.name for p in out.iterdir() if p.is_file()])
}
(out / "page-41-summary.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps(summary, ensure_ascii=False, indent=2))
PYEOF

if ! grep -q "page 41 inspection" worksheets/deltoid/VECTOR_QA.md; then
cat >> worksheets/deltoid/VECTOR_QA.md <<'EOF'

- page 41 — deep inspection prepared, awaiting precise vector rebuild
EOF
fi

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("page 41 inspection assets exist", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page41_inspection","page-41-raw.png")), true);
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page41_inspection","page-41-enhanced.png")), true);
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page41_inspection","page-41-lines.png")), true);
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page41_inspection","page-41-images.txt")), true);
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page41_inspection","page-41.txt")), true);
});
EOF

npm test | tee deltoid_page41_inspection_test_output.txt

{
  echo "# Deltoid page 41 deep inspection"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## files"
  find "$OUT" -maxdepth 1 -type f | sort
  echo
  echo "## image list"
  cat "$OUT/page-41-images.txt"
  echo
  echo "## extracted text"
  cat "$OUT/page-41.txt" || true
  echo
  echo "## tests"
  cat deltoid_page41_inspection_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT" worksheets/deltoid/VECTOR_QA.md "$TEST_FILE" deltoid_page41_inspection_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: add deep inspection for deltoid page 41"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "NEXT: precise vector rebuild for page 41"
