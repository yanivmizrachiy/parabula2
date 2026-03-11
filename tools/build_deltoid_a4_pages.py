from __future__ import annotations
import json
import re
from pathlib import Path

SRC = Path("worksheets/deltoid/extracted/questions.cleaned.json")
OUT_DIR = Path("worksheets/deltoid/pages")
OUT_DIR.mkdir(parents=True, exist_ok=True)

data = json.loads(SRC.read_text(encoding="utf-8"))
questions = data.get("questions", [])

clean_questions = []
for q in questions:
    text = str(q.get("text", "")).strip()
    text = re.sub(r"\s+", " ", text).strip()
    if len(text) >= 8:
        clean_questions.append({
            "id": q.get("id", ""),
            "source_page": q.get("source_page"),
            "text": text
        })

MAX_PER_PAGE = 8
chunks = [clean_questions[i:i+MAX_PER_PAGE] for i in range(0, len(clean_questions), MAX_PER_PAGE)]
if not chunks:
    chunks = [[]]

total_pages = len(chunks)
css_path = "../../../styles/worksheet.css"

for idx, chunk in enumerate(chunks, start=1):
    html_lines = []
    html_lines.append("<!DOCTYPE html>")
    html_lines.append('<html lang="he" dir="rtl">')
    html_lines.append("<head>")
    html_lines.append('  <meta charset="utf-8">')
    html_lines.append('  <meta name="viewport" content="width=device-width, initial-scale=1.0">')
    html_lines.append(f"  <title>דלתון — דף {idx}</title>")
    html_lines.append(f'  <link rel="stylesheet" href="{css_path}">')
    html_lines.append('  <script defer src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>')
    html_lines.append("</head>")
    html_lines.append("<body>")
    html_lines.append('  <main class="a4-page">')
    html_lines.append('    <header class="worksheet-header">')
    html_lines.append(f'      <h1 class="page-title">דלתון — דף עבודה {idx}</h1>')
    html_lines.append(f'      <div class="page-number">{idx}</div>')
    html_lines.append("    </header>")
    html_lines.append('    <section class="questions">')

    for q in chunk:
        source_page = q.get("source_page")
        source_meta = f" | מקור עמוד {source_page}" if source_page else ""
        html_lines.append('      <div class="question">')
        html_lines.append('        <span class="q-bullet"></span>')
        html_lines.append('        <div>')
        html_lines.append(f'          <div>{q["text"]}</div>')
        html_lines.append(f'          <div class="source-meta">{q.get("id","")}{source_meta}</div>')
        html_lines.append("        </div>")
        html_lines.append("      </div>")

    html_lines.append("    </section>")
    html_lines.append("  </main>")
    html_lines.append("</body>")
    html_lines.append("</html>")

    out_file = OUT_DIR / f"page-{idx:02d}.html"
    out_file.write_text("\n".join(html_lines) + "\n", encoding="utf-8")

manifest = {
    "topic": "דלתון",
    "source": "sources/geometry/deltoid/source.pdf",
    "input": "worksheets/deltoid/extracted/questions.cleaned.json",
    "page_count": total_pages,
    "question_count": len(clean_questions),
    "pages": [f"worksheets/deltoid/pages/page-{i:02d}.html" for i in range(1, total_pages + 1)],
    "status": "a4_pages_generated_from_cleaned_source"
}

(Path("worksheets/deltoid/pages/manifest.json")).write_text(
    json.dumps(manifest, ensure_ascii=False, indent=2),
    encoding="utf-8"
)

print(json.dumps(manifest, ensure_ascii=False, indent=2))
