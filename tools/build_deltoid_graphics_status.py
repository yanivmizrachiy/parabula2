from __future__ import annotations
import json
import re
from pathlib import Path

status_path = Path("worksheets/deltoid/graphics-status.json")
qa_path = Path("worksheets/deltoid/VECTOR_QA.md")

exact_pages = sorted(Path("worksheets/deltoid/exact_pages").glob("page-*.html"))
enhanced_assets = sorted(Path("worksheets/deltoid/exact_assets").glob("page-*-enhanced.png"))
vector_pages = sorted(Path("worksheets/deltoid/vector_pages").glob("page-*.html"))
vector_assets = sorted(Path("worksheets/deltoid/vector_assets").glob("*.svg"))

def extract_page_id(name: str) -> str | None:
    m = re.search(r'page-(\d+)', name)
    if m:
        return m.group(1).zfill(2)
    return None

enhanced_nums = {extract_page_id(p.stem) for p in enhanced_assets}
enhanced_nums = {x for x in enhanced_nums if x}

vector_nums = {extract_page_id(p.stem) for p in vector_pages}
vector_nums = {x for x in vector_nums if x}

exact_nums = {extract_page_id(p.stem) for p in exact_pages}
exact_nums = {x for x in exact_nums if x}

all_nums = sorted(exact_nums, key=lambda x: int(x))

records = []
for num in all_nums:
    state = "exact"
    verified = False
    notes = []

    if num in enhanced_nums:
        state = "enhanced"
        notes.append("enhanced asset exists")

    if num in vector_nums:
        state = "vector"
        notes.append("vector page exists")

    if num in {"09", "38", "42"}:
        verified = True
        notes.append("manually advanced in repo")

    priority = "normal"
    if num in {"56", "63", "72", "78", "84", "91"}:
        priority = "high"
    if num in {"09", "38", "42"}:
        priority = "done"

    records.append({
        "page": int(num),
        "page_id": num,
        "state": state,
        "verified": verified,
        "priority": priority,
        "notes": notes
    })

status = {
    "topic": "דלתון",
    "source": "sources/geometry/deltoid/source.pdf",
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
lines.append(f"- exact pages: {len(exact_pages)}")
lines.append(f"- enhanced assets: {len(enhanced_assets)}")
lines.append(f"- vector pages: {len(vector_pages)}")
lines.append("")
lines.append("## Completed / advanced pages")
for n in sorted(vector_nums, key=lambda x: int(x)):
    lines.append(f"- page {int(n)} — vector or advanced treatment exists")
lines.append("")
lines.append("## High-priority next pages")
for n in ["56","63","72","78","84","91"]:
    state = next((r["state"] for r in records if r["page_id"] == n), "missing")
    lines.append(f"- page {int(n)} — current state: {state}")
lines.append("")
lines.append("## QA rules")
lines.append("- no inline CSS in vector HTML pages")
lines.append("- external SVG preferred for rebuilt geometry")
lines.append("- every rebuilt page must have a matching test")
lines.append("- every significant change must update graphics-status.json")

qa_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(json.dumps({
    "status_json": str(status_path),
    "qa_md": str(qa_path),
    "exact_pages": len(exact_pages),
    "enhanced_assets": len(enhanced_assets),
    "vector_pages": len(vector_pages)
}, ensure_ascii=False, indent=2))
