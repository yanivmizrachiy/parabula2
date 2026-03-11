import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("exact deltoid html pages exist", () => {
  const dir = path.join("worksheets", "deltoid", "exact_pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.html$/i.test(x));
  assert.equal(files.length, 60, `Expected 60 exact pages, got ${files.length}`);
});

test("exact deltoid png assets exist", () => {
  const dir = path.join("worksheets", "deltoid", "exact_assets");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.png$/i.test(x));
  assert.equal(files.length, 60, `Expected 60 exact pngs, got ${files.length}`);
});

test("exact deltoid manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets", "deltoid", "exact_pages", "manifest.json")), true);
});
