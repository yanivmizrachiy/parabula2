import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";

test("at least 10 worksheet pages exist", () => {
  const files = fs.readdirSync(".").filter(x => /^עמוד-\d+\.html$/u.test(x));
  assert.ok(files.length >= 10, `Expected at least 10 pages, got ${files.length}`);
});
