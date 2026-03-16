#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_A4_PACKING_AUDIT_$(date +%Y%m%d_%H%M%S).md"
JSON_OUT="worksheets/deltoid/a4_packing_audit.json"
TEST_FILE="tests/deltoid-a4-packing-audit.test.mjs"

mkdir -p tools tests worksheets/deltoid

python - <<'PYEOF'
from pathlib import Path
import re, json

pages = sorted(Path("worksheets/deltoid").glob("**/pages/page-*.html"))
records = []

for p in pages:
    text = p.read_text(encoding="utf-8", errors="ignore")

    page_match = re.search(r'page-(\d+)\.html$', p.name)
    page_no = int(page_match.group(1)) if page_match else -1

    bullet_count = text.count('class="question-bullet"')
    line_count = len(text.splitlines())
    char_count = len(re.sub(r"<[^>]+>", " ", text))
    has_reference = 'reference-image' in text
    has_page_number = 'class="page-number"' in text

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

    records.append({
        "file": p.as_posix(),
        "page": page_no,
        "line_count": line_count,
        "char_count": char_count,
        "bullet_count": bullet_count,
        "has_reference": has_reference,
        "has_page_number": has_page_number,
        "packing_status": packing_status,
        "notes": notes
    })

summary = {
    "page_count": len(records),
    "weak_pages": [r["page"] for r in records if r["packing_status"] == "weak"],
    "good_pages": [r["page"] for r in records if r["packing_status"] == "good"],
    "records": records
}

Path("worksheets/deltoid/a4_packing_audit.json").write_text(
    json.dumps(summary, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

md = []
md.append("# DELTOID A4 PACKING AUDIT")
md.append("")
md.append(f"- page_count: {summary['page_count']}")
md.append(f"- weak_pages: {', '.join(str(x) for x in summary['weak_pages']) if summary['weak_pages'] else 'None'}")
md.append(f"- good_pages: {', '.join(str(x) for x in summary['good_pages']) if summary['good_pages'] else 'None'}")
md.append("")
md.append("## Details")
for r in records:
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

Path("worksheets/deltoid/A4_PACKING_AUDIT_REPORT.md").write_text(
    "\n".join(md),
    encoding="utf-8"
)

print(json.dumps({
    "page_count": summary["page_count"],
    "weak_pages": summary["weak_pages"][:20]
}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'TESTEOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("a4 packing audit json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","a4_packing_audit.json")), true);
});

test("a4 packing report exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","A4_PACKING_AUDIT_REPORT.md")), true);
});
TESTEOF

npm test | tee deltoid_a4_packing_audit_test_output.txt

{
  echo "# Deltoid A4 packing audit"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## tests"
  cat deltoid_a4_packing_audit_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add tools/deltoid_a4_packing_audit.sh \
  worksheets/deltoid/a4_packing_audit.json \
  worksheets/deltoid/A4_PACKING_AUDIT_REPORT.md \
  "$TEST_FILE" \
  deltoid_a4_packing_audit_test_output.txt \
  "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: add deltoid A4 packing audit"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
