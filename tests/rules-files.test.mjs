import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";

test("rules files exist", () => {
  assert.equal(fs.existsSync("PROJECT_RULES.md"), true);
  assert.equal(fs.existsSync("RULES.md"), true);
  assert.equal(fs.existsSync("rules.html"), true);
});
