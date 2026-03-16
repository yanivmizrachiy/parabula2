import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("a4 packing audit json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","a4_packing_audit.json")), true);
});

test("a4 packing report exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","A4_PACKING_AUDIT_REPORT.md")), true);
});
