import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("strict qa tool exists", () => {
  assert.equal(fs.existsSync(path.join("tools","deltoid_strict_layout_math_qa.sh")), true);
});
