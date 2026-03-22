import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("batch 03 repair manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_03","batch_03_repair_manifest.json")), true);
});

test("batch 03 repaired pages keep bullet layout and page number", () => {
  for (const p of ["15","16","17","18","19"]) {
    const html = fs.readFileSync(path.join("worksheets","deltoid","final_pages_batch_03","pages",`page-${p}.html`), "utf8");
    assert.ok(html.includes('class="page-number"'));
    assert.ok(html.includes('class="question-bullet">●<'));
    assert.equal(/שאלה\s*\d+/u.test(html), false);
  }
});
