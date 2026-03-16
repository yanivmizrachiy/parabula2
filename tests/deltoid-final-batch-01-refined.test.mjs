import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("refined batch index exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_01_refined","index.html")), true);
});

test("refined batch manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_01_refined","refined_manifest.json")), true);
});

test("refined batch has 5 pages", () => {
  const dir = path.join("worksheets","deltoid","final_pages_batch_01_refined","pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.html$/i.test(x));
  assert.equal(files.length, 5);
});

test("refined page keeps bullet layout and page number", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","final_pages_batch_01_refined","pages","page-09.html"), "utf8");
  assert.ok(html.includes('class="page-number"'));
  assert.ok(html.includes('class="question-bullet">●<'));
  assert.equal(/שאלה\s*\d+/u.test(html), false);
});
