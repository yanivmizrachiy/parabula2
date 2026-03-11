#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SITE="$ROOT/site"

rm -rf "$SITE"
mkdir -p "$SITE"

cp -R "$ROOT/styles" "$SITE/"
[ -d "$ROOT/assets" ] && cp -R "$ROOT/assets" "$SITE/" || true

find "$ROOT" -maxdepth 1 -type f -name 'עמוד-*.html' -exec cp {} "$SITE/" \;

if [ -d "$ROOT/worksheets" ]; then
  while IFS= read -r -d "" file; do
    rel="${file#$ROOT/}"
    mkdir -p "$SITE/$(dirname "$rel")"
    cp "$file" "$SITE/$rel"
  done < <(find "$ROOT/worksheets" -type f \( -name 'page-*.html' -o -name '*.png' -o -name 'manifest.json' \) -print0)
fi

ROOT_LINKS="$(find "$SITE" -maxdepth 1 -type f -name 'עמוד-*.html' | sort | sed "s#^$SITE/##" | awk "{print \"<li><a href='\''\" \$0 \"'\''>\" \$0 \"</a></li>\"}")"
TOPIC_LINKS="$(find "$SITE/worksheets" -type f -name 'page-*.html' 2>/dev/null | sort | sed "s#^$SITE/##" | awk "{print \"<li><a href='\''\" \$0 \"'\''>\" \$0 \"</a></li>\"}")"

cat > "$SITE/index.html" <<HTML
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>parabula2</title>
<link rel="stylesheet" href="styles/worksheet.css">
</head>
<body>
<main class="a4-page">
<header class="worksheet-header">
<h1 class="page-title">parabula2</h1>
<div class="page-number">1</div>
</header>
<section class="questions">
<div class="question"><span class="q-bullet"></span><div>דפי שורש</div></div>
<ul>
$ROOT_LINKS
</ul>
<div class="question"><span class="q-bullet"></span><div>דפי worksheets</div></div>
<ul>
$TOPIC_LINKS
</ul>
</section>
</main>
</body>
</html>
HTML

: > "$SITE/.nojekyll"
echo "site built"
