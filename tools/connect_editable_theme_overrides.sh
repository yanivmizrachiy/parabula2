#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

REPORT="DELTOID_THEME_OVERRIDES_$(date +%Y%m%d_%H%M%S).md"
OUT_DIR="worksheets/deltoid/editable_book"
CONFIG_DIR="$OUT_DIR/config"
ASSETS_DIR="$OUT_DIR/assets"
THEME_JSON="$CONFIG_DIR/theme.json"
GEN_CSS="$ASSETS_DIR/theme.generated.css"
EDITABLE_INDEX="$OUT_DIR/editable-index.html"
EDITABLE_BOOK="$OUT_DIR/editable-book.html"
TEST_FILE="tests/deltoid-theme-overrides.test.mjs"

mkdir -p "$CONFIG_DIR" "$ASSETS_DIR" tests tools

python - <<'PYEOF'
from __future__ import annotations
import json
from pathlib import Path

out_dir = Path("worksheets/deltoid/editable_book")
config_dir = out_dir / "config"
assets_dir = out_dir / "assets"
theme_json = config_dir / "theme.json"
gen_css = assets_dir / "theme.generated.css"
editable_index = out_dir / "editable-index.html"
editable_book = out_dir / "editable-book.html"

if not theme_json.exists():
    theme = {
        "direction": "rtl",
        "language": "he",
        "font_family": "Arial, sans-serif",
        "title_font_size": "34px",
        "section_font_size": "24px",
        "body_font_size": "16px",
        "line_height": "1.75",
        "page_background": "#f4f7fb",
        "card_background": "#ffffff",
        "primary_color": "#1d4ed8",
        "primary_dark": "#173b8f",
        "accent_color": "#4f8df7",
        "text_color": "#0f172a",
        "muted_color": "#475569",
        "border_color": "#dbe4ee",
        "radius": "22px",
        "shadow": "0 12px 30px rgba(15,23,42,.08)"
    }
    theme_json.write_text(json.dumps(theme, ensure_ascii=False, indent=2), encoding="utf-8")
else:
    theme = json.loads(theme_json.read_text(encoding="utf-8"))

css = f"""
:root{{
  --bg:{theme.get("page_background","#f4f7fb")};
  --card:{theme.get("card_background","#ffffff")};
  --text:{theme.get("text_color","#0f172a")};
  --muted:{theme.get("muted_color","#475569")};
  --line:{theme.get("border_color","#dbe4ee")};
  --blue:{theme.get("primary_color","#1d4ed8")};
  --blue-dark:{theme.get("primary_dark","#173b8f")};
  --accent:{theme.get("accent_color","#4f8df7")};
  --radius:{theme.get("radius","22px")};
  --shadow:{theme.get("shadow","0 12px 30px rgba(15,23,42,.08)")};
  --font-main:{theme.get("font_family","Arial, sans-serif")};
  --title-size:{theme.get("title_font_size","34px")};
  --section-size:{theme.get("section_font_size","24px")};
  --body-size:{theme.get("body_font_size","16px")};
  --line-height:{theme.get("line_height","1.75")};
}}
body{{
  direction:{theme.get("direction","rtl")};
  margin:0;
  font-family:var(--font-main);
  background:linear-gradient(180deg,#eef4fb 0%,var(--bg) 100%);
  color:var(--text);
  font-size:var(--body-size);
  line-height:var(--line-height);
}}
.shell{{
  max-width:1280px;
  margin:0 auto;
  padding:24px 16px 48px;
}}
.hero{{
  background:linear-gradient(135deg,var(--blue-dark) 0%,var(--blue) 55%,var(--accent) 100%);
  color:#fff;
  border-radius:28px;
  padding:28px 22px;
  box-shadow:var(--shadow);
}}
.hero h1{{margin:0 0 10px 0;font-size:var(--title-size)}}
.hero p{{margin:0;opacity:.96}}
.toolbar{{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(220px,1fr));
  gap:14px;
  margin-top:20px;
}}
.tool{{
  background:rgba(255,255,255,.14);
  border:1px solid rgba(255,255,255,.18);
  border-radius:18px;
  padding:14px;
}}
.tool .label{{font-size:13px;opacity:.9}}
.tool .value{{font-size:18px;font-weight:700;margin-top:6px}}
.section-title{{margin:28px 0 16px;font-size:var(--section-size)}}
.grid{{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(300px,1fr));
  gap:18px;
}}
.card{{
  background:var(--card);
  border:1px solid var(--line);
  border-radius:var(--radius);
  padding:18px;
  box-shadow:var(--shadow);
}}
.card h2{{margin:0 0 10px 0;font-size:20px}}
.card p{{margin:0 0 14px 0;color:var(--muted)}}
.actions{{display:flex;flex-wrap:wrap;gap:10px}}
.btn{{
  display:inline-flex;
  align-items:center;
  justify-content:center;
  min-height:42px;
  padding:0 14px;
  border-radius:14px;
  text-decoration:none;
  font-weight:700;
  border:1px solid transparent;
}}
.btn-primary{{background:var(--blue);color:#fff}}
.btn-secondary{{background:#fff;color:var(--blue);border-color:#bfdbfe}}
.config, .frame-wrap{{
  margin-top:26px;
  background:#fff;
  border:1px solid var(--line);
  border-radius:26px;
  box-shadow:var(--shadow);
  padding:18px;
}}
pre{{
  margin:0;
  white-space:pre-wrap;
  word-break:break-word;
  font-size:13px;
  line-height:1.7;
  color:#0f172a;
}}
.note{{margin-top:18px;color:var(--muted);font-size:14px}}
iframe{{
  width:100%;
  height:78vh;
  border:0;
  display:block;
  border-radius:18px;
  background:#fff;
}}
@media (max-width:700px){{
  .hero h1{{font-size:28px}}
  iframe{{height:68vh}}
}}
""".strip() + "\n"

