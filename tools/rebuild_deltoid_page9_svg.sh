#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_PAGE9_VECTOR_REBUILD_$(date +%Y%m%d_%H%M%S).md"

PAGE_DIR="worksheets/deltoid/exact_pages"
SVG_DIR="worksheets/deltoid/vector_assets"

mkdir -p "$SVG_DIR"

cat > "$SVG_DIR/deltoid_page9.svg" <<'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 600">

<style>
.edge{stroke:#000;stroke-width:3;fill:none}
.diagonal{stroke:#2563eb;stroke-width:4}
.mark{stroke:#000;stroke-width:2}
.angle{stroke:#e11d48;stroke-width:3;fill:none}
.label{font-family:Arial;font-size:24px}
</style>

<!-- vertices -->
<circle cx="400" cy="80" r="4"/>
<circle cx="150" cy="350" r="4"/>
<circle cx="400" cy="520" r="4"/>
<circle cx="650" cy="350" r="4"/>

<!-- deltoid edges -->
<line class="edge" x1="400" y1="80" x2="150" y2="350"/>
<line class="edge" x1="150" y1="350" x2="400" y2="520"/>
<line class="edge" x1="400" y1="520" x2="650" y2="350"/>
<line class="edge" x1="650" y1="350" x2="400" y2="80"/>

<!-- diagonal -->
<line class="diagonal" x1="400" y1="80" x2="400" y2="520"/>

<!-- labels -->
<text class="label" x="390" y="60">A</text>
<text class="label" x="120" y="360">B</text>
<text class="label" x="390" y="560">C</text>
<text class="label" x="660" y="360">D</text>

</svg>
EOF

cat > "$PAGE_DIR/page-09-vector.html" <<'EOF'
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
<meta charset="utf-8">
<title>דלתון עמוד 9 – גרסת וקטור</title>
<link rel="stylesheet" href="../../../styles/worksheet.css">
</head>

<body>

<main class="a4-page">

<header class="worksheet-header">
<h1 class="page-title">דלתון – שרטוט וקטורי</h1>
<div class="page-number">9</div>
</header>

<section class="questions">

<div class="question">
<span class="q-bullet"></span>
<div>שרטוט דלתון עם אלכסון ראשי</div>
</div>

<div style="display:flex;justify-content:center;margin-top:40px">
<img src="../vector_assets/deltoid_page9.svg" style="width:420px">
</div>

</section>

</main>

</body>
</html>
EOF

{
echo "# Deltoid page 9 vector rebuild"
echo
echo "- time: $(date -Iseconds)"
echo
echo "## svg asset"
ls -lh "$SVG_DIR/deltoid_page9.svg"
echo
echo "## html page"
ls -lh "$PAGE_DIR/page-09-vector.html"
} > "$REPORT"

git add "$SVG_DIR/deltoid_page9.svg" "$PAGE_DIR/page-09-vector.html" "$REPORT"

git commit -m "feat: rebuild deltoid page 9 as vector svg diagram"

git push

echo
echo "DONE"
echo "REPORT: $REPORT"
