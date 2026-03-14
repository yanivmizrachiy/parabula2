import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("chapter manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_01_done_pages","manifest.json")), true);
});

test("chapter index exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_01_done_pages","index.html")), true);
});

test("chapter book exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_01_done_pages","chapter-book.html")), true);
});

test("chapter contains 5 wrapped pages", () => {
  const dir = path.join("worksheets","deltoid","chapters","chapter_01_done_pages","pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.html$/i.test(x));
  assert.equal(files.length, 5);
});

test("chapter manifest page count is 5", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","chapters","chapter_01_done_pages","manifest.json"), "utf8"));
  assert.equal(data.page_count, 5);
});
