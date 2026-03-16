#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "RUNNING DELTOID QUALITY CHECK"
echo

ERRORS=0
WARNINGS=0

for f in worksheets/deltoid/final_pages_batch_*/pages/page-*.html worksheets/deltoid/final_pages_batch_01_refined/pages/page-*.html
do
  [ -f "$f" ] || continue

  if grep -q "<ol>" "$f"; then
    echo "ERROR: numbered questions found in $f"
    ERRORS=1
  fi

  if ! grep -q 'class="page-number"' "$f"; then
    echo "ERROR: missing page number in $f"
    ERRORS=1
  fi

  if ! grep -q 'class="question-bullet">●<' "$f"; then
    echo "ERROR: missing bullet question layout in $f"
    ERRORS=1
  fi

  if grep -q "מעלות" "$f"; then
    echo "ERROR: found word מעלות instead of ° in $f"
    ERRORS=1
  fi

  if grep -q "זווית" "$f"; then
    echo "WARNING: check mathematical symbol ∠ in $f"
    WARNINGS=1
  fi

  if grep -q "מקביל" "$f"; then
    echo "WARNING: check symbol ∥ in $f"
    WARNINGS=1
  fi

  if grep -q "מאונך" "$f"; then
    echo "WARNING: check symbol ⊥ in $f"
    WARNINGS=1
  fi
done

echo
if [ $ERRORS -eq 0 ]; then
  echo "QUALITY CHECK PASSED"
else
  echo "QUALITY CHECK FAILED"
fi

if [ $WARNINGS -eq 1 ]; then
  echo "QUALITY CHECK HAS WARNINGS"
fi
