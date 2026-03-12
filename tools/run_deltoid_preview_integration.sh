#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_PREVIEW_INTEGRATION_$(date +%Y%m%d_%H%M%S).md"

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
      "text/plain; charset=utf-8";
    return send(res, 200, fs.readFileSync(target, "utf8"), type);
  }

  return send(res, 404, "Not found");
});

server.listen(port, host, () => {
  console.log(`Preview server running: http://${host}:${port}/preview`);
});
EOF

cat > preview/app.mjs <<'EOF'
const host = document.getElementById("host");
const statusEl = document.getElementById("status");

function getFileFromQuery() {
  const url = new URL(window.location.href);
  return url.searchParams.get("file") || "";
}

async function loadToc() {
  const res = await fetch("/api/toc", { cache: "no-store" });
  if (!res.ok) throw new Error(`TOC HTTP ${res.status}`);
  return res.json();
}

function renderFrame(file) {
  host.innerHTML = "";
  const iframe = document.createElement("iframe");
  iframe.className = "reader-frame";
  iframe.src = `/${file}`;
  iframe.loading = "eager";
  iframe.title = file;
  host.appendChild(iframe);
}

async function boot() {
  try {
    const toc = await loadToc();
    const files = Array.isArray(toc?.files) ? toc.files : [];
    const requested = getFileFromQuery();
    const selected = files.includes(requested) ? requested : (files[0] || "");

    if (!selected) {
      statusEl.textContent = "אין עדיין דפים";
      host.innerHTML = '<div class="preview-empty">אין עדיין דפים תקינים לתצוגה מקדימה.</div>';
      return;
    }

    statusEl.textContent = `מוצג: ${selected}`;
    renderFrame(selected);
  } catch (err) {
    statusEl.textContent = "שגיאת preview";
    host.innerHTML = `<div class="preview-empty">שגיאה בטעינת התצוגה: ${String(err.message || err)}</div>`;
  }
}

boot();
EOF

cat > tools/build-site.ps1 <<'EOF'
param()
$ErrorActionPreference='Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$site = Join-Path $repoRoot 'site'

if(Test-Path $site){ Remove-Item $site -Recurse -Force }
New-Item -ItemType Directory -Path $site | Out-Null

Copy-Item (Join-Path $repoRoot 'styles') $site -Recurse -Force
Copy-Item (Join-Path $repoRoot 'assets') $site -Recurse -Force

Get-ChildItem $repoRoot -Filter 'עמוד-*.html' -File | ForEach-Object {
  Copy-Item $_.FullName $site -Force
}

$worksheetPages = Get-ChildItem (Join-Path $repoRoot 'worksheets') -Recurse -File -Filter 'page-*.html' -ErrorAction SilentlyContinue
foreach($page in $worksheetPages){
  $relative = $page.FullName.Substring($repoRoot.Length).TrimStart('\').Replace('\','/')
  $target = Join-Path $site $relative.Replace('/','\')
  $targetDir = Split-Path $target -Parent
  if(!(Test-Path $targetDir)){ New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
  Copy-Item $page.FullName $target -Force
}

$rootPages = Get-ChildItem $site -Filter 'עמוד-*.html' -File | Sort-Object Name
$topicPages = Get-ChildItem (Join-Path $site 'worksheets') -Recurse -File -Filter 'page-*.html' -ErrorAction SilentlyContinue | Sort-Object FullName

$rootLinks = ($rootPages | ForEach-Object { "<li><a href='$($_.Name)'>$($_.Name)</a></li>" }) -join "`n"
$topicLinks = ($topicPages | ForEach-Object {
  $rel = $_.FullName.Substring($site.Length).TrimStart('\').Replace('\','/')
  "<li><a href='$rel'>$rel</a></li>"
}) -join "`n"

@"
<!DOCTYPE html>
<html lang='he' dir='rtl'>
<head>
<meta charset='utf-8'>
<meta name='viewport' content='width=device-width, initial-scale=1.0'>
<title>parabula2</title>
<link rel='stylesheet' href='styles/worksheet.css'>
</head>
<body>
<main class='a4-page'>
<header class='worksheet-header'>
<h1 class='page-title'>parabula2</h1>
<div class='page-number'>1</div>
</header>
<section class='questions'>
<div class='question'><span class='q-bullet'></span><div>דפי שורש</div></div>
<ul>
$rootLinks
</ul>
<div class='question'><span class='q-bullet'></span><div>דפי דלתון שנוצרו אוטומטית</div></div>
<ul>
$topicLinks
</ul>
</section>
</main>
</body>
</html>
"@ | Set-Content (Join-Path $site 'index.html') -Encoding utf8

'' | Set-Content (Join-Path $site '.nojekyll') -Encoding utf8
Write-Host ("site built. root pages: " + $rootPages.Count + " | worksheet pages: " + $topicPages.Count) -ForegroundColor Green
EOF

cat > tests/deltoid-pages.test.mjs <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("deltoid generated pages exist", () => {
  const dir = path.join("worksheets", "deltoid", "pages");
  const files = fs.readdirSync(dir).filter(x => /^page-\d+\.html$/i.test(x));
  assert.ok(files.length >= 1, "Expected generated deltoid pages");
});

test("deltoid manifest exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets", "deltoid", "pages", "manifest.json")), true);
});
EOF

if ! grep -q "Preview must include generated worksheet topic pages" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Preview must include generated worksheet topic pages

- `/preview` must include generated worksheet pages under `worksheets/**/pages/page-*.html`
- `api/toc` must expose both root worksheet pages and generated topic pages
- `site/` build must copy generated topic pages as publishable output
EOF
fi

if ! grep -q "preview חייב לכלול גם דפי worksheets" RULES.md; then
cat >> RULES.md <<'EOF'

---

## preview חייב לכלול גם דפי worksheets

- התצוגה המקדימה חייבת להראות גם דפים שנוצרו תחת:
  `worksheets/**/pages/page-*.html`
- build ל־site חייב להעתיק גם אותם
- אסור שדפי עבודה שנוצרו יישארו מנותקים מהתצוגה ומהפרסום
EOF
fi

npm test | tee deltoid_preview_integration_test_output.txt

{
  echo "# Deltoid preview integration report"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## generated pages"
  find worksheets/deltoid/pages -maxdepth 1 -type f | sort
  echo
  echo "## npm test"
  cat deltoid_preview_integration_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add preview/server.mjs preview/app.mjs tools/build-site.ps1 tests/deltoid-pages.test.mjs PROJECT_RULES.md RULES.md deltoid_preview_integration_test_output.txt "$REPORT"
git commit -m "feat: integrate generated deltoid pages into preview and site build"
git push

echo
echo "DONE"
echo "REPORT: $REPORT"
