import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("page 38 vector svg exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","vector_assets","deltoid_page38.svg")), true);
});

test("page 38 vector html exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","vector_pages","page-38.html")), true);
});

test("page 38 vector html has no inline style", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","vector_pages","page-38.html"), "utf8");
  assert.equal(html.includes('style="'), false);
  assert.equal(html.includes('<style'), false);
});
