from __future__ import annotations
import json
from pathlib import Path

img_dir = Path("worksheets/deltoid/exact_assets")
page_dir = Path("worksheets/deltoid/exact_pages")
page_dir.mkdir(parents=True, exist_ok=True)

pngs = sorted(img_dir.glob("page-*.png"))
manifest = {
    "topic": "דלתון",
    "mode": "exact-facsimile",
    "source": "sources/geometry/deltoid/source.pdf",
    "page_count": len(pngs),
    "pages": []
}

for i, png in enumerate(pngs, start=1):
    html = f"""<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>דלתון מדויק — עמוד {i}</title>
  <link rel="stylesheet" href="../../../styles/worksheet.css">
  <link rel="stylesheet" href="../../../styles/exact-facsimile.css">
</head>
<body>
  <div class="exact-shell">
    <main class="a4-page exact-page">
      <img class="exact-image" src="../exact_assets/{png.name}" alt="דלתון עמוד {i}">
    </main>
  </div>
</body>
</html>
"""
    out = page_dir / f"page-{i:02d}.html"
    out.write_text(html, encoding="utf-8")
    manifest["pages"].append(str(out).replace("\\", "/"))

(page_dir / "manifest.json").write_text(
    json.dumps(manifest, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

print(json.dumps(manifest, ensure_ascii=False, indent=2))
