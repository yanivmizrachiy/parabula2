#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_BOOK_INVENTORY_$(date +%Y%m%d_%H%M%S).md"
PDF="sources/geometry/deltoid/source.pdf"
OUT_DIR="worksheets/deltoid/book_inventory"
TEXT_DIR="$OUT_DIR/text"
JSON_OUT="$OUT_DIR/book_inventory.json"
MD_OUT="$OUT_DIR/BOOK_STATUS.md"
TEST_FILE="tests/deltoid-book-inventory.test.mjs"

mkdir -p "$TEXT_DIR" tests tools

if [ ! -f "$PDF" ]; then
  echo "MISSING PDF: $PDF"
  exit 1
fi

if ! command -v pdfinfo >/dev/null 2>&1 || ! command -v pdftotext >/dev/null 2>&1 || ! command -v pdfimages >/dev/null 2>&1; then
  pkg install -y poppler
fi

PAGES="$(pdfinfo "$PDF" | awk -F: "/Pages/ {gsub(/ /,\"\",\$2); print \$2}")"
if [ -z "${PAGES:-}" ]; then
  echo "FAILED TO READ PAGE COUNT"
  exit 1
fi

rm -f "$TEXT_DIR"/page-*.txt "$TEXT_DIR"/page-*.clean.txt "$TEXT_DIR"/page-*.meta.json

pdfimages -list "$PDF" > "$OUT_DIR/pdfimages-list.txt"

python - <<'PYEOF'
from __future__ import annotations
import json, re, subprocess
from pathlib import Path

pdf = Path("sources/geometry/deltoid/source.pdf")
out_dir = Path("worksheets/deltoid/book_inventory")
text_dir = out_dir / "text"
text_dir.mkdir(parents=True, exist_ok=True)

pages = 0
raw_info = subprocess.check_output(["pdfinfo", str(pdf)], text=True, errors="ignore")
for line in raw_info.splitlines():
    if line.startswith("Pages:"):
        pages = int(line.split(":",1)[1].strip())
        break
if not pages:
    raise SystemExit("Could not detect page count")

img_raw = subprocess.check_output(["pdfimages","-list",str(pdf)], text=True, errors="ignore")
img_lines = img_raw.splitlines()

image_counts = {}
for ln in img_lines:
    parts = ln.split()
    if len(parts) >= 2 and parts[0].isdigit():
        page = int(parts[0])
        image_counts[page] = image_counts.get(page, 0) + 1

records = []
total_question_markers = 0

for page in range(1, pages + 1):
    txt = subprocess.check_output(
        ["pdftotext", "-f", str(page), "-l", str(page), str(pdf), "-"],
        text=True,
        errors="ignore"
    )
    raw_path = text_dir / f"page-{page:02d}.txt"
    raw_path.write_text(txt, encoding="utf-8")

    clean = txt.replace("\x0c", " ")
    clean = re.sub(r"[ \t]+", " ", clean)
    clean = re.sub(r"\n{2,}", "\n", clean).strip()
    clean_path = text_dir / f"page-{page:02d}.clean.txt"
    clean_path.write_text(clean + "\n", encoding="utf-8")

    q_matches = re.findall(r"שאלה\s*\d+", clean)
    q_numbers = []
    for m in q_matches:
        mm = re.search(r"(\d+)", m)
        if mm:
            q_numbers.append(int(mm.group(1)))

    has_kite_word = ("דלתון" in clean)
    has_diag = ("אלכסון" in clean)
    has_angle = ("זוו" in clean)
    has_area = ("שטח" in clean)
    has_perimeter = ("היקף" in clean)

    categories = []
    if has_kite_word:
        categories.append("דלתון")
    if has_diag:
        categories.append("אלכסונים")
    if has_angle:
        categories.append("זוויות")
    if has_area:
        categories.append("שטח")
    if has_perimeter:
        categories.append("היקף")
    if not categories:
        categories.append("לא_סווג")

    rec = {
        "page": page,
        "raw_text_file": str(raw_path),
        "clean_text_file": str(clean_path),
        "char_count": len(clean),
        "line_count": len([x for x in clean.splitlines() if x.strip()]),
        "question_marker_count": len(q_numbers),
        "question_numbers": q_numbers,
        "image_count": image_counts.get(page, 0),
        "categories": categories,
    }
    (text_dir / f"page-{page:02d}.meta.json").write_text(
        json.dumps(rec, ensure_ascii=False, indent=2),
        encoding="utf-8"
    )
    total_question_markers += len(q_numbers)
    records.append(rec)

summary = {
    "project": "parabula2",
    "topic": "דלתון",
    "source_pdf": str(pdf),
    "page_count": pages,
    "total_question_markers_detected": total_question_markers,
    "pages_with_images": sum(1 for r in records if r["image_count"] > 0),
    "pages_with_question_markers": sum(1 for r in records if r["question_marker_count"] > 0),
    "records": records,
}

(out_dir / "book_inventory.json").write_text(
    json.dumps(summary, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

lines = []
lines.append("# DELTOID BOOK STATUS")
lines.append("")
lines.append(f"- source: {pdf}")
lines.append(f"- page_count: {pages}")
lines.append(f"- total_question_markers_detected: {total_question_markers}")
lines.append(f"- pages_with_images: {summary['pages_with_images']}")
lines.append(f"- pages_with_question_markers: {summary['pages_with_question_markers']}")
lines.append("")
lines.append("## Pages overview")
for r in records:
    cats = ", ".join(r["categories"])
    qnums = ", ".join(str(x) for x in r["question_numbers"][:12]) if r["question_numbers"] else "-"
    lines.append(
        f"- page {r['page']:02d} | chars={r['char_count']} | lines={r['line_count']} | "
        f"question_markers={r['question_marker_count']} | images={r['image_count']} | "
        f"categories={cats} | qnums={qnums}"
    )
(out_dir / "BOOK_STATUS.md").write_text("\n".join(lines) + "\n", encoding="utf-8")

print(json.dumps({
    "page_count": pages,
    "total_question_markers_detected": total_question_markers,
    "pages_with_images": summary["pages_with_images"],
    "pages_with_question_markers": summary["pages_with_question_markers"]
}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("book inventory json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","book_inventory","book_inventory.json")), true);
});

test("book status markdown exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","book_inventory","BOOK_STATUS.md")), true);
});

