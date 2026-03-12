#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_PAGE38_VECTOR_REBUILD_$(date +%Y%m%d_%H%M%S).md"
SVG_DIR="worksheets/deltoid/vector_assets"
PAGE_DIR="worksheets/deltoid/vector_pages"
CSS_FILE="styles/vector-pages.css"
TEST_FILE="tests/deltoid-page38.test.mjs"

mkdir -p "$SVG_DIR" "$PAGE_DIR" tests styles

cat > "$SVG_DIR/deltoid_page38.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 700">
  <defs>
    <style>
      .edge { stroke:#111827; stroke-width:5; fill:none; vector-effect:non-scaling-stroke; }
      .kite { stroke:#111827; stroke-width:5; fill:none; vector-effect:non-scaling-stroke; }
      .pt { font-family:Arial, sans-serif; font-size:34px; fill:#111827; }
      .mid { font-family:Arial, sans-serif; font-size:32px; fill:#111827; }
    </style>
  </defs>

  <!-- rectangle -->
  <line class="edge" x1="120" y1="100" x2="520" y2="100"/>
  <line class="edge" x1="520" y1="100" x2="520" y2="560"/>
  <line class="edge" x1="520" y1="560" x2="120" y2="560"/>
  <line class="edge" x1="120" y1="560" x2="120" y2="100"/>

  <!-- kite MKTE -->
  <line class="kite" x1="320" y1="100" x2="120" y2="410"/>
  <line class="kite" x1="320" y1="100" x2="520" y2="410"/>
  <line class="kite" x1="120" y1="410" x2="320" y2="560"/>
  <line class="kite" x1="520" y1="410" x2="320" y2="560"/>

  <!-- labels -->
  <text class="pt" x="75" y="112">A</text>
  <text class="pt" x="535" y="112">B</text>
  <text class="pt" x="535" y="590">C</text>
  <text class="pt" x="75" y="590">D</text>

  <text class="mid" x="305" y="82">M</text>
  <text class="mid" x="304" y="610">T</text>
  <text class="mid" x="88" y="420">E</text>
  <text class="mid" x="535" y="420">K</text>
</svg>
EOF

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
  margin-top:18px;
  margin-bottom:22px;
}

.vector-figure{
  width:360px;
  max-width:100%;
  display:block;
}

.vector-notes{
  display:grid;
  grid-template-columns:1fr;
  gap:18px;
  margin-top:24px;
}

.vector-line{
  border-bottom:2px solid #111827;
  min-height:24px;
}

@media print{
  .vector-page-shell{
    padding:0;
    min-height:auto;
    background:#fff;
  }

  .vector-page{
    margin:0;
    box-shadow:none;
  }
}
EOF

cat > "$PAGE_DIR/page-38.html" <<'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>דלתון — עמוד 38 וקטורי</title>
  <link rel="stylesheet" href="../../styles/worksheet.css">
  <link rel="stylesheet" href="../../styles/vector-pages.css">
</head>
<body>
  <div class="vector-page-shell">
    <main class="a4-page vector-page">
      <header class="worksheet-header">
        <h1 class="page-title">שאלה 74 — דלתון</h1>
        <div class="page-number">38</div>
      </header>

      <section class="questions">
        <div class="question">
          <span class="q-bullet"></span>
          <div>המרובע ABCD הוא מלבן. T אמצע DC, M אמצע AB. נתון BK = AE.</div>
        </div>

        <div class="question">
          <span class="q-bullet"></span>
          <div>הסבירו כיצד ניתן להוכיח שהמרובע MKTE הוא דלתון.</div>
        </div>

        <div class="vector-figure-wrap">
          <img class="vector-figure" src="../vector_assets/deltoid_page38.svg" alt="שרטוט דלתון לעמוד 38">
        </div>

        <div class="vector-notes">
          <div class="question">
            <span class="q-bullet"></span>
            <div>נתון:</div>
          </div>
          <div class="vector-line"></div>

          <div class="question">
            <span class="q-bullet"></span>
            <div>צ״ל:</div>
          </div>
          <div class="vector-line"></div>

          <div class="question">
            <span class="q-bullet"></span>
            <div>הוכחה:</div>
          </div>
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

test("page 38 vector svg exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","vector_assets","deltoid_page38.svg")), true);
});

test("page 38 vector html exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","vector_pages","page-38.html")), true);
});

test("page 38 vector html has no inline style", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","vector_pages","page-38.html"), "utf8");
  assert.equal(html.includes('style="'), false);
  assert.equal(html.includes('<style'), false);
});
EOF

if ! grep -q "Page 38 vector rebuild" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Page 38 vector rebuild

- עמוד 38 של דלתון נבנה גם בגרסה וקטורית תחת:
  `worksheets/deltoid/vector_pages/page-38.html`
- השרטוט נשמר תחת:
  `worksheets/deltoid/vector_assets/deltoid_page38.svg`
- גרסה זו מיועדת לשיפור חדות גיאומטרית מעבר לאיכות המקור
- גם כאן אין להשתמש ב-inline CSS בתוך HTML
EOF
fi

if ! grep -q "עמוד 38 נבנה מחדש כגרסה וקטורית" RULES.md; then
cat >> RULES.md <<'EOF'

---

## עמוד 38 נבנה מחדש כגרסה וקטורית

- גרסת הווקטור של עמוד 38 נשמרת תחת:
  `worksheets/deltoid/vector_pages/page-38.html`
- השרטוט נשמר תחת:
  `worksheets/deltoid/vector_assets/deltoid_page38.svg`
- הגרסה נועדה לשפר חדות גיאומטרית משמעותית
EOF
fi

npm test | tee deltoid_page38_test_output.txt

{
  echo "# Deltoid page 38 vector rebuild"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## svg"
  ls -lh "$SVG_DIR/deltoid_page38.svg"
  echo
  echo "## html"
  ls -lh "$PAGE_DIR/page-38.html"
  echo
  echo "## tests"
  cat deltoid_page38_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$SVG_DIR/deltoid_page38.svg" "$PAGE_DIR/page-38.html" "$CSS_FILE" "$TEST_FILE" PROJECT_RULES.md RULES.md deltoid_page38_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: rebuild deltoid page 38 as clean vector geometry page"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
