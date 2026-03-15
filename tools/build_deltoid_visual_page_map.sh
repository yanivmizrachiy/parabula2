#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_VISUAL_PAGE_MAP_$(date +%Y%m%d_%H%M%S).md"
IMG_JSON="worksheets/deltoid/image_inventory/image_inventory.json"
BOOK_JSON="worksheets/deltoid/book_inventory/book_inventory.json"
OUT_DIR="worksheets/deltoid/visual_page_map"
JSON_OUT="$OUT_DIR/visual_page_map.json"
MD_OUT="$OUT_DIR/VISUAL_PAGE_MAP.md"
HTML_OUT="$OUT_DIR/visual-map.html"
TEST_FILE="tests/deltoid-visual-page-map.test.mjs"

mkdir -p "$OUT_DIR" tests tools

if [ ! -f "$IMG_JSON" ]; then
  echo "MISSING: $IMG_JSON"
  exit 1
fi

if [ ! -f "$BOOK_JSON" ]; then
  echo "MISSING: $BOOK_JSON"
  exit 1
fi

python - <<'PYEOF'
from __future__ import annotations
import json
from pathlib import Path

img = json.loads(Path("worksheets/deltoid/image_inventory/image_inventory.json").read_text(encoding="utf-8"))
book = json.loads(Path("worksheets/deltoid/book_inventory/book_inventory.json").read_text(encoding="utf-8"))

book_map = {r["page"]: r for r in book["records"]}
records = []

for rec in img["records"]:
    page = rec["page"]
    meta = book_map.get(page, {})
    img_count = int(meta.get("image_count", 0))
    chars = int(meta.get("char_count", 0))
    qcount = int(meta.get("question_marker_count", 0))
    cats = meta.get("categories", [])

    kind = "mixed"
    priority = "medium"
    action = "review"

    if img_count >= 8:
        kind = "graphic-heavy"
        priority = "high"
        action = "manual-visual-rebuild"
    elif img_count >= 3 and chars < 120:
        kind = "diagram-page"
        priority = "high"
        action = "vector-first"
    elif chars >= 120 and img_count <= 2:
        kind = "text-heavy"
        priority = "medium"
        action = "rewrite-from-layout"
    elif chars < 80 and img_count >= 1:
        kind = "worksheet-graphic"
        priority = "high"
        action = "image-first-rebuild"

    if page in [9, 38, 41, 42, 56]:
        priority = "done"
        action = "already-treated"

    records.append({
        "page": page,
        "image": rec["image"],
        "thumb": rec["thumb"],
        "image_count": img_count,
        "char_count": chars,
        "question_marker_count": qcount,
        "categories": cats,
        "kind": kind,
        "priority": priority,
        "recommended_action": action
    })

summary = {
    "project": "parabula2",
    "topic": "דלתון",
    "page_count": len(records),
    "records": records,
    "counts": {
        "graphic-heavy": sum(1 for r in records if r["kind"] == "graphic-heavy"),
        "diagram-page": sum(1 for r in records if r["kind"] == "diagram-page"),
        "text-heavy": sum(1 for r in records if r["kind"] == "text-heavy"),
        "worksheet-graphic": sum(1 for r in records if r["kind"] == "worksheet-graphic"),
        "mixed": sum(1 for r in records if r["kind"] == "mixed"),
        "done": sum(1 for r in records if r["priority"] == "done"),
    }
}

