import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("theme json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","editable_book","config","theme.json")), true);
});

test("generated theme css exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","editable_book","assets","theme.generated.css")), true);
});

test("editable index links generated theme", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","editable_book","editable-index.html"), "utf8");
  assert.ok(html.includes("theme.generated.css"));
});

test("editable book links generated theme", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","editable_book","editable-book.html"), "utf8");
  assert.ok(html.includes("theme.generated.css"));
});
