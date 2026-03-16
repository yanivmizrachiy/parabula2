import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("final batch 01 index exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_01","index.html")), true);
});

test("final batch 01 manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_01","batch_01_manifest.json")), true);
});

test("final batch 01 has 5 pages", () => {
  const dir = path.join("worksheets","deltoid","final_pages_batch_01","pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.html$/i.test(x));
  assert.equal(files.length, 5);
});

test("final page has blue page number and no numbered question labels", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","final_pages_batch_01","pages","page-09.html"), "utf8");
  assert.ok(html.includes('class="page-number"'));
  assert.equal(/שאלה\s*\d+/u.test(html), false);
  assert.ok(html.includes('class="question-bullet">●<'));
});
