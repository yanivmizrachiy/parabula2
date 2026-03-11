import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "..");
const host = process.env.HOST || "127.0.0.1";
const port = Number(process.env.PORT || 5179);

function send(res, code, body, type="text/plain; charset=utf-8"){
  res.writeHead(code, { "Content-Type": type });
  res.end(body);
}

function fileList() {
  return fs.readdirSync(repoRoot, { withFileTypes: true })
    .filter(d => d.isFile() && /^עמוד-\d+\.html$/u.test(d.name))
    .map(d => d.name)
    .sort((a,b) => a.localeCompare(b, "he", { numeric:true }));
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  if (url.pathname === "/" || url.pathname === "/preview") {
    const html = fs.readFileSync(path.join(repoRoot, "preview", "index.html"), "utf8");
    return send(res, 200, html, "text/html; charset=utf-8");
  }
  if (url.pathname === "/preview/app.mjs") {
    return send(res, 200, fs.readFileSync(path.join(repoRoot, "preview", "app.mjs"), "utf8"), "text/javascript; charset=utf-8");
  }
  if (url.pathname === "/api/toc") {
    return send(res, 200, JSON.stringify({ files: fileList() }), "application/json; charset=utf-8");
  }
  const target = path.join(repoRoot, decodeURIComponent(url.pathname.replace(/^\/+/, "")));
  if (!target.startsWith(repoRoot)) return send(res, 403, "Forbidden");
  if (fs.existsSync(target) && fs.statSync(target).isFile()) {
    const ext = path.extname(target).toLowerCase();
    const type = ext === ".html" ? "text/html; charset=utf-8" : ext === ".css" ? "text/css; charset=utf-8" : "text/plain; charset=utf-8";
    return send(res, 200, fs.readFileSync(target, "utf8"), type);
  }
  return send(res, 404, "Not found");
});

server.listen(port, host, () => {
  console.log(`Preview server running: http://${host}:${port}/preview`);
});
