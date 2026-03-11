import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("graphics analysis file exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","exact_assets","graphics_analysis.json")), true);
});

test("at least one enhanced page exists", () => {
  const dir = path.join("worksheets","deltoid","exact_assets");
  const files = fs.readdirSync(dir).filter(x => x.endsWith("-enhanced.png"));
  assert.ok(files.length >= 1, "Expected enhanced PNG assets");
});
