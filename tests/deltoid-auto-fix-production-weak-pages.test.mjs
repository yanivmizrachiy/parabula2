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
