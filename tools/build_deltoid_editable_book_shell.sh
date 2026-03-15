#!/data/data/com.termux/files/usr/bin/bash
set -e

OUT="worksheets/deltoid/editable_book"
mkdir -p "$OUT/assets" "$OUT/config"

cat > "$OUT/book.config.json" <<'JSON'
{
  "project": "parabula2",
  "topic": "דלתון",
  "chapter_count": 3
}
JSON

cat > "$OUT/config/theme.json" <<'JSON'
{
  "direction": "rtl",
  "font": "Arial",
  "primary_color": "#1d4ed8"
}
JSON

cat > "$OUT/assets/editor.css" <<'CSS'
body{
  font-family:Arial,sans-serif;
  background:#f4f7fb;
  margin:0;
}
.shell{
  max-width:1100px;
  margin:auto;
  padding:20px;
}
h1{
  margin:0 0 20px 0;
}
.card{
  background:white;
  padding:20px;
  border-radius:14px;
  box-shadow:0 10px 25px rgba(0,0,0,.08);
  margin-bottom:16px;
}
a{
  color:#1d4ed8;
  font-weight:700;
  text-decoration:none;
}
CSS

cat > "$OUT/editable-index.html" <<'HTML'
<!DOCTYPE html>
<html dir="rtl" lang="he">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="assets/editor.css">
<title>מעטפת עריכה</title>
</head>
<body>
<div class="shell">
<h1>מעטפת עריכה לספר דלתון</h1>

<div class="card">
<a href="../chapters/chapter_01_done_pages/index.html">פרק 1 — עמודים מטופלים</a>
</div>

<div class="card">
<a href="../chapters/chapter_02_vector_next/index.html">פרק 2 — vector-next</a>
</div>

<div class="card">
<a href="../chapters/chapter_03_image_first/index.html">פרק 3 — image-first</a>
</div>

</div>
</body>
</html>
HTML

cp "$OUT/editable-index.html" "$OUT/editable-book.html"

echo "Editable shell created"
