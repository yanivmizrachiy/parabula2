import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("production strict qa json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","production_strict_qa.json")), true);
});

test("production packing audit json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","production_a4_packing_audit.json")), true);
});

test("production packing audit report exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","PRODUCTION_A4_PACKING_AUDIT_REPORT.md")), true);
});
