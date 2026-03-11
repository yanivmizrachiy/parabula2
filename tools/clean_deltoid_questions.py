from __future__ import annotations
import json, re
from pathlib import Path

src = Path("worksheets/deltoid/extracted/questions.json")
dst = Path("worksheets/deltoid/extracted/questions.cleaned.json")

data = json.loads(src.read_text(encoding="utf-8"))

raw_questions = data.get("questions", [])
cleaned = []
seen = set()

for i, item in enumerate(raw_questions, start=1):
    if isinstance(item, str):
        text = item
        page = None
    else:
        text = str(item.get("text", "")).strip()
        page = item.get("source_page")

    text = re.sub(r"\s+", " ", text).strip()
    if len(text) < 12:
        continue
    if text in seen:
        continue
    seen.add(text)

    cleaned.append({
        "id": f"deltoid-clean-{len(cleaned)+1:03d}",
        "source_page": page,
        "text": text,
        "status": "cleaned_from_source",
        "approved": False
    })

payload = {
    "topic": "דלתון",
    "grade": "ט",
    "source": "sources/geometry/deltoid/source.pdf",
    "status": "cleaned_not_yet_typeset",
    "question_count": len(cleaned),
    "questions": cleaned
}

dst.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
print(len(cleaned))
