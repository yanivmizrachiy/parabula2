import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("deltoid generated pages exist", () => {
  const dir = path.join("worksheets", "deltoid", "pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.html$/i.test(x));
  assert.ok(files.length >= 1, "Expected generated deltoid pages");
});

test("deltoid manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets", "deltoid", "pages", "manifest.json")), true);
});
