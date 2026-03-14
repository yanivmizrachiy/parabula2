import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("chapter 02 manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_02_vector_next","manifest.json")), true);
});

test("chapter 02 index exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_02_vector_next","index.html")), true);
});

test("chapter 02 book exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","chapters","chapter_02_vector_next","chapter-book.html")), true);
});

test("chapter 02 contains wrapped pages", () => {
  const dir = path.join("worksheets","deltoid","chapters","chapter_02_vector_next","pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.html$/i.test(x));
  assert.ok(files.length > 0);
});

test("chapter 02 manifest has vector-next bucket", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","chapters","chapter_02_vector_next","manifest.json"), "utf8"));
  assert.equal(data.source_bucket, "vector-next");
  assert.ok(data.page_count > 0);
});
