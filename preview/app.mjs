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
