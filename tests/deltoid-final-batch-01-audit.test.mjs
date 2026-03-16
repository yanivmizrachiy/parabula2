import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("batch 01 audit json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_01","batch_01_audit.json")), true);
});

test("batch 01 audit report exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_01","BATCH_01_AUDIT_REPORT.md")), true);
});

test("batch 01 audit has 5 records", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","final_pages_batch_01","batch_01_audit.json"), "utf8"));
  assert.equal(data.records.length, 5);
});

test("page 09 still has bullet layout and page number", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","final_pages_batch_01","pages","page-09.html"), "utf8");
  assert.ok(html.includes('class="page-number"'));
  assert.ok(html.includes('class="question-bullet">●<'));
});
