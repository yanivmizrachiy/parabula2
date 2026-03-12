import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("page 41 inspection assets exist", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page41_inspection","page-41-raw.png")), true);
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page41_inspection","page-41-enhanced.png")), true);
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page41_inspection","page-41-lines.png")), true);
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page41_inspection","page-41-images.txt")), true);
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","page41_inspection","page-41.txt")), true);
});
