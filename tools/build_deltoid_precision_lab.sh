#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_PRECISION_LAB_$(date +%Y%m%d_%H%M%S).md"
PLAN_JSON="worksheets/deltoid/rebuild_plan/normalized_rebuild_plan.json"
PDF="sources/geometry/deltoid/source.pdf"
OUT_DIR="worksheets/deltoid/precision_lab"
SRC_DIR="$OUT_DIR/source_pages"
LINES_DIR="$OUT_DIR/line_maps"
BEST_DIR="$OUT_DIR/current_best"
JSON_OUT="$OUT_DIR/precision_lab.json"
HTML_OUT="$OUT_DIR/precision-gallery.html"
TEST_FILE="tests/deltoid-precision-lab.test.mjs"

mkdir -p "$OUT_DIR" "$SRC_DIR" "$LINES_DIR" "$BEST_DIR" tests tools

if [ ! -f "$PLAN_JSON" ]; then
  echo "MISSING: $PLAN_JSON"
  exit 1
fi

if [ ! -f "$PDF" ]; then
  echo "MISSING: $PDF"
  exit 1
fi

if ! command -v pdftoppm >/dev/null 2>&1 || ! command -v pdfinfo >/dev/null 2>&1; then
  pkg install -y poppler
fi

if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
  pkg install -y imagemagick
fi

IMGTOOL="convert"
if command -v magick >/dev/null 2>&1; then
  IMGTOOL="magick"
fi

python - <<'PYEOF'
from __future__ import annotations
import json, subprocess, shutil
from pathlib import Path

plan = json.loads(Path("worksheets/deltoid/rebuild_plan/normalized_rebuild_plan.json").read_text(encoding="utf-8"))
pdf = Path("sources/geometry/deltoid/source.pdf")
out_dir = Path("worksheets/deltoid/precision_lab")
src_dir = out_dir / "source_pages"
lines_dir = out_dir / "line_maps"
best_dir = out_dir / "current_best"

pages = []
for bucket in ("done", "vector-next"):
    for p in plan["buckets"].get(bucket, []):
        ip = int(p)
        if ip not in pages:
            pages.append(ip)

def pick_best_asset(page: int):
    candidates = [
        ("vector-html", Path(f"worksheets/deltoid/vector_pages/page-{page:02d}-vector.html")),
        ("vector-html", Path(f"worksheets/deltoid/vector_pages/page-{page:02d}-precise.html")),
        ("vector-html", Path(f"worksheets/deltoid/vector_pages/page-{page:02d}.html")),
        ("exact-html", Path(f"worksheets/deltoid/exact_pages/page-{page:02d}.html")),
        ("enhanced-png", Path(f"worksheets/deltoid/exact_assets/page-{page:02d}-enhanced.png")),
        ("inventory-png", Path(f"worksheets/deltoid/image_inventory/pages/page-{page:02d}.png")),
    ]
    for kind, p in candidates:
        if p.exists():
            return kind, p
    return "missing", None

records = []
for page in pages:
    src_prefix = src_dir / f"page-{page:02d}"
    subprocess.run(
        ["pdftoppm", "-f", str(page), "-l", str(page), "-png", "-r", "420", str(pdf), str(src_prefix)],
        check=True
    )
    made = sorted(src_dir.glob(f"page-{page:02d}-*.png"))
    if made:
        src_png = made[0]
        final_src = src_dir / f"page-{page:02d}.png"
        if final_src.exists():
            final_src.unlink()
        src_png.rename(final_src)
    else:
        final_src = src_dir / f"page-{page:02d}.png"

    line_png = lines_dir / f"page-{page:02d}.png"
    best_kind, best_path = pick_best_asset(page)

    rec = {
        "page": page,
        "source_png": final_src.as_posix(),
        "line_map_png": line_png.as_posix(),
        "best_kind": best_kind,
        "best_path": best_path.as_posix() if best_path else None
    }

    if best_path and best_path.exists() and best_path.suffix.lower() == ".png":
        target = best_dir / f"page-{page:02d}.png"
        shutil.copy2(best_path, target)
        rec["best_preview_png"] = target.as_posix()
    elif best_path and best_path.exists():
        rec["best_preview_png"] = None
    else:
        rec["best_preview_png"] = None

    records.append(rec)

summary = {
    "project": "parabula2",
    "topic": "דלתון",
    "page_count": len(records),
    "pages": pages,
    "records": records
}

(out_dir / "precision_lab.json").write_text(
    json.dumps(summary, ensure_ascii=False, indent=2),
    encoding="utf-8"
)
print(json.dumps({"page_count": len(records), "pages": pages}, ensure_ascii=False, indent=2))
PYEOF

for f in "$SRC_DIR"/page-*.png; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  "$IMGTOOL" "$f" -colorspace Gray -contrast-stretch 0.5%x0.5% -threshold 62% "$LINES_DIR/$base"
done