test("all 60 page text files exist", () => {
  const dir = path.join("worksheets","deltoid","book_inventory","text");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.clean\.txt$/i.test(x));
  assert.equal(files.length, 60);
});

test("inventory page count is 60", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","book_inventory","book_inventory.json"), "utf8"));
  assert.equal(data.page_count, 60);
});
EOF

if ! grep -q "Deltoid book inventory" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deltoid book inventory

- יש לשמור inventory מלא של הספר תחת:
  `worksheets/deltoid/book_inventory/`
- לכל עמוד חייבים להיות:
  - raw text
  - clean text
  - meta json
- inventory זה הוא בסיס העבודה לבניית ספר אחיד חדש
EOF
fi

if ! grep -q "אינדקס ספר דלתון" RULES.md; then
cat >> RULES.md <<'EOF'

---

## אינדקס ספר דלתון

- לכל 60 העמודים חייב להיות קטלוג מסודר
- אין לבנות ספר חדש לפני שיש inventory מלא של העמודים
- כל בנייה עתידית חייבת להישען על:
  `worksheets/deltoid/book_inventory/book_inventory.json`
EOF
fi

npm test | tee deltoid_book_inventory_test_output.txt

{
  echo "# Deltoid book inventory build"
  echo
  echo "- time: $(date -Iseconds)"
  echo "- source: $PDF"
  echo
  echo "## inventory summary"
  cat "$JSON_OUT"
  echo
  echo "## tests"
  cat deltoid_book_inventory_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md deltoid_book_inventory_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: build full deltoid book inventory for all 60 pages"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "NEXT HIGH PRIORITY: build questions catalog from inventory"
