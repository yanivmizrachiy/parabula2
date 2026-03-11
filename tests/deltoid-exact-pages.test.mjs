import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("exact deltoid png assets exist", () => {
  const dir = path.join("worksheets", "deltoid", "exact_assets");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.png$/i.test(x));
  assert.ok(files.length >= 1, "Expected exact PNG page assets");
});

test("exact deltoid html pages exist", () => {
  const dir = path.join("worksheets", "deltoid", "exact_pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.html$/i.test(x));
  assert.ok(files.length >= 1, "Expected exact HTML facsimile pages");
});

test("exact deltoid manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets", "deltoid", "exact_pages", "manifest.json")), true);
});
