#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_PAGE41_VECTOR_PRECISE_$(date +%Y%m%d_%H%M%S).md"
SVG_DIR="worksheets/deltoid/vector_assets"
PAGE_DIR="worksheets/deltoid/vector_pages"
CSS_FILE="styles/vector-pages.css"
TEST_FILE="tests/deltoid-page41-vector.test.mjs"

mkdir -p "$SVG_DIR" "$PAGE_DIR" tests styles

if [ ! -f "$CSS_FILE" ]; then
cat > "$CSS_FILE" <<'EOF'
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
  margin-top:32px;
}
.vector-figure{
  width:420px;
  max-width:100%;
  display:block;
}
.vector-notes{
  display:grid;
  grid-template-columns:1fr;
  gap:14px;
  margin-top:24px;
}
.vector-line{
  border-bottom:2px solid #111827;
  min-height:22px;
}
@media print{
  .vector-page-shell{padding:0;min-height:auto;background:#fff}
  .vector-page{margin:0;box-shadow:none}
}
EOF
fi

cat > "$SVG_DIR/deltoid_page41_precise.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 760">
  <defs>
    <style>
      .edge{stroke:#111827;stroke-width:5;fill:none;vector-effect:non-scaling-stroke}
      .inner{stroke:#111827;stroke-width:4;fill:none;vector-effect:non-scaling-stroke}
      .label{font-family:Heebo, Arial, sans-serif;font-size:34px;fill:#111827}
    </style>
  </defs>

  <!-- A top, E on extension of AD, BC horizontal -->
  <line class="edge" x1="360" y1="110" x2="170" y2="420"/>
  <line class="edge" x1="360" y1="110" x2="550" y2="420"/>
  <line class="edge" x1="170" y1="420" x2="360" y2="620"/>
  <line class="edge" x1="550" y1="420" x2="360" y2="620"/>

  <!-- BC -->
  <line class="inner" x1="170" y1="420" x2="550" y2="420"/>

  <!-- AD / DE axis -->
  <line class="inner" x1="360" y1="110" x2="360" y2="620"/>

  <!-- labels -->
  <text class="label" x="348" y="92">A</text>
  <text class="label" x="138" y="432">B</text>
  <text class="label" x="563" y="432">C</text>
  <text class="label" x="372" y="436">D</text>
  <text class="label" x="348" y="655">E</text>
</svg>
EOF

cat > "$PAGE_DIR/page-41-vector.html" <<'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>דלתון — עמוד 41 וקטורי</title>
  <link rel="stylesheet" href="../../styles/worksheet.css">
  <link rel="stylesheet" href="../../styles/vector-pages.css">
</head>
<body>
  <div class="vector-page-shell">
    <main class="a4-page vector-page">
      <header class="worksheet-header">
        <h1 class="page-title">שאלה 77 — דלתון</h1>
        <div class="page-number">41</div>
      </header>

      <section class="questions">
        <div class="question">
          <span class="q-bullet"></span>
          <div>משולש \(ABC\) שווה־שוקיים \((AB=AC)\). \(AD\) תיכון לצלע \(BC\). \(E\) על המשך \(AD\).</div>
        </div>

        <div class="question">
          <span class="q-bullet"></span>
          <div>הסבירו מדוע המשולש \(BEC\) שווה־שוקיים, והסבירו מדוע המרובע \(ABEC\) הוא דלתון.</div>
        </div>

        <div class="vector-figure-wrap">
          <img class="vector-figure" src="../vector_assets/deltoid_page41_precise.svg" alt="שרטוט וקטורי לעמוד 41">
        </div>

        <div class="vector-notes">
          <div class="question"><span class="q-bullet"></span><div>נתון:</div></div>
          <div class="vector-line"></div>
          <div class="question"><span class="q-bullet"></span><div>צ״ל:</div></div>
          <div class="vector-line"></div>
          <div class="question"><span class="q-bullet"></span><div>הוכחה:</div></div>
          <div class="vector-line"></div>
          <div class="vector-line"></div>
          <div class="vector-line"></div>
          <div class="vector-line"></div>
        </div>
      </section>
    </main>
  </div>
</body>
</html>
EOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("page 41 precise vector svg exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","vector_assets","deltoid_page41_precise.svg")), true);
});

test("page 41 precise vector html exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","vector_pages","page-41-vector.html")), true);
});

test("page 41 precise vector html has no inline style", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","vector_pages","page-41-vector.html"), "utf8");
  assert.equal(html.includes('style="'), false);
  assert.equal(html.includes("<style"), false);
});
EOF

if ! grep -q "Page 41 precise vector rebuild" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Page 41 precise vector rebuild

- עמוד 41 נבנה מחדש על בסיס השרטוט האמיתי מהמקור:
  משולש שווה־שוקיים ABC, התיכון AD לצלע BC, והנקודה E על המשך AD.
- גרסת הווקטור נשמרת תחת:
  `worksheets/deltoid/vector_pages/page-41-vector.html`
- השרטוט נשמר תחת:
  `worksheets/deltoid/vector_assets/deltoid_page41_precise.svg`
EOF
fi

if ! grep -q "עמוד 41 נבנה מחדש לפי השרטוט האמיתי" RULES.md; then
cat >> RULES.md <<'EOF'

---

## עמוד 41 נבנה מחדש לפי השרטוט האמיתי

- העמוד מתאר משולש שווה־שוקיים ABC
- AD הוא תיכון ל-BC
- E על המשך AD
- גרסת הווקטור נשמרת תחת:
  `worksheets/deltoid/vector_pages/page-41-vector.html`
EOF
fi

python tools/rebuild_graphics_status_precise.py | tee worksheets/deltoid/graphics-status-build.out.json
npm test | tee deltoid_page41_vector_precise_test_output.txt

{
  echo "# Deltoid page 41 precise vector rebuild"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## svg"
  ls -lh "$SVG_DIR/deltoid_page41_precise.svg"
  echo
  echo "## html"
  ls -lh "$PAGE_DIR/page-41-vector.html"
  echo
  echo "## tests"
  cat deltoid_page41_vector_precise_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$SVG_DIR/deltoid_page41_precise.svg" "$PAGE_DIR/page-41-vector.html" "$TEST_FILE" PROJECT_RULES.md RULES.md worksheets/deltoid/graphics-status-build.out.json "$REPORT" deltoid_page41_vector_precise_test_output.txt

if ! git diff --cached --quiet; then
  git commit -m "feat: rebuild deltoid page 41 as precise vector geometry page"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "NEXT HIGH PRIORITY: page 5 vector rebuild"