gen_css.write_text(css, encoding="utf-8")

def ensure_link(path: Path):
    if not path.exists():
        return
    html = path.read_text(encoding="utf-8")
    if 'theme.generated.css' not in html:
        html = html.replace(
            '</head>',
            '  <link rel="stylesheet" href="assets/theme.generated.css">\n</head>'
        )
    path.write_text(html, encoding="utf-8")

ensure_link(editable_index)
ensure_link(editable_book)

print(json.dumps({
    "theme_json": str(theme_json),
    "generated_css": str(gen_css),
    "editable_index": str(editable_index),
    "editable_book": str(editable_book)
}, ensure_ascii=False, indent=2))
PYEOF

cat > "$TEST_FILE" <<'EOF'
import test from "node:test";
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";

test("theme json exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","editable_book","config","theme.json")), true);
});

test("generated theme css exists", () => {
  assert.equal(fs.existsSync(path.join("worksheets","deltoid","editable_book","assets","theme.generated.css")), true);
});

test("editable index links generated theme", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","editable_book","editable-index.html"), "utf8");
  assert.ok(html.includes("theme.generated.css"));
});

test("editable book links generated theme", () => {
  const html = fs.readFileSync(path.join("worksheets","deltoid","editable_book","editable-book.html"), "utf8");
  assert.ok(html.includes("theme.generated.css"));
});
EOF

if ! grep -q "Deltoid theme overrides" PROJECT_RULES.md; then
cat >> PROJECT_RULES.md <<'EOF'

---

## Deltoid theme overrides

- יש לקשר את editable_book ל-theme.json כ-source of truth
- יש לייצר:
  `worksheets/deltoid/editable_book/assets/theme.generated.css`
- editable-index.html ו-editable-book.html חייבים לטעון את theme.generated.css
EOF
fi

if ! grep -q "חיבור theme overrides לדלתון" RULES.md; then
cat >> RULES.md <<'EOF'

---

## חיבור theme overrides לדלתון

- אחרי editable shell חייב להיות חיבור אמיתי בין theme.json לבין CSS מחולל
- שינוי עתידי בעיצוב יעבור דרך theme.json
EOF
fi

npm test | tee deltoid_theme_overrides_test_output.txt

{
  echo "# Deltoid theme overrides build"
  echo
  echo "- time: $(date -Iseconds)"
  echo
  echo "## theme summary"
  cat "$THEME_JSON"
  echo
  echo "## generated css"
  cat "$GEN_CSS"
  echo
  echo "## tests"
  cat deltoid_theme_overrides_test_output.txt
  echo
  echo "## git status"
  git status --short
} > "$REPORT"

git add "$OUT_DIR" "$TEST_FILE" PROJECT_RULES.md RULES.md deltoid_theme_overrides_test_output.txt "$REPORT"

if ! git diff --cached --quiet; then
  git commit -m "feat: connect editable theme overrides for deltoid book"
  git push
fi

echo
echo "DONE"
echo "REPORT: $REPORT"
echo "EDITABLE INDEX: $EDITABLE_INDEX"
echo "NEXT HIGH PRIORITY: tune deltoid visuals from theme source of truth"
