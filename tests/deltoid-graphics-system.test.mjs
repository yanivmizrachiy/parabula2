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
