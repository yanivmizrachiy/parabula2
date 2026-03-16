#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_AUTO_FIX_PRODUCTION_WEAK_PAGES_$(date +%Y%m%d_%H%M%S).md"
PACKING_JSON="worksheets/deltoid/production_a4_packing_audit.json"
TEST_FILE="tests/deltoid-auto-fix-production-weak-pages.test.mjs"

python - <<'PYEOF'
from pathlib import Path
import json

packing_path = Path("worksheets/deltoid/production_a4_packing_audit.json")
if not packing_path.exists():
    raise SystemExit("Missing production_a4_packing_audit.json")

data = json.loads(packing_path.read_text(encoding="utf-8"))
records = data.get("records", [])
fixed = []

insert_block = """
      <section class="a4-balance-block">
        <article class="question">
          <span class="question-bullet">●</span>
          <div class="question-body">
            כתוב בצורה מסודרת אילו תכונות של דלתון שימשו אותך, נמק כל שלב, והסבר כיצד הגעת לפתרון הסופי.
          </div>
        </article>
        <article class="question">
          <span class="question-bullet">●</span>
          <div class="question-body">
            בדוק האם קיימת דרך נוספת לפתור את השאלה, וכתוב בקצרה מה ההבדל בין שתי הדרכים.
          </div>
        </article>
      </section>
""".rstrip()

for rec in records:
    if rec.get("packing_status") != "weak":
        continue

    file_path = Path(rec["file"])
    if not file_path.exists():
        continue

    html = file_path.read_text(encoding="utf-8", errors="ignore")

    if "a4-balance-block" in html:
        continue

    if "</section>\n</main>" in html:
        html = html.replace("</section>\n</main>", insert_block + "\n    </section>\n</main>", 1)
    elif "</section>\n  </main>" in html:
        html = html.replace("</section>\n  </main>", insert_block + "\n    </section>\n  </main>", 1)
    elif "</body>" in html:
        html = html.replace("</body>", insert_block + "\n</body>", 1)
    else:
        continue

    file_path.write_text(html, encoding="utf-8")
    fixed.append(file_path.as_posix())

Path("worksheets/deltoid/production_auto_fix_weak_pages.json").write_text(
    json.dumps({
        "fixed_count": len(fixed),
        "fixed_files": fixed
    }, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

print(json.dumps({
    "fixed_count": len(fixed),
    "fixed_files": fixed
}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'TESTEOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("production auto-fix weak pages json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","production_auto_fix_weak_pages.json")), true);
});

test("pages 10-14 contain a4 balance block", () => {
  for (const p of ["10","11","12","13","14"]) {
    const file = path.join("worksheets","deltoid","final_pages_batch_02","pages",`page-${p}.html`);
    const html = fs.readFileSync(file, "utf8");
    assert.ok(html.includes("a4-balance-block"));
  }
});
TESTEOF

npm test | tee deltoid_auto_fix_production_weak_pages_test_output.txt

{
  echo "# Deltoid auto-fix production weak pages"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## auto-fix summary"
  cat worksheets/deltoid/production_auto_fix_weak_pages.json
  echo
  echo "## tests"
  cat deltoid_auto_fix_production_weak_pages_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add tools/deltoid_auto_fix_production_weak_pages.sh \
  worksheets/deltoid/production_auto_fix_weak_pages.json \
  worksheets/deltoid/final_pages_batch_02/pages/page-10.html \
  worksheets/deltoid/final_pages_batch_02/pages/page-11.html \
  worksheets/deltoid/final_pages_batch_02/pages/page-12.html \
  worksheets/deltoid/final_pages_batch_02/pages/page-13.html \
  worksheets/deltoid/final_pages_batch_02/pages/page-14.html \
  "$TEST_FILE" \
  deltoid_auto_fix_production_weak_pages_test_output.txt \
  "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "fix: auto-balance weak production deltoid pages 10-14"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
