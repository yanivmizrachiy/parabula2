import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("chapter 03 manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_03_image_first","manifest.json")), true);
});

test("chapter 03 index exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_03_image_first","index.html")), true);
});

test("chapter 03 book exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_03_image_first","chapter-book.html")), true);
});

test("chapter 03 contains wrapped pages", () => {
  const dir = path.join("worksheets","deltoid","chapters","chapter_03_image_first","pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.html$/i.test(x));
  assert.ok(files.length > 0);
});

test("chapter 03 manifest has image-first-next bucket", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","chapters","chapter_03_image_first","manifest.json"), "utf8"));
  assert.equal(data.source_bucket, "image-first-next");
  assert.ok(data.page_count > 0);
});
