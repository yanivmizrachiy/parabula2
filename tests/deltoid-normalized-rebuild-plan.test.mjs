import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("normalized rebuild plan json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","rebuild_plan","normalized_rebuild_plan.json")), true);
});

test("normalized rebuild plan markdown exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","rebuild_plan","NORMALIZED_REBUILD_PLAN.md")), true);
});

test("normalized rebuild plan html exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","rebuild_plan","rebuild-plan.html")), true);
});

test("normalized rebuild plan contains 60 records", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","rebuild_plan","normalized_rebuild_plan.json"), "utf8"));
  assert.equal(data.page_count, 60);
  assert.equal(data.records.length, 60);
});

test("normalized rebuild plan has done bucket", () => {
  const data = JSON.parse(fs.readFileSync(path.join("worksheets","deltoid","rebuild_plan","normalized_rebuild_plan.json"), "utf8"));
  assert.ok(Array.isArray(data.buckets.done));
  assert.ok(data.buckets.done.length >= 5);
});
