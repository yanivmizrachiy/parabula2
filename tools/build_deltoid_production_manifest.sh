#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_PRODUCTION_MANIFEST_$(date +%Y%m%d_%H%M%S).md"
JSON_OUT="worksheets/deltoid/production_manifest.json"
TEST_FILE="tests/deltoid-production-manifest.test.mjs"

mkdir -p tools tests worksheets/deltoid

python - <<'PYEOF'
from pathlib import Path
import json, re

roots = [
    Path("worksheets/deltoid/final_pages_batch_01/pages"),
    Path("worksheets/deltoid/final_pages_batch_01_refined/pages"),
    Path("worksheets/deltoid/final_pages_batch_02/pages"),
    Path("worksheets/deltoid/final_pages_batch_03/pages"),
]

best = {}
priority = {
    "final_pages_batch_01": 1,
    "final_pages_batch_01_refined": 2,
    "final_pages_batch_02": 1,
    "final_pages_batch_03": 1,
}

for root in roots:
    if not root.exists():
        continue
    for p in sorted(root.glob("page-*.html")):
        m = re.search(r"page-(\d+)\.html$", p.name)
        if not m:
            continue
        page = int(m.group(1))
        batch_name = p.parts[-3]
        pr = priority.get(batch_name, 0)
        current = best.get(page)
        if current is None or pr >= current["priority"]:
            best[page] = {
                "page": page,
                "file": p.as_posix(),
                "source_set": batch_name,
                "priority": pr
            }

records = [best[k] for k in sorted(best)]
summary = {
    "page_count": len(records),
    "pages": [r["page"] for r in records],
    "records": records
}

Path("worksheets/deltoid/production_manifest.json").write_text(
    json.dumps(summary, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

print(json.dumps({
    "page_count": summary["page_count"],
    "pages": summary["pages"]
}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'TESTEOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("production manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","production_manifest.json")), true);
});

test("production manifest has at least 15 pages", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","production_manifest.json"), "utf8"));
  assert.ok(data.page_count >= 15);
});
TESTEOF

npm test | tee deltoid_production_manifest_test_output.txt

{
  echo "# Deltoid production manifest"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## manifest"
  cat "$JSON_OUT"
  echo
  echo "## tests"
  cat deltoid_production_manifest_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add tools/build_deltoid_production_manifest.sh \
  worksheets/deltoid/production_manifest.json \
  "$TEST_FILE" \
  deltoid_production_manifest_test_output.txt \
  "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: add deltoid production manifest for final page sets"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
