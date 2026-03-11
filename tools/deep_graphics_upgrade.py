from __future__ import annotations
import json
import subprocess
from pathlib import Path

pdf = "sources/geometry/deltoid/source.pdf"
report_json = Path("worksheets/deltoid/exact_assets/graphics_analysis.json")

raw = subprocess.check_output(["pdfimages", "-list", pdf], text=True)
lines = raw.strip().splitlines()[2:]

per_page = {}
for ln in lines:
    parts = ln.split()
    if len(parts) < 14:
        continue
    try:
        page = int(parts[0])
        xppi = int(parts[12])
        yppi = int(parts[13])
    except ValueError:
        continue
    dpi = min(xppi, yppi)
    per_page.setdefault(page, []).append(dpi)

summary = []
for page in sorted(per_page):
    dpis = per_page[page]
    summary.append({
        "page": page,
        "image_count": len(dpis),
        "min_dpi": min(dpis),
        "max_dpi": max(dpis),
        "avg_dpi": round(sum(dpis) / len(dpis), 2),
        "upgrade": min(dpis) <= 100
    })

report_json.write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps(summary, ensure_ascii=False, indent=2))
