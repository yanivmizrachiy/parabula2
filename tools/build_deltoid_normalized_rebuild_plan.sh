#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_NORMALIZED_REBUILD_PLAN_$(date +%Y%m%d_%H%M%S).md"
VIS_JSON="worksheets/deltoid/visual_page_map/visual_page_map.json"
GRAPHICS_JSON="worksheets/deltoid/graphics-status.json"
OUT_DIR="worksheets/deltoid/rebuild_plan"
JSON_OUT="$OUT_DIR/normalized_rebuild_plan.json"
MD_OUT="$OUT_DIR/NORMALIZED_REBUILD_PLAN.md"
HTML_OUT="$OUT_DIR/rebuild-plan.html"
TEST_FILE="tests/deltoid-normalized-rebuild-plan.test.mjs"

mkdir -p "$OUT_DIR" tests tools

if [ ! -f "$VIS_JSON" ]; then
  echo "MISSING: $VIS_JSON"
  exit 1
fi

if [ ! -f "$GRAPHICS_JSON" ]; then
  echo "MISSING: $GRAPHICS_JSON"
  exit 1
fi

python - <<'PYEOF'
from __future__ import annotations
import json
from pathlib import Path

vis = json.loads(Path("worksheets/deltoid/visual_page_map/visual_page_map.json").read_text(encoding="utf-8"))
graphics = json.loads(Path("worksheets/deltoid/graphics-status.json").read_text(encoding="utf-8"))

graphics_map = {int(r["page"]): r for r in graphics.get("records", [])}

plan_records = []
buckets = {
    "done": [],
    "vector-next": [],
    "image-first-next": [],
    "rewrite-later": [],
    "manual-review": []
}

for r in vis["records"]:
    page = int(r["page"])
    g = graphics_map.get(page, {})
    state = g.get("state", "unknown")
    verified = bool(g.get("verified", False))
    kind = r.get("kind", "mixed")
    action = r.get("recommended_action", "review")
    priority = r.get("priority", "medium")

    final_stage = "manual-review"
    reason = "default"

    if verified or priority == "done" or state == "vector":
        final_stage = "done"
        reason = "already treated in repo"
    elif kind in ("diagram-page", "graphic-heavy") and action in ("vector-first", "manual-visual-rebuild"):
        final_stage = "vector-next"
        reason = "high geometry value / diagram-driven page"
    elif kind == "worksheet-graphic":
        final_stage = "image-first-next"
        reason = "graphic page with weak text layer"
    elif kind == "text-heavy":
        final_stage = "rewrite-later"
        reason = "can be rewritten after diagram pages"
    else:
        final_stage = "manual-review"
        reason = "mixed content"

    rank = 999
    if final_stage == "done":
        rank = 0
    elif final_stage == "vector-next":
        rank = 1
    elif final_stage == "image-first-next":
        rank = 2
    elif final_stage == "rewrite-later":
        rank = 3
    else:
        rank = 4

    rec = {
        "page": page,
        "kind": kind,
        "graphics_state": state,
        "verified": verified,
        "current_priority": priority,
        "recommended_action": action,
        "final_stage": final_stage,
        "reason": reason,
        "image_count": r.get("image_count", 0),
        "char_count": r.get("char_count", 0),
        "question_marker_count": r.get("question_marker_count", 0),
        "categories": r.get("categories", []),
        "execution_rank": rank,
    }
    plan_records.append(rec)
    buckets[final_stage].append(page)

plan_records.sort(key=lambda x: (x["execution_rank"], x["page"]))

summary = {
    "project": "parabula2",
    "topic": "דלתון",
    "page_count": len(plan_records),
    "counts": {k: len(v) for k, v in buckets.items()},
    "buckets": buckets,
    "records": plan_records
}

