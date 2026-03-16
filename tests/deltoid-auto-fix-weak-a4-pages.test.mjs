import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("auto fix weak a4 json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","auto_fix_weak_a4_pages.json")), true);
});
