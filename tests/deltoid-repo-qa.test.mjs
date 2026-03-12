import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("graphics status json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","graphics-status.json")), true);
});

test("vector qa markdown exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","VECTOR_QA.md")), true);
});

test("page 56 inspection assets exist", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page56_inspection","page-56-raw.png")), true);
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page56_inspection","page-56-enhanced.png")), true);
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page56_inspection","page-56-lines.png")), true);
});

test("exact page count is 60", () => {
  const dir = path.join("worksheets","deltoid","exact_pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.html$/i.test(x));
  assert.equal(files.length, 60);
});

test("all vector html files have no inline style", () => {
  const dir = path.join("worksheets","deltoid","vector_pages");
  if (!fs.existsSync(dir)) return;
  const files = fs.readdirSync(dir).filter(x => /^page-.*\.html$/i.test(x));
  for (const file of files) {
    const html = fs.readFileSync(path.join(dir, file), "utf8");
    assert.equal(html.includes('style="'), false, `${file} has inline style attribute`);
    assert.equal(html.includes('<style'), false, `${file} has inline style block`);
  }
});
