#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$HOME/parabula2"
PDF="$ROOT/100 שאלות דלתון.pdf"
OUT="$ROOT/vector_precision_audit"

mkdir -p "$OUT"

echo "=== VECTOR PRECISION AUDIT START ==="

echo
echo "1️⃣ extracting high resolution pages"

mkdir -p "$OUT/pages"

pdftoppm -png -r 600 "$PDF" "$OUT/pages/page"

echo
echo "2️⃣ edge detection for geometry lines"

mkdir -p "$OUT/edges"

for f in "$OUT"/pages/*.png; do
  base=$(basename "$f")
  convert "$f" -colorspace Gray -edge 2 "$OUT/edges/$base"
done

echo
echo "3️⃣ vector vs raster comparison"

mkdir -p "$OUT/diff"

for svg in "$ROOT"/worksheets/deltoid/vector_assets/*.svg; do

  name=$(basename "$svg" .svg)

  if [ -f "$OUT/pages/${name}.png" ]; then

    convert "$svg" "$OUT/tmp.png"

    compare -metric RMSE "$OUT/tmp.png" "$OUT/pages/${name}.png" "$OUT/diff/${name}_diff.png" 2> "$OUT/${name}_rmse.txt" || true

  fi

done

echo
echo "4️⃣ line detection"

mkdir -p "$OUT/lines"

for f in "$OUT"/edges/*.png; do
  convert "$f" -threshold 40% "$OUT/lines/$(basename "$f")"
done

echo
echo "5️⃣ geometry summary"

REPORT="$ROOT/VECTOR_GEOMETRY_AUDIT_$(date +%Y%m%d_%H%M%S).md"

{
echo "# VECTOR GEOMETRY AUDIT"
echo
echo "pages extracted:"
ls "$OUT/pages" | wc -l
echo
echo "edge maps:"
ls "$OUT/edges" | wc -l
echo
echo "line maps:"
ls "$OUT/lines" | wc -l
echo
echo "vector files:"
ls "$ROOT"/worksheets/deltoid/vector_assets/*.svg | wc -l
} > "$REPORT"

echo
echo "6️⃣ git update"

git add "$OUT" "$REPORT" || true

if ! git diff --cached --quiet; then
  git commit -m "deep geometry precision audit"
  git push
fi

echo
echo "=== VECTOR PRECISION AUDIT DONE ==="
echo "REPORT: $REPORT"

