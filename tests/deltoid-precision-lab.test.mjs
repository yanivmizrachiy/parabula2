import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("precision lab json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","precision_lab","precision_lab.json")), true);
});

test("precision gallery exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","precision_lab","precision-gallery.html")), true);
});

test("precision lab source pages exist", () => {
  const dir = path.join("worksheets","deltoid","precision_lab","source_pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.png$/i.test(x));
  assert.ok(files.length >= 10);
});

test("precision lab line maps exist", () => {
  const dir = path.join("worksheets","deltoid","precision_lab","line_maps");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.png$/i.test(x));
  assert.ok(files.length >= 10);
});
