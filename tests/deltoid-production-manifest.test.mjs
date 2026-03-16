import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("production manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","production_manifest.json")), true);
});

test("production manifest has at least 15 pages", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","production_manifest.json"), "utf8"));
  assert.ok(data.page_count >= 15);
});
