#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_EXACT_PREVIEW_PUBLISH_$(date +%Y%m%d_%H%M%S).md"

cat > preview/server.mjs <<'EOF'
import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..");
const host = process.env.HOST || "127.0.0.1";
const port = Number(process.env.PORT || 5179);

function send(res, code, body, type = "text/plain; charset=utf-8") {
  res.writeHead(code, { "Content-Type": type });
  res.end(body);
}

function rootPages() {
  return fs.readdirSync(repoRoot, { withFileTypes: true })
    .filter(d => d.isFile() && /^עמוד-\d+\.html$/u.test(d.name))
    .map(d => d.name)
    .sort((a, b) => a.localeCompare(b, "he", { numeric: true }));
}

function worksheetPages() {
  const out = [];
  const worksheetsDir = path.join(repoRoot, "worksheets");
  if (!fs.existsSync(worksheetsDir)) return out;

  function walk(dir) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        walk(full);
      } else if (/page-\d+\.html$/i.test(entry.name)) {
        out.push(path.relative(repoRoot, full).replace(/\\/g, "/"));
      }
    }
  }

  walk(worksheetsDir);
  return out.sort((a, b) => a.localeCompare(b, "he", { numeric: true }));
}

function fileList() {
  return [...rootPages(), ...worksheetPages()];
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);

  if (url.pathname === "/" || url.pathname === "/preview") {
    return send(
      res,
      200,
      fs.readFileSync(path.join(repoRoot, "preview", "index.html"), "utf8"),
      "text/html; charset=utf-8"
    );
  }

  if (url.pathname === "/preview/app.mjs") {
    return send(
      res,
      200,
      fs.readFileSync(path.join(repoRoot, "preview", "app.mjs"), "utf8"),
      "text/javascript; charset=utf-8"
    );
  }

  if (url.pathname === "/api/toc") {
    return send(
      res,
      200,
      JSON.stringify({ files: fileList() }, null, 2),
      "application/json; charset=utf-8"
    );
  }

  const rel = decodeURIComponent(url.pathname.replace(/^\/+/, ""));
  const target = path.join(repoRoot, rel);

  if (!target.startsWith(repoRoot)) {
    return send(res, 403, "Forbidden");
  }

  if (fs.existsSync(target) && fs.statSync(target).isFile()) {
    const ext = path.extname(target).toLowerCase();
    const type =
      ext === ".html" ? "text/html; charset=utf-8" :
      ext === ".css" ? "text/css; charset=utf-8" :
      ext === ".mjs" ? "text/javascript; charset=utf-8" :
      ext === ".json" ? "application/json; charset=utf-8" :
      ext === ".png" ? "image/png" :
      "text/plain; charset=utf-8";

    if (ext === ".png") {
      res.writeHead(200, { "Content-Type": type });
      fs.createReadStream(target).pipe(res);
      return;
    }

    return send(res, 200, fs.readFileSync(target, "utf8"), type);
  }

  return send(res, 404, "Not found");
});

server.listen(port, host, () => {
  console.log(`Preview server running: http://${host}:${port}/preview`);
});
EOF

cat > tools/build-site-termux.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SITE="$ROOT/site"

rm -rf "$SITE"
mkdir -p "$SITE"

[ -d "$ROOT/styles" ] && cp -R "$ROOT/styles" "$SITE/"
[ -d "$ROOT/assets" ] && cp -R "$ROOT/assets" "$SITE/" || true

find "$ROOT" -maxdepth 1 -type f -name 'עמוד-*.html' -exec cp {} "$SITE/" \;

if [ -d "$ROOT/worksheets" ]; then
  while IFS= read -r -d '' file; do
    rel="${file#$ROOT/}"
    mkdir -p "$SITE/$(dirname "$rel")"
    cp "$file" "$SITE/$rel"
  done < <(find "$ROOT/worksheets" -type f \( -name 'page-*.html' -o -name '*.png' -o -name 'manifest.json' -o -name 'README.md' \) -print0)
