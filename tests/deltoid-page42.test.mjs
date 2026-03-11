import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("page 42 enhanced asset exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","exact_assets","page-42-enhanced.png")), true);
});

test("page 42 html points to enhanced asset", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","exact_pages","page-42.html"), "utf8");
  assert.ok(html.includes("page-42-enhanced.png"));
});
