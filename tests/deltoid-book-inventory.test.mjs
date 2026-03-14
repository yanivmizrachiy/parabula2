import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("book inventory json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","book_inventory","book_inventory.json")), true);
});

test("book status markdown exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","book_inventory","BOOK_STATUS.md")), true);
});

test("all 60 page text files exist", () => {
  const dir = path.join("worksheets","deltoid","book_inventory","text");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.clean\.txt$/i.test(x));
  assert.equal(files.length, 60);
});

test("inventory page count is 60", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","book_inventory","book_inventory.json"), "utf8"));
  assert.equal(data.page_count, 60);
});
