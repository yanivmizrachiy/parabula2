import fs from "fs";
import assert from "assert";

assert.ok(fs.existsSync("worksheets/deltoid/vector_assets/deltoid_page42.svg"));
assert.ok(fs.existsSync("worksheets/deltoid/vector_pages/page-42-vector.html"));

console.log("page 42 vector files exist ✓");