python - <<'PYEOF'
from __future__ import annotations
import json
from pathlib import Path

data = json.loads(Path("worksheets/deltoid/precision_lab/precision_lab.json").read_text(encoding="utf-8"))
out_dir = Path("worksheets/deltoid/precision_lab")

html = []
html.append("<!DOCTYPE html>")
html.append('<html lang="he" dir="rtl">')
html.append("<head>")
html.append('<meta charset="utf-8">')
html.append('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
html.append("<title>Deltoid Precision Lab</title>")
html.append("<style>")
html.append("body{font-family:Arial,sans-serif;background:#f7fafc;margin:0;padding:24px;color:#0f172a}")
html.append("h1{margin:0 0 20px 0}")
html.append(".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(340px,1fr));gap:18px}")
html.append(".card{background:#fff;border:1px solid #dbe4ee;border-radius:20px;padding:14px;box-shadow:0 10px 25px rgba(0,0,0,.06)}")
html.append(".triple{display:grid;grid-template-columns:1fr;gap:10px}")
html.append(".triple img{width:100%;height:auto;display:block;border:1px solid #cbd5e1;border-radius:12px;background:#fff}")
html.append(".meta{font-size:13px;line-height:1.7;color:#334155;margin-top:10px}")
html.append(".tag{display:inline-block;background:#eff6ff;color:#1d4ed8;border:1px solid #bfdbfe;padding:2px 8px;border-radius:999px;margin-left:6px}")
html.append("a{color:#1d4ed8;text-decoration:none}")
html.append("</style>")
html.append("</head>")
html.append("<body>")
html.append("<h1>Deltoid Precision Lab</h1>")
html.append('<div class="grid">')

for r in data["records"]:
    page = r["page"]
    html.append('<div class="card">')
    html.append(f'<div class="meta"><span class="tag">עמוד {page:02d}</span><span class="tag">{r["best_kind"]}</span></div>')
    html.append('<div class="triple">')
    html.append(f'<div><img src="source_pages/page-{page:02d}.png" alt="source {page}"></div>')
    html.append(f'<div><img src="line_maps/page-{page:02d}.png" alt="lines {page}"></div>')
    if r.get("best_preview_png"):
        html.append(f'<div><img src="current_best/page-{page:02d}.png" alt="best {page}"></div>')
    else:
        html.append('<div style="padding:18px;border:1px dashed #cbd5e1;border-radius:12px;color:#64748b">לקובץ הזה אין כרגע PNG ישיר להשוואה. פתח מהמקור הטוב ביותר דרך הקישור למטה.</div>')
    html.append('</div>')
    html.append(f'<div class="meta">source: <a href="{r["source_png"]}" target="_blank">{r["source_png"]}</a><br>lines: <a href="{r["line_map_png"]}" target="_blank">{r["line_map_png"]}</a><br>best: {r["best_path"] if r["best_path"] else "missing"}</div>')
    html.append('</div>')

html.append("</div>")
html.append("</body>")
html.append("</html>")

(out_dir / "precision-gallery.html").write_text("\n".join(html) + "\n", encoding="utf-8")
PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("precision lab json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","precision_lab","precision_lab.json")), true);
});

test("precision gallery exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","precision_lab","precision-gallery.html")), true);
});

test("precision lab source pages exist", () => {
  const dir = path.join("worksheets","deltoid","precision_lab","source_pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.png$/i.test(x));
  assert.ok(files.length >= 10);
});

test("precision lab line maps exist", () => {
  const dir = path.join("worksheets","deltoid","precision_lab","line_maps");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.png$/i.test(x));
  assert.ok(files.length >= 10);
});
EOF

if ! grep -q "Deltoid precision lab" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deltoid precision lab

- יש לבנות precision lab תחת:
  `worksheets/deltoid/precision_lab/`
- המעבדה חייבת לכלול:
  - source_pages
  - line_maps
  - current_best
  - precision_lab.json
  - precision-gallery.html
- זהו בסיס העבודה לדיוק עמוק של ציורים וגרפים
EOF
fi

if ! grep -q "מעבדת דיוק לדלתון" RULES.md; then
cat >> RULES.md <<'EOF'

---

## מעבדת דיוק לדלתון

- אחרי editable shell יש לבנות precision lab
- המעבדה נועדה להשוואה ויזואלית עמוקה בין מקור PDF לבין הגרסאות שנבנו
EOF
fi

npm test | tee deltoid_precision_lab_test_output.txt

{
  echo "# Deltoid precision lab build"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## precision summary"
  cat "$JSON_OUT"
  echo
  echo "## tests"
  cat deltoid_precision_lab_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md deltoid_precision_lab_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: build deltoid precision lab for deep diagram accuracy"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "GALLERY: $HTML_OUT"
echo "NEXT HIGH PRIORITY: rebuild top mismatch pages from precision lab"
