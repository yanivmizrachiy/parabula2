#!/data/data/com.termux/files/usr/bin/bash
set -e

OUT="worksheets/deltoid/final_pages_batch_03"
PAGES="$OUT/pages"

mkdir -p "$PAGES"

for i in 15 16 17 18 19
do
cat > "$PAGES/page-$i.html" <<HTML
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
<meta charset="utf-8">
<title>דלתון – דף $i</title>
<link rel="stylesheet" href="../../../styles/worksheet.css">
</head>
<body>

<div class="page">

<div class="page-number">$i</div>

<h2>דלתון</h2>

<ul class="questions">

<li>בדלתון נתון חשבו את הזוויות החסרות.</li>

<li>האם האלכסונים בדלתון מאונכים זה לזה? נמקו.</li>

<li>בדקו אם המרובע הנתון יכול להיות דלתון.</li>

<li>שרטטו דלתון שבו זוג אחד של צלעות שוות.</li>

<li>מה תכונת האלכסון הראשי בדלתון?</li>

</ul>

</div>

</body>
</html>
HTML
done

cat > "$OUT/batch_03_manifest.json" <<JSON
{
"batch":3,
"pages":[15,16,17,18,19]
}
JSON

cat > "$OUT/index.html" <<HTML
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
<meta charset="utf-8">
<title>Deltoid batch 03</title>
</head>
<body>

<h1>Deltoid Batch 03</h1>

<ul>
<li><a href="pages/page-15.html">page 15</a></li>
<li><a href="pages/page-16.html">page 16</a></li>
<li><a href="pages/page-17.html">page 17</a></li>
<li><a href="pages/page-18.html">page 18</a></li>
<li><a href="pages/page-19.html">page 19</a></li>
</ul>

</body>
</html>
HTML

echo "Batch 03 built"
