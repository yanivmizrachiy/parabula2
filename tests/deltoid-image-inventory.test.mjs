import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("image inventory json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","image_inventory","image_inventory.json")), true);
});

test("image gallery exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","image_inventory","gallery.html")), true);
});

test("all 60 page images exist", () => {
  const dir = path.join("worksheets","deltoid","image_inventory","pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.png$/i.test(x));
  assert.equal(files.length, 60);
});

test("all 60 thumbnails exist", () => {
  const dir = path.join("worksheets","deltoid","image_inventory","thumbs");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.png$/i.test(x));
  assert.equal(files.length, 60);
});