out = Path("worksheets/deltoid/rebuild_plan")
out.mkdir(parents=True, exist_ok=True)
(out / "normalized_rebuild_plan.json").write_text(
    json.dumps(summary, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

lines = []
lines.append("# DELTOID NORMALIZED REBUILD PLAN")
lines.append("")
lines.append(f"- page_count: {summary['page_count']}")
for k, v in summary["counts"].items():
    lines.append(f"- {k}: {v}")
lines.append("")
lines.append("## Buckets")
for k, v in buckets.items():
    lines.append(f"- {k}: {', '.join(str(x) for x in v) if v else 'None'}")
lines.append("")
lines.append("## Ordered plan")
for r in plan_records:
    lines.append(
        f"- page {r['page']:02d} | stage={r['final_stage']} | kind={r['kind']} | "
        f"graphics_state={r['graphics_state']} | images={r['image_count']} | "
        f"chars={r['char_count']} | qmarkers={r['question_marker_count']} | reason={r['reason']}"
    )

(out / "NORMALIZED_REBUILD_PLAN.md").write_text("\n".join(lines) + "\n", encoding="utf-8")

html = []
html.append("<!DOCTYPE html>")
html.append('<html lang="he" dir="rtl">')
html.append("<head>")
html.append('<meta charset="utf-8">')
html.append('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
html.append("<title>Deltoid Normalized Rebuild Plan</title>")
html.append("<style>")
html.append("body{font-family:Arial,sans-serif;background:#f8fafc;margin:0;padding:24px}")
html.append("h1{margin:0 0 24px 0}")
html.append(".grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(260px,1fr));gap:16px}")
html.append(".card{background:#fff;border:2px solid #cbd5e1;border-radius:16px;padding:12px;box-shadow:0 4px 14px rgba(0,0,0,.05)}")
html.append(".card img{width:100%;height:auto;display:block;border-radius:10px;border:1px solid #e2e8f0}")
html.append(".meta{margin-top:10px;font-size:13px;color:#334155;line-height:1.55}")
html.append(".done{border-color:#16a34a}")
html.append(".vector-next{border-color:#dc2626}")
html.append(".image-first-next{border-color:#f59e0b}")
html.append(".rewrite-later{border-color:#2563eb}")
html.append(".manual-review{border-color:#64748b}")
html.append("</style>")
html.append("</head>")
html.append("<body>")
html.append("<h1>Deltoid Normalized Rebuild Plan</h1>")
html.append('<div class="grid">')
for r in plan_records:
    css = r["final_stage"]
    html.append(f'<div class="card {css}">')
    html.append(f'<img src="../image_inventory/thumbs/page-{r["page"]:02d}.png" alt="page {r["page"]}">')
    html.append(f'<div class="meta">עמוד {r["page"]:02d}<br>stage: {r["final_stage"]}<br>kind: {r["kind"]}<br>graphics_state: {r["graphics_state"]}<br>images: {r["image_count"]}<br>chars: {r["char_count"]}<br>qmarkers: {r["question_marker_count"]}<br>reason: {r["reason"]}</div>')
    html.append("</div>")
html.append("</div>")
html.append("</body>")
html.append("</html>")
(out / "rebuild-plan.html").write_text("\n".join(html) + "\n", encoding="utf-8")

print(json.dumps(summary["counts"], ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("normalized rebuild plan json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","rebuild_plan","normalized_rebuild_plan.json")), true);
});

test("normalized rebuild plan markdown exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","rebuild_plan","NORMALIZED_REBUILD_PLAN.md")), true);
});

test("normalized rebuild plan html exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","rebuild_plan","rebuild-plan.html")), true);
});

test("normalized rebuild plan contains 60 records", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","rebuild_plan","normalized_rebuild_plan.json"), "utf8"));
  assert.equal(data.page_count, 60);
  assert.equal(data.records.length, 60);
});

test("normalized rebuild plan has done bucket", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","rebuild_plan","normalized_rebuild_plan.json"), "utf8"));
  assert.ok(Array.isArray(data.buckets.done));
  assert.ok(data.buckets.done.length >= 5);
});
EOF

if ! grep -q "Deltoid normalized rebuild plan" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deltoid normalized rebuild plan

- יש לשמור תוכנית שחזור מנורמלת תחת:
  `worksheets/deltoid/rebuild_plan/`
- כל עמוד חייב להשתייך ל-stage אחד:
  - done
  - vector-next
  - image-first-next
  - rewrite-later
  - manual-review
- התוכנית הזו היא מקור האמת לסדר העבודה על בניית הספר החדש
EOF
fi

if ! grep -q "תוכנית שחזור מנורמלת לדלתון" RULES.md; then
cat >> RULES.md <<'EOF'

---

## תוכנית שחזור מנורמלת לדלתון

- אחרי visual page map חייבת להיבנות rebuild plan
- כל עמוד מסווג לשלב עבודה ברור
- אין לעבוד אקראית; עובדים לפי ה-stage שנקבע
EOF
fi

npm test | tee deltoid_normalized_rebuild_plan_test_output.txt

{
  echo "# Deltoid normalized rebuild plan build"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## rebuild plan summary"
  cat "$JSON_OUT"
  echo
  echo "## tests"
  cat deltoid_normalized_rebuild_plan_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md deltoid_normalized_rebuild_plan_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: build normalized deltoid rebuild plan for full book"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "PLAN: $HTML_OUT"
echo "NEXT HIGH PRIORITY: generate first real rebuilt chapter pages"
