from __future__ import annotations
import json
import re
from pathlib import Path

PDF_PAGES = 60

exact_dir = Path("worksheets/deltoid/exact_pages")
enhanced_dir = Path("worksheets/deltoid/exact_assets")
vector_pages_dir = Path("worksheets/deltoid/vector_pages")
vector_assets_dir = Path("worksheets/deltoid/vector_assets")
status_path = Path("worksheets/deltoid/graphics-status.json")
qa_path = Path("worksheets/deltoid/VECTOR_QA.md")

def page_id_from_name(name: str):
    m = re.search(r'^page-(\d+)(?:-vector)?\.html$|^page-(\d+)(?:-enhanced)?\.png$', name)
    if not m:
        return None
    g1 = m.group(1) or m.group(2)
    return g1.zfill(2) if g1 else None

exact_pages = sorted([p for p in exact_dir.glob("page-*.html") if re.match(r"^page-\d{2}\.html$", p.name)])
enhanced_assets = sorted([p for p in enhanced_dir.glob("page-*-enhanced.png") if page_id_from_name(p.name)])
vector_pages = sorted([p for p in vector_pages_dir.glob("page-*.html") if page_id_from_name(p.name)])
vector_assets = sorted(vector_assets_dir.glob("*.svg"))

exact_ids = {page_id_from_name(p.name) for p in exact_pages}
enhanced_ids = {page_id_from_name(p.name) for p in enhanced_assets}
vector_ids = {page_id_from_name(p.name) for p in vector_pages}

records = []
for n in range(1, PDF_PAGES + 1):
    pid = str(n).zfill(2)
    state = "exact"
    verified = False
    notes = []

    if pid in enhanced_ids:
        state = "enhanced"
        notes.append("enhanced asset exists")

    if pid in vector_ids:
        state = "vector"
        notes.append("vector page exists")

    if pid in {"09", "38", "42"}:
        verified = True
        notes.append("manually advanced in repo")

    priority = "normal"
    if pid in {"56", "63", "72", "78", "84", "91", "41", "05"}:
        priority = "high"
    if pid in {"09", "38", "42"}:
        priority = "done"

    records.append({
        "page": int(pid),
        "page_id": pid,
        "state": state,
        "verified": verified,
        "priority": priority,
        "notes": notes
    })

status = {
    "topic": "דלתון",
    "source": "sources/geometry/deltoid/source.pdf",
    "source_pdf_page_count": PDF_PAGES,
    "exact_page_count": len(exact_pages),
    "enhanced_asset_count": len(enhanced_assets),
    "vector_page_count": len(vector_pages),
    "vector_asset_count": len(vector_assets),
    "records": records
}

status_path.write_text(json.dumps(status, ensure_ascii=False, indent=2), encoding="utf-8")

lines = []
lines.append("# VECTOR_QA — דלתון")
lines.append("")
lines.append(f"- source pdf pages: {PDF_PAGES}")
lines.append(f"- exact pages: {len(exact_pages)}")
lines.append(f"- enhanced assets: {len(enhanced_assets)}")
lines.append(f"- vector pages: {len(vector_pages)}")
lines.append("")
lines.append("## Completed / advanced pages")
for pid in sorted(vector_ids, key=lambda x: int(x)):
    lines.append(f"- page {int(pid)} — vector page exists")
lines.append("")
lines.append("## High-priority next pages")
for pid in ["56","41","05","63","72","78","84","91"]:
    rec = next((r for r in records if r["page_id"] == pid), None)
    state = rec["state"] if rec else "missing"
    lines.append(f"- page {int(pid)} — current state: {state}")
lines.append("")
lines.append("## QA rules")
lines.append("- no inline CSS in vector HTML pages")
lines.append("- external SVG preferred for rebuilt geometry")
lines.append("- every rebuilt page must have a matching test")
lines.append("- exact pages count must equal source PDF page count (60)")
qa_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(json.dumps({
    "source_pdf_page_count": PDF_PAGES,
    "exact_pages": len(exact_pages),
    "enhanced_assets": len(enhanced_assets),
    "vector_pages": len(vector_pages),
    "vector_assets": len(vector_assets)
}, ensure_ascii=False, indent=2))
