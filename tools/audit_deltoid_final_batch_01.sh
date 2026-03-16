#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_BATCH_01_AUDIT_$(date +%Y%m%d_%H%M%S).md"
OUT_DIR="worksheets/deltoid/final_pages_batch_01"
PAGES_DIR="$OUT_DIR/pages"
TEXT_DIR="worksheets/deltoid/rebuild_v2/source_text"
AUDIT_JSON="$OUT_DIR/batch_01_audit.json"
AUDIT_MD="$OUT_DIR/BATCH_01_AUDIT_REPORT.md"
TEST_FILE="tests/deltoid-final-batch-01-audit.test.mjs"

mkdir -p tools tests

python - <<'PYEOF'
from __future__ import annotations
import json, re
from pathlib import Path

pages = ["09", "38", "41", "42", "56"]
out_dir = Path("worksheets/deltoid/final_pages_batch_01")
pages_dir = out_dir / "pages"
text_dir = Path("worksheets/deltoid/rebuild_v2/source_text")

records = []

def clean_text(t: str) -> str:
    t = t.replace("\x0c", " ")
    t = t.replace("\r", "\n")
    t = re.sub(r"\s+", " ", t).strip()
    return t

for n in pages:
    html_path = pages_dir / f"page-{n}.html"
    txt_path = text_dir / f"page-{n}.txt"

    html = html_path.read_text(encoding="utf-8", errors="ignore") if html_path.exists() else ""
    txt = txt_path.read_text(encoding="utf-8", errors="ignore") if txt_path.exists() else ""

    bullet_count = html.count('class="question-bullet"')
    page_number_ok = 'class="page-number"' in html
    question_numbering_found = bool(re.search(r'שאלה\s*\d+', html))
    source_text_block_found = "טקסט מקור" in html or "עמוד מקור" in html
    source_image_match = re.search(r'<img[^>]+src="([^"]+page-' + n + r'\.png)"', html)
    source_image_found = bool(source_image_match)

    clean_txt = clean_text(txt)
    clean_html = clean_text(re.sub(r"<[^>]+>", " ", html))

    txt_len = len(clean_txt)
    html_len = len(clean_html)

    ratio = 0.0
    if txt_len > 0:
        ratio = round(html_len / txt_len, 3)

    status = "ok"
    issues = []

    if bullet_count == 0:
        status = "needs-fix"
        issues.append("אין bullet לשאלות")
    if not page_number_ok:
        status = "needs-fix"
        issues.append("אין page-number")
    if question_numbering_found:
        status = "needs-fix"
        issues.append("נמצא מספור שאלות")
    if not source_image_found:
        status = "needs-fix"
        issues.append("אין תמונת מקור תואמת")
    if txt_len < 20:
        issues.append("טקסט מקור קצר מאוד או חסר")
    if ratio < 0.25:
        issues.append("מעט מאוד טקסט עבר לעמוד")
    if ratio > 3.5:
        issues.append("יותר מדי טקסט/מעטפת ביחס למקור")

    records.append({
        "page": int(n),
        "html_path": html_path.as_posix(),
        "text_path": txt_path.as_posix(),
        "bullet_count": bullet_count,
        "page_number_ok": page_number_ok,
        "question_numbering_found": question_numbering_found,
        "source_text_block_found": source_text_block_found,
        "source_image_found": source_image_found,
        "source_text_length": txt_len,
        "html_text_length": html_len,
        "length_ratio": ratio,
        "status": status,
        "issues": issues
    })

summary = {
    "page_count": len(records),
    "ok_pages": [r["page"] for r in records if r["status"] == "ok"],
    "needs_fix_pages": [r["page"] for r in records if r["status"] != "ok"],
    "records": records
}

(out_dir / "batch_01_audit.json").write_text(
    json.dumps(summary, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

md = []
md.append("# DELTOID BATCH 01 AUDIT REPORT")
md.append("")
md.append(f"- page_count: {summary['page_count']}")
md.append(f"- ok_pages: {', '.join(str(x) for x in summary['ok_pages']) if summary['ok_pages'] else 'None'}")
md.append(f"- needs_fix_pages: {', '.join(str(x) for x in summary['needs_fix_pages']) if summary['needs_fix_pages'] else 'None'}")
md.append("")
md.append("## Per page")
for r in records:
    md.append(f"### Page {r['page']:02d}")
    md.append(f"- status: {r['status']}")
    md.append(f"- bullet_count: {r['bullet_count']}")
    md.append(f"- page_number_ok: {r['page_number_ok']}")
    md.append(f"- question_numbering_found: {r['question_numbering_found']}")
    md.append(f"- source_text_block_found: {r['source_text_block_found']}")
    md.append(f"- source_image_found: {r['source_image_found']}")
    md.append(f"- source_text_length: {r['source_text_length']}")
    md.append(f"- html_text_length: {r['html_text_length']}")
    md.append(f"- length_ratio: {r['length_ratio']}")
    if r["issues"]:
        md.append(f"- issues: {', '.join(r['issues'])}")
    else:
        md.append("- issues: none")
    md.append("")

(out_dir / "BATCH_01_AUDIT_REPORT.md").write_text("\n".join(md), encoding="utf-8")

print(json.dumps({
    "ok_pages": summary["ok_pages"],
    "needs_fix_pages": summary["needs_fix_pages"]
}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("batch 01 audit json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_01","batch_01_audit.json")), true);
});

test("batch 01 audit report exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_01","BATCH_01_AUDIT_REPORT.md")), true);
});

test("batch 01 audit has 5 records", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","final_pages_batch_01","batch_01_audit.json"), "utf8"));
  assert.equal(data.records.length, 5);
});

test("page 09 still has bullet layout and page number", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","final_pages_batch_01","pages","page-09.html"), "utf8");
  assert.ok(html.includes('class="page-number"'));
  assert.ok(html.includes('class="question-bullet">●<'));
});
EOF

npm test | tee deltoid_batch_01_audit_test_output.txt

{
  echo "# Deltoid batch 01 audit"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## audit json"
  cat "$AUDIT_JSON"
  echo
  echo "## tests"
  cat deltoid_batch_01_audit_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" deltoid_batch_01_audit_test_output.txt "$REPORT" tools/audit_deltoid_final_batch_01.sh

if ! git diff --cached --quiet; then
  git commit -m "feat: audit deltoid final batch 01 quality"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "AUDIT_MD: $AUDIT_MD"
echo "AUDIT_JSON: $AUDIT_JSON"

if command -v termux-open-url >/dev/null 2>&1; then
  termux-open-url "http://127.0.0.1:5179/worksheets/deltoid/final_pages_batch_01/index.html"
fi
