#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

echo "RUNNING DELTOID AUTO MATH SYMBOL NORMALIZER"
echo

FILES=$(find worksheets/deltoid -path "*/pages/page-*.html")

for f in $FILES
do
  sed -i 's/זווית/∠/g' "$f"
  sed -i 's/מעלות/°/g' "$f"
  sed -i 's/מקביל/∥/g' "$f"
  sed -i 's/מאונך/⟂/g' "$f"
  sed -i 's/משולש/△/g' "$f"
done

echo
echo "MATH SYMBOL NORMALIZATION COMPLETE"
