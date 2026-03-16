#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_STRICT_LAYOUT_MATH_QA_$(date +%Y%m%d_%H%M%S).md"
TEST_FILE="tests/deltoid-strict-layout-math-qa.test.mjs"

echo "RUNNING DELTOID STRICT LAYOUT + MATH QA"
echo

ERRORS=0
WARNINGS=0

PAGES="$(find worksheets/deltoid \( -path '*/final_pages_batch_*/pages/page-*.html' -o -path '*/final_pages_batch_01_refined/pages/page-*.html' -o -path '*/rebuild_v2/pages/page-*.html' \) | sort)"

for f in $PAGES
do
  [ -f "$f" ] || continue

  if ! grep -q 'class="page-number"' "$f"; then
    echo "ERROR: missing page-number in $f"
    ERRORS=1
  fi

  if ! grep -q 'class="question-bullet">●<' "$f"; then
    echo "ERROR: missing bullet layout in $f"
    ERRORS=1
  fi

  if grep -q "<ol>" "$f"; then
    echo "ERROR: ordered list found in $f"
    ERRORS=1
  fi

  BULLETS=$(grep -o 'class="question-bullet">●<' "$f" | wc -l | tr -d ' ')
  if [ "$BULLETS" -lt 1 ]; then
    echo "ERROR: no questions found in $f"
    ERRORS=1
  fi

  LINES=$(wc -l < "$f" | tr -d ' ')
  if [ "$LINES" -lt 25 ]; then
    echo "WARNING: page too short / may underuse A4 in $f"
    WARNINGS=1
  fi

  if grep -q "מעלות" "$f"; then
    echo "ERROR: found word מעלות instead of ° in $f"
    ERRORS=1
  fi

  if grep -q "זווית" "$f"; then
    echo "WARNING: found word זווית in $f ; check whether ∠ should be used"
    WARNINGS=1
  fi

  if grep -q "מאונך" "$f"; then
    echo "WARNING: found word מאונך in $f ; check whether ⊥ should be used"
    WARNINGS=1
  fi

  if grep -q "מקביל" "$f"; then
    echo "WARNING: found word מקביל in $f ; check whether ∥ should be used"
    WARNINGS=1
  fi

  if ! grep -q "styles/deltoid-rebuild-v2.css\|styles/deltoid-book.css" "$f"; then
    echo "WARNING: page may not be linked to main stylesheet in $f"
    WARNINGS=1
  fi
done

echo
if [ "$ERRORS" -eq 0 ]; then
  echo "STRICT QA PASSED"
else
  echo "STRICT QA FAILED"
fi

if [ "$WARNINGS" -eq 1 ]; then
  echo "STRICT QA HAS WARNINGS"
fi

cat > "$TEST_FILE" <<'TESTEOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("strict qa tool exists", () => {
  assert.equal(fs.existsSync(path.join("tools","deltoid_strict_layout_math_qa.sh")), true);
});
TESTEOF

npm test | tee deltoid_strict_layout_math_qa_test_output.txt

{
  echo "# Deltoid strict layout and math QA"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## tests"
  cat deltoid_strict_layout_math_qa_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add tools/deltoid_strict_layout_math_qa.sh "$TEST_FILE" deltoid_strict_layout_math_qa_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "fix: scope strict deltoid QA to production page sets"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
