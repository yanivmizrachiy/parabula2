import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("unified book shell json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","unified_book","book-shell.json")), true);
});

test("unified book index exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","unified_book","index.html")), true);
});

test("unified book page exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","unified_book","book.html")), true);
});

test("unified book theme exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","unified_book","assets","theme.css")), true);
});

test("unified book has 3 chapters", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","unified_book","book-shell.json"), "utf8"));
  assert.equal(data.chapter_count, 3);
});
