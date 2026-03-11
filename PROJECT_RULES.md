# PROJECT_RULES — Parabula2 (Single Source of Truth)

This repository is a self-validating, RTL-first A4 worksheet engine.

## 0) Ground Truth
- Every printable worksheet page must preserve true A4 integrity.
- RTL Hebrew is the default language and direction.
- No inline CSS anywhere in worksheet pages.
- No inline JavaScript anywhere in worksheet pages.
- Styling must live in dedicated CSS files only.
- Preview behavior must be controlled by external files, not inline HTML injections.

## A4 Contract
- Printable pages must be designed for true A4 output.
- Avoid unintended blank regions.
- Avoid overflow hacks.
- Free-writing zones must expand intelligently inside the available A4 space.

## Preview Contract
- `/preview` is the canonical reading environment.
- Preview must feel like a real textbook reader.
- Pages must be centered.
- The page must begin from the top of the reading area.
- The preview must never show a blank reading area when valid pages exist.
- If state becomes invalid, the system must fall back to the first valid page.
- Centering and scaling are handled exclusively via `styles/preview.css`.

## HTML/CSS Separation
- No `<style>` blocks inside worksheet pages.
- No `style=""` attributes inside worksheet pages.
- No inline preview hotfixes inside HTML.

## Math
- Use MathJax.
- Inline math: `\( ... \)`
- Display math: `$$ ... $$`

## SVG
- Use SVG for mathematical and geometric diagrams.
- Prefer vector assets over raster images.

## Publish Contract
- Output is built into `site/`.
- Before deployment, confirm that `site/` contains the expected textbook pages.