out = Path("worksheets/deltoid/visual_page_map")
out.mkdir(parents=True, exist_ok=True)
(out / "visual_page_map.json").write_text(json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8")

lines = []
lines.append("# DELTOID VISUAL PAGE MAP")
lines.append("")
lines.append(f"- page_count: {summary['page_count']}")
for k, v in summary["counts"].items():
    lines.append(f"- {k}: {v}")
lines.append("")
lines.append("## Page map")
for r in records:
    lines.append(
        f"- page {r['page']:02d} | kind={r['kind']} | priority={r['priority']} | "
        f"action={r['recommended_action']} | images={r['image_count']} | "
        f"chars={r['char_count']} | qmarkers={r['question_marker_count']}"
    )
(out / "VISUAL_PAGE_MAP.md").write_text("\n".join(lines) + "\n", encoding="utf-8")

html = []
html.append("<!DOCTYPE html>")
html.append('<html lang="he" dir="rtl">')
html.append("<head>")
html.append('<meta charset="utf-8">')
html.append('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
html.append("<title>Deltoid Visual Page Map</title>")
html.append("<style>")
html.append("body{font-family:Arial,sans-serif;background:#f8fafc;margin:0;padding:24px}")
html.append("h1{margin:0 0 24px 0}")
html.append(".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:16px}")
html.append(".card{background:#fff;border:1px solid #cbd5e1;border-radius:16px;padding:12px;box-shadow:0 4px 14px rgba(0,0,0,.05)}")
html.append(".card img{width:100%;height:auto;display:block;border-radius:10px;border:1px solid #e2e8f0}")
html.append(".meta{margin-top:10px;font-size:13px;color:#334155;line-height:1.5}")
html.append(".done{border-color:#16a34a}")
html.append(".high{border-color:#dc2626}")
html.append(".medium{border-color:#f59e0b}")
html.append("</style>")
html.append("</head>")
html.append("<body>")
html.append("<h1>Deltoid Visual Page Map</h1>")
html.append('<div class="grid">')
for r in records:
    css = "done" if r["priority"] == "done" else ("high" if r["priority"] == "high" else "medium")
    html.append(f'<div class="card {css}">')
    html.append(f'<img src="../image_inventory/thumbs/page-{r["page"]:02d}.png" alt="page {r["page"]}">')
    html.append(f'<div class="meta">עמוד {r["page"]:02d}<br>kind: {r["kind"]}<br>priority: {r["priority"]}<br>action: {r["recommended_action"]}<br>images: {r["image_count"]}<br>chars: {r["char_count"]}<br>qmarkers: {r["question_marker_count"]}</div>')
    html.append("</div>")
html.append("</div>")
html.append("</body>")
html.append("</html>")
(out / "visual-map.html").write_text("\n".join(html) + "\n", encoding="utf-8")

print(json.dumps(summary["counts"], ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("visual page map json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","visual_page_map","visual_page_map.json")), true);
});

test("visual page map markdown exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","visual_page_map","VISUAL_PAGE_MAP.md")), true);
});

test("visual map html exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","visual_page_map","visual-map.html")), true);
});

test("visual page map contains 60 records", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","visual_page_map","visual_page_map.json"), "utf8"));
  assert.equal(data.page_count, 60);
  assert.equal(data.records.length, 60);
});
EOF

if ! grep -q "Deltoid visual page map" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deltoid visual page map

- יש לשמור מפת עמודים חזותית תחת:
  `worksheets/deltoid/visual_page_map/`
- המפה קובעת לכל עמוד:
  - kind
  - priority
  - recommended_action
- זהו בסיס העבודה לתכנון שחזור הספר מחדש
EOF
fi

if ! grep -q "מפת עמודים חזותית לדלתון" RULES.md; then
cat >> RULES.md <<'EOF'

---

## מפת עמודים חזותית לדלתון

- אחרי image inventory חייבת להיבנות visual page map
- כל עמוד מסווג לפי רמת גרפיקה/טקסט והפעולה המומלצת
- העבודה על הספר החדש תבוצע לפי סדר עדיפויות מהמפה
EOF
fi

npm test | tee deltoid_visual_page_map_test_output.txt

{
  echo "# Deltoid visual page map build"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## visual map summary"
  cat "$JSON_OUT"
  echo
  echo "## tests"
  cat deltoid_visual_page_map_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md deltoid_visual_page_map_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: build deltoid visual page map from image and book inventory"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "VISUAL MAP: $HTML_OUT"
echo "NEXT HIGH PRIORITY: build normalized rebuild plan"