fi

ROOT_LINKS="$(
  find "$SITE" -maxdepth 1 -type f -name 'עמוד-*.html' | sort | sed "s#^$SITE/##" |
  awk '{print "<li><a href=\""$0"\">"$0"</a></li>"}'
)"

TOPIC_LINKS="$(
  find "$SITE/worksheets" -type f -name 'page-*.html' 2>/dev/null | sort | sed "s#^$SITE/##" |
  awk '{print "<li><a href=\""$0"\">"$0"</a></li>"}'
)"

cat > "$SITE/index.html" <<HTML
<!DOCTYPE html>
<html lang="he" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>parabula2</title>
<link rel="stylesheet" href="styles/worksheet.css">
</head>
<body>
<main class="a4-page">
<header class="worksheet-header">
<h1 class="page-title">parabula2</h1>
<div class="page-number">1</div>
</header>
<section class="questions">
<div class="question"><span class="q-bullet"></span><div>דפי שורש</div></div>
<ul>
$ROOT_LINKS
</ul>
<div class="question"><span class="q-bullet"></span><div>דפי worksheets כולל exact</div></div>
<ul>
$TOPIC_LINKS
</ul>
</section>
</main>
</body>
</html>
HTML

: > "$SITE/.nojekyll"
echo "site built"
EOF

chmod +x tools/build-site-termux.sh

cat > tests/deltoid-exact-integration.test.mjs <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("exact deltoid html pages exist", () => {
  const dir = path.join("worksheets", "deltoid", "exact_pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.html$/i.test(x));
  assert.equal(files.length, 60, `Expected 60 exact pages, got ${files.length}`);
});

test("exact deltoid png assets exist", () => {
  const dir = path.join("worksheets", "deltoid", "exact_assets");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.png$/i.test(x));
  assert.equal(files.length, 60, `Expected 60 exact pngs, got ${files.length}`);
});

test("exact deltoid manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets", "deltoid", "exact_pages", "manifest.json")), true);
});
EOF

if ! grep -q "Exact facsimile pages must be visible in preview and publish output" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Exact facsimile pages must be visible in preview and publish output

- כל דפי exact תחת `worksheets/**/exact_pages/` או `worksheets/**/pages/` חייבים להיות זמינים ב־`/preview`
- `api/toc` חייב לכלול גם דפי exact
- build של `site/` חייב להעתיק גם דפי exact וגם נכסי PNG נלווים
EOF
fi

if ! grep -q "דפי exact חייבים להופיע גם ב-preview וגם ב-site" RULES.md; then
cat >> RULES.md <<'EOF'

---

## דפי exact חייבים להופיע גם ב-preview וגם ב-site

- אם נבנו דפי exact מדויקים, אסור להשאיר אותם מנותקים
- הם חייבים להופיע ב־preview
- הם חייבים להיכלל ב־site
- גם קבצי ה־PNG התומכים חייבים לעבור לבנייה
EOF
fi

npm test | tee exact_preview_publish_test_output.txt
bash tools/build-site-termux.sh | tee exact_site_build_output.txt

{
  echo "# Exact preview publish integration report"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## exact page count"
  find worksheets/deltoid/exact_pages -maxdepth 1 -type f -name "page-*.html" | sort | wc -l
  echo
  echo "## exact asset count"
  find worksheets/deltoid/exact_assets -maxdepth 1 -type f -name "page-*.png" | sort | wc -l
  echo
  echo "## npm test"
  cat exact_preview_publish_test_output.txt
  echo
  echo "## site build"
  cat exact_site_build_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add preview/server.mjs tools/build-site-termux.sh tests/deltoid-exact-integration.test.mjs PROJECT_RULES.md RULES.md exact_preview_publish_test_output.txt exact_site_build_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: integrate exact deltoid pages into preview and publish pipeline"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "PREVIEW URL:"
echo "http://127.0.0.1:5179/preview?file=worksheets/deltoid/exact_pages/page-01.html"
