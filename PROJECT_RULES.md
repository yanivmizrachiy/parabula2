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


## Source material

מקור החומר לדפי העבודה בנושא דלתון:

sources/geometry/deltoid/source.pdf


---

## Deltoid cleaning stage

- לאחר חילוץ ראשוני מ-PDF יש ליצור קובץ ניקוי: `worksheets/deltoid/extracted/questions.cleaned.json`
- רק ממנו מותר להתקדם לשלב בניית דפי A4
- אין לבנות דפים ישירות מ־`questions.json` הגולמי

---

## Deltoid A4 generation contract

- דפי A4 בנושא דלתון נוצרים אך ורק מתוך:
  `worksheets/deltoid/extracted/questions.cleaned.json`
- הדפים נשמרים תחת:
  `worksheets/deltoid/pages/`
- כל דף חייב להכיל רק תוכן שמבוסס על מקור דלתון שנשמר בריפו.
- כל page generation חייב לעדכן גם manifest.
- אין לקדם דפים אלו לשלב פרסום סופי בלי בדיקה אנושית של התוכן שחולץ.

---

## Preview must include generated worksheet topic pages

- `/preview` must include generated worksheet pages under `worksheets/**/pages/page-*.html`
- `api/toc` must expose both root worksheet pages and generated topic pages
- `site/` build must copy generated topic pages as publishable output

---

## Deltoid exact facsimile contract

- כאשר נדרש דיוק מלא של השרטוטים והציורים, מותר ליצור עמודי facsimile מדויקים מתוך:
  `sources/geometry/deltoid/source.pdf`
- הפלט נשמר תחת:
  `worksheets/deltoid/exact_pages/`
- נכסי התמונה המדויקים נשמרים תחת:
  `worksheets/deltoid/exact_assets/`
- במצב זה אין לבצע שחזור ידני של השרטוטים; שומרים את עמוד המקור בדיוק חזותי מלא.
- גם במצב זה HTML חייב להישאר ללא style inline, והעיצוב חייב להישען על CSS חיצוני בלבד.

---

## Exact facsimile pages must be visible in preview and publish output

- כל דפי exact תחת `worksheets/**/exact_pages/` או `worksheets/**/pages/` חייבים להיות זמינים ב־`/preview`
- `api/toc` חייב לכלול גם דפי exact
- build של `site/` חייב להעתיק גם דפי exact וגם נכסי PNG נלווים

---

## Page 9 deep enhancement

- עמוד 9 של דלתון עבר extraction מחדש ברזולוציה גבוהה יותר ושיפור חזותי ייעודי.
- הקבצים:
  - `worksheets/deltoid/exact_assets/page-09-hires.png`
  - `worksheets/deltoid/exact_assets/page-09-enhanced.png`
- `worksheets/deltoid/exact_pages/page-09.html` חייב להצביע לגרסה המשופרת.
- זהו שיפור חזותי מבוסס מקור, לא שרטוט SVG חדש.

---

## Deep graphics upgrade for low-DPI source pages

- כאשר עמודי מקור ב-PDF מכילים שרטוטים ברזולוציה נמוכה, מותר לבצע extraction מחדש ב-DPI גבוה יותר וליצור:
  `page-XX-enhanced.png`
- דפי exact הרלוונטיים חייבים להצביע לקובץ המשופר.
- זהו שיפור חזותי מבוסס מקור, לא שרטוט SVG חדש.
- יש לשמור דוח ניתוח שמסמן אילו עמודים הוגדרו low-DPI ואילו שופרו.

---

## Page 38 vector rebuild

- עמוד 38 של דלתון נבנה גם בגרסה וקטורית תחת:
  `worksheets/deltoid/vector_pages/page-38.html`
- השרטוט נשמר תחת:
  `worksheets/deltoid/vector_assets/deltoid_page38.svg`
- גרסה זו מיועדת לשיפור חדות גיאומטרית מעבר לאיכות המקור
- גם כאן אין להשתמש ב-inline CSS בתוך HTML

---

## Page 42 deep enhancement

- עמוד 42 של דלתון עבר extraction מחדש ברזולוציה גבוהה ושיפור חזותי ייעודי.
- הקבצים:
  - `worksheets/deltoid/exact_assets/page-42-enhanced.png`
  - `worksheets/deltoid/exact_pages/page-42.html`
- זהו שיפור חזותי מבוסס מקור, לא שרטוט SVG חדש.

---

## Graphics status registry

- כל מצב גרפי של דפי דלתון חייב להירשם בקובץ:
  `worksheets/deltoid/graphics-status.json`
- לכל עמוד חייב להיות state ברור:
  `exact` / `enhanced` / `vector`
- עמודים מועמדים לשדרוג חייבים להופיע גם ב:
  `worksheets/deltoid/VECTOR_QA.md`
- כל שיפור גרפי משמעותי חייב לעדכן את שני הקבצים.

---

## Exact pages count integrity

- דפי exact תחת `worksheets/deltoid/exact_pages/` חייבים לייצג את דפי המקור בלבד.
- הספירה הצפויה לקובץ הדלתון היא 60 עמודים.
- דפי vector אינם נספרים כ-exact pages.
- כל שינוי במצב הגרפי חייב לעדכן את:
  `worksheets/deltoid/graphics-status.json`

---

## Page 56 precise vector rebuild

- עמוד 56 נבנה מחדש על בסיס השרטוט האמיתי מהמקור:
  ריבוע ABCD, נקודה E על AD, נקודה F על DB, הקטעים EB ו-FB, ונתון EF ⟂ DB.
- גרסת הווקטור נשמרת תחת:
  `worksheets/deltoid/vector_pages/page-56-vector.html`
- השרטוט נשמר תחת:
  `worksheets/deltoid/vector_assets/deltoid_page56_precise.svg`

---

## Page 41 precise vector rebuild

- עמוד 41 נבנה מחדש על בסיס השרטוט האמיתי מהמקור:
  משולש שווה־שוקיים ABC, התיכון AD לצלע BC, והנקודה E על המשך AD.
- גרסת הווקטור נשמרת תחת:
  `worksheets/deltoid/vector_pages/page-41-vector.html`
- השרטוט נשמר תחת:
  `worksheets/deltoid/vector_assets/deltoid_page41_precise.svg`

---

## Deltoid book inventory

- יש לשמור inventory מלא של הספר תחת:
  `worksheets/deltoid/book_inventory/`
- לכל עמוד חייבים להיות:
  - raw text
  - clean text
  - meta json
- inventory זה הוא בסיס העבודה לבניית ספר אחיד חדש
