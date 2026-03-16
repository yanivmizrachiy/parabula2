import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("batch 02 index exists", () => {
assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_02","index.html")),true);
});

test("batch 02 manifest exists", () => {
assert.equal(fs.existsSync(path.join("worksheets","deltoid","final_pages_batch_02","batch_02_manifest.json")),true);
});

test("batch 02 has 5 pages", () => {
const dir=path.join("worksheets","deltoid","final_pages_batch_02","pages");
const files=fs.readdirSync(dir).filter(x=>/^page-\d{2}\.html$/i.test(x));
assert.equal(files.length,5);
});
