import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("visual page map json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","visual_page_map","visual_page_map.json")), true);
});

test("visual page map markdown exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","visual_page_map","VISUAL_PAGE_MAP.md")), true);
});

test("visual map html exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","visual_page_map","visual-map.html")), true);
});

test("visual page map contains 60 records", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","visual_page_map","visual_page_map.json"), "utf8"));
  assert.equal(data.page_count, 60);
  assert.equal(data.records.length, 60);
});
