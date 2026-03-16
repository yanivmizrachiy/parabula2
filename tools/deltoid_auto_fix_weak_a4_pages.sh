#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_AUTO_FIX_WEAK_A4_PAGES_$(date +%Y%m%d_%H%M%S).md"
AUDIT_JSON="worksheets/deltoid/a4_packing_audit.json"
TEST_FILE="tests/deltoid-auto-fix-weak-a4-pages.test.mjs"

python - <<'PYEOF'
from pathlib import Path
import json, re

audit_path = Path("worksheets/deltoid/a4_packing_audit.json")
if not audit_path.exists():
    raise SystemExit("Missing audit json")

data = json.loads(audit_path.read_text(encoding="utf-8"))
records = data.get("records", [])
fixed = []

insert_block = """
      <section class="a4-balance-block">
        <article class="question">
          <span class="question-bullet">●</span>
          <div class="question-body">
            הסבר בקצרה באילו תכונות של דלתון השתמשת במהלך הפתרון, וכתוב את הנימוק המתמטי בצורה מסודרת וברורה.
          </div>
        </article>
      </section>
""".rstrip()

for r in records:
    if r.get("packing_status") != "weak":
        continue

    file_path = Path(r["file"])
    if not file_path.exists():
        continue

    html = file_path.read_text(encoding="utf-8", errors="ignore")

    if "a4-balance-block" in html:
        continue

    if "</section>\n  </main>" in html:
        html = html.replace("</section>\n  </main>", insert_block + "\n    </section>\n  </main>", 1)
        file_path.write_text(html, encoding="utf-8")
        fixed.append(file_path.as_posix())
    elif "</section></main>" in html:
        html = html.replace("</section></main>", insert_block + "</section></main>", 1)
        file_path.write_text(html, encoding="utf-8")
        fixed.append(file_path.as_posix())

Path("worksheets/deltoid/auto_fix_weak_a4_pages.json").write_text(
    json.dumps({"fixed_count": len(fixed), "fixed_files": fixed}, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

print(json.dumps({"fixed_count": len(fixed), "fixed_files": fixed[:20]}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'TESTEOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("auto fix weak a4 json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","auto_fix_weak_a4_pages.json")), true);
});
TESTEOF

npm test | tee deltoid_auto_fix_weak_a4_pages_test_output.txt

{
  echo "# Deltoid auto-fix weak A4 pages"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## auto-fix summary"
  cat worksheets/deltoid/auto_fix_weak_a4_pages.json
  echo
  echo "## tests"
  cat deltoid_auto_fix_weak_a4_pages_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add tools/deltoid_auto_fix_weak_a4_pages.sh \
  worksheets/deltoid/auto_fix_weak_a4_pages.json \
  "$TEST_FILE" \
  deltoid_auto_fix_weak_a4_pages_test_output.txt \
  "$REPORT" \
  worksheets/deltoid

if ! git diff --cached --quiet; then
  git commit -m "fix: auto-balance weak deltoid A4 pages"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
