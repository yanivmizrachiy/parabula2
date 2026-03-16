#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_PRODUCTION_QA_AND_PACKING_$(date +%Y%m%d_%H%M%S).md"
MANIFEST="worksheets/deltoid/production_manifest.json"
STRICT_JSON="worksheets/deltoid/production_strict_qa.json"
PACKING_JSON="worksheets/deltoid/production_a4_packing_audit.json"
PACKING_MD="worksheets/deltoid/PRODUCTION_A4_PACKING_AUDIT_REPORT.md"
TEST_FILE="tests/deltoid-production-qa-and-packing.test.mjs"

python - <<'PYEOF'
from pathlib import Path
import json, re

manifest_path = Path("worksheets/deltoid/production_manifest.json")
if not manifest_path.exists():
    raise SystemExit("Missing production_manifest.json")

manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
records = manifest.get("records", [])

strict_records = []
packing_records = []

for rec in records:
    file_path = Path(rec["file"])
    if not file_path.exists():
        strict_records.append({
            "page": rec["page"],
            "file": rec["file"],
            "status": "missing-file",
            "errors": ["missing html file"]
        })
        continue

    html = file_path.read_text(encoding="utf-8", errors="ignore")

    errors = []
    warnings = []

    if 'class="page-number"' not in html:
        errors.append("missing page-number")

    if 'class="question-bullet">●<' not in html:
        errors.append("missing bullet layout")

    if "<ol>" in html:
        errors.append("ordered list found")

    if "מעלות" in html:
        errors.append("word מעלות used instead of °")

    if "זווית" in html:
        warnings.append("found word זווית ; check whether ∠ should be used")

    if "מקביל" in html:
        warnings.append("found word מקביל ; check whether ∥ should be used")

    if "מאונך" in html:
        warnings.append("found word מאונך ; check whether ⟂ should be used")

    strict_records.append({
        "page": rec["page"],
        "file": rec["file"],
        "status": "ok" if not errors else "failed",
        "errors": errors,
        "warnings": warnings
    })

    bullet_count = html.count('class="question-bullet"')
    line_count = len(html.splitlines())
    char_count = len(re.sub(r"<[^>]+>", " ", html))
    has_reference = 'reference-image' in html
    has_page_number = 'class="page-number"' in html

    packing_status = "good"
    notes = []

    if line_count < 35:
        packing_status = "weak"
        notes.append("מעט מדי שורות")
    if char_count < 900:
        packing_status = "weak"
        notes.append("מעט מדי תוכן")
    if bullet_count < 2:
        packing_status = "weak"
        notes.append("מעט מדי שאלות")
    if not has_reference:
        notes.append("אין reference-image")
    if not has_page_number:
        packing_status = "weak"
        notes.append("אין page-number")

    packing_records.append({
        "page": rec["page"],
        "file": rec["file"],
        "line_count": line_count,
        "char_count": char_count,
        "bullet_count": bullet_count,
        "has_reference": has_reference,
        "has_page_number": has_page_number,
        "packing_status": packing_status,
        "notes": notes
    })

strict_summary = {
    "page_count": len(strict_records),
    "failed_pages": [r["page"] for r in strict_records if r["status"] != "ok"],
    "warning_pages": [r["page"] for r in strict_records if r["warnings"]],
    "records": strict_records
}

packing_summary = {
    "page_count": len(packing_records),
    "weak_pages": [r["page"] for r in packing_records if r["packing_status"] == "weak"],
    "good_pages": [r["page"] for r in packing_records if r["packing_status"] == "good"],
    "records": packing_records
}

Path("worksheets/deltoid/production_strict_qa.json").write_text(
    json.dumps(strict_summary, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

Path("worksheets/deltoid/production_a4_packing_audit.json").write_text(
    json.dumps(packing_summary, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

md = []
md.append("# PRODUCTION A4 PACKING AUDIT")
md.append("")
md.append(f"- page_count: {packing_summary['page_count']}")
md.append(f"- weak_pages: {', '.join(str(x) for x in packing_summary['weak_pages']) if packing_summary['weak_pages'] else 'None'}")
md.append(f"- good_pages: {', '.join(str(x) for x in packing_summary['good_pages']) if packing_summary['good_pages'] else 'None'}")
md.append("")
md.append("## Details")
for r in packing_records:
    md.append(f"### Page {r['page']:02d}")
    md.append(f"- file: {r['file']}")
    md.append(f"- line_count: {r['line_count']}")
    md.append(f"- char_count: {r['char_count']}")
    md.append(f"- bullet_count: {r['bullet_count']}")
    md.append(f"- has_reference: {r['has_reference']}")
    md.append(f"- has_page_number: {r['has_page_number']}")
    md.append(f"- packing_status: {r['packing_status']}")
    md.append(f"- notes: {', '.join(r['notes']) if r['notes'] else 'none'}")
    md.append("")
Path("worksheets/deltoid/PRODUCTION_A4_PACKING_AUDIT_REPORT.md").write_text("\n".join(md), encoding="utf-8")

print(json.dumps({
    "production_pages": strict_summary["page_count"],
    "failed_pages": strict_summary["failed_pages"],
    "warning_pages": strict_summary["warning_pages"],
    "weak_pages": packing_summary["weak_pages"]
}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'TESTEOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("production strict qa json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","production_strict_qa.json")), true);
});

test("production packing audit json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","production_a4_packing_audit.json")), true);
});

test("production packing audit report exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","PRODUCTION_A4_PACKING_AUDIT_REPORT.md")), true);
});
TESTEOF

npm test | tee deltoid_production_qa_and_packing_test_output.txt

{
  echo "# Deltoid production QA and packing"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## strict qa"
  cat "$STRICT_JSON"
  echo
  echo "## packing audit"
  cat "$PACKING_JSON"
  echo
  echo "## tests"
  cat deltoid_production_qa_and_packing_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add tools/deltoid_production_qa_and_packing.sh \
  worksheets/deltoid/production_strict_qa.json \
  worksheets/deltoid/production_a4_packing_audit.json \
  worksheets/deltoid/PRODUCTION_A4_PACKING_AUDIT_REPORT.md \
  "$TEST_FILE" \
  deltoid_production_qa_and_packing_test_output.txt \
  "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: add production-only deltoid QA and A4 packing audit"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
