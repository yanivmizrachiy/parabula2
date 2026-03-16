import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("rebuild v2 source_text dir exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","rebuild_v2","source_text")), true);
});

test("rebuild v2 has 60 source text files", () => {
  const dir = path.join("worksheets","deltoid","rebuild_v2","source_text");
  const files = fs.readdirSync(dir).filter(x => /^page-\d{2}\.txt$/i.test(x));
  assert.equal(files.length, 60);
});

test("content queue exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","rebuild_v2","config","content_queue.json")), true);
});

test("page 01 contains extracted source text block", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","rebuild_v2","pages","page-01.html"), "utf8");
  assert.ok(html.includes("טקסט מקור שחולץ מהעמוד"));
});
