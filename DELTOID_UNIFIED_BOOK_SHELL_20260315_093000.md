# Deltoid unified book shell build

- time: 2026-03-15T09:30:02+02:00

## unified shell summary
{
  "project": "parabula2",
  "topic": "דלתון",
  "title": "ספר דלתון — מעטפת מאוחדת",
  "chapter_count": 3,
  "chapters": [
    {
      "id": "chapter_01_done_pages",
      "title": "פרק 1 — עמודים מטופלים",
      "index": "worksheets/deltoid/chapters/chapter_01_done_pages/index.html",
      "book": "worksheets/deltoid/chapters/chapter_01_done_pages/chapter-book.html",
      "description": "עמודים 9, 38, 41, 42, 56 שכבר טופלו והפכו לבסיס האיכותי של הספר."
    },
    {
      "id": "chapter_02_vector_next",
      "title": "פרק 2 — vector-next",
      "index": "worksheets/deltoid/chapters/chapter_02_vector_next/index.html",
      "book": "worksheets/deltoid/chapters/chapter_02_vector_next/chapter-book.html",
      "description": "עמודים בעלי ערך גיאומטרי גבוה שהוגדרו כשלב הבא לשחזור שיטתי."
    },
    {
      "id": "chapter_03_image_first",
      "title": "פרק 3 — image-first",
      "index": "worksheets/deltoid/chapters/chapter_03_image_first/index.html",
      "book": "worksheets/deltoid/chapters/chapter_03_image_first/chapter-book.html",
      "description": "עמודים גרפיים חזקים שנעטפו בגישת image-first כדי לסגור מהר חלק גדול מהספר."
    }
  ]
}
## tests

> test
> node --test

[32m✔ book inventory json exists [90m(1.570833ms)[39m[39m
[32m✔ book status markdown exists [90m(0.140729ms)[39m[39m
[32m✔ all 60 page text files exist [90m(0.548333ms)[39m[39m
[32m✔ inventory page count is 60 [90m(2.04875ms)[39m[39m
[32m✔ chapter manifest exists [90m(6.148021ms)[39m[39m
[32m✔ chapter index exists [90m(0.721771ms)[39m[39m
[32m✔ chapter book exists [90m(1.084063ms)[39m[39m
[32m✔ chapter contains 5 wrapped pages [90m(1.274063ms)[39m[39m
[32m✔ chapter manifest page count is 5 [90m(16.778698ms)[39m[39m
[32m✔ chapter 02 manifest exists [90m(2.935365ms)[39m[39m
[32m✔ chapter 02 index exists [90m(0.307917ms)[39m[39m
[32m✔ chapter 02 book exists [90m(0.279739ms)[39m[39m
[32m✔ chapter 02 contains wrapped pages [90m(0.68375ms)[39m[39m
[32m✔ chapter 02 manifest has vector-next bucket [90m(24.817708ms)[39m[39m
[32m✔ chapter 03 manifest exists [90m(2.892188ms)[39m[39m
[32m✔ chapter 03 index exists [90m(0.312969ms)[39m[39m
[32m✔ chapter 03 book exists [90m(0.307292ms)[39m[39m
[32m✔ chapter 03 contains wrapped pages [90m(0.718021ms)[39m[39m
[32m✔ chapter 03 manifest has image-first-next bucket [90m(10.358385ms)[39m[39m
[32m✔ graphics analysis file exists [90m(3.090573ms)[39m[39m
[32m✔ at least one enhanced page exists [90m(0.82401ms)[39m[39m
[32m✔ exact deltoid html pages exist [90m(3.455834ms)[39m[39m
[32m✔ exact deltoid png assets exist [90m(0.652344ms)[39m[39m
[32m✔ exact deltoid manifest exists [90m(0.324532ms)[39m[39m
[32m✔ exact deltoid png assets exist [90m(1.879427ms)[39m[39m
[32m✔ exact deltoid html pages exist [90m(0.319323ms)[39m[39m
[32m✔ exact deltoid manifest exists [90m(0.254375ms)[39m[39m
[32m✔ graphics status json exists [90m(3.049323ms)[39m[39m
[32m✔ vector qa markdown exists [90m(0.747969ms)[39m[39m
[32m✔ page 56 inspection assets exist [90m(0.991823ms)[39m[39m
[32m✔ image inventory json exists [90m(1.528333ms)[39m[39m
[32m✔ image gallery exists [90m(0.147552ms)[39m[39m
[32m✔ all 60 page images exist [90m(0.440416ms)[39m[39m
[32m✔ all 60 thumbnails exist [90m(0.236355ms)[39m[39m
[32m✔ normalized rebuild plan json exists [90m(3.286667ms)[39m[39m
[32m✔ normalized rebuild plan markdown exists [90m(0.160989ms)[39m[39m
[32m✔ normalized rebuild plan html exists [90m(0.139739ms)[39m[39m
[32m✔ normalized rebuild plan contains 60 records [90m(7.855156ms)[39m[39m
[32m✔ normalized rebuild plan has done bucket [90m(0.445677ms)[39m[39m
[32m✔ page 38 vector svg exists [90m(3.94625ms)[39m[39m
[32m✔ page 38 vector html exists [90m(0.304375ms)[39m[39m
[32m✔ page 38 vector html has no inline style [90m(0.805312ms)[39m[39m
[32m✔ page 41 inspection assets exist [90m(2.82625ms)[39m[39m
[32m✔ page 41 precise vector svg exists [90m(3.367292ms)[39m[39m
[32m✔ page 41 precise vector html exists [90m(0.325833ms)[39m[39m
[32m✔ page 41 precise vector html has no inline style [90m(3.58901ms)[39m[39m
[32m✔ page 42 enhanced asset exists [90m(2.779062ms)[39m[39m
[32m✔ page 42 html points to enhanced asset [90m(1.947865ms)[39m[39m
[32m✔ page 56 precise vector svg exists [90m(2.780834ms)[39m[39m
[32m✔ page 56 precise vector html exists [90m(0.273802ms)[39m[39m
[32m✔ page 56 precise vector html has no inline style [90m(0.787968ms)[39m[39m
[32m✔ page 9 enhanced asset exists [90m(6.188177ms)[39m[39m
[32m✔ page 9 html points to enhanced asset [90m(3.348802ms)[39m[39m
[32m✔ deltoid generated pages exist [90m(6.61901ms)[39m[39m
[32m✔ deltoid manifest exists [90m(0.53125ms)[39m[39m
[32m✔ graphics status json exists [90m(1.536407ms)[39m[39m
[32m✔ vector qa markdown exists [90m(0.13ms)[39m[39m
[32m✔ page 56 inspection assets exist [90m(0.166615ms)[39m[39m
[32m✔ exact page count is 60 [90m(0.379583ms)[39m[39m
[32m✔ all vector html files have no inline style [90m(1.627239ms)[39m[39m
[32m✔ unified book shell json exists [90m(1.733907ms)[39m[39m
[32m✔ unified book index exists [90m(0.145052ms)[39m[39m
[32m✔ unified book page exists [90m(0.1275ms)[39m[39m
[32m✔ unified book theme exists [90m(0.111406ms)[39m[39m
[32m✔ unified book has 3 chapters [90m(0.217969ms)[39m[39m
[32m✔ visual page map json exists [90m(1.518282ms)[39m[39m
[32m✔ visual page map markdown exists [90m(0.16849ms)[39m[39m
[32m✔ visual map html exists [90m(0.115208ms)[39m[39m
[32m✔ visual page map contains 60 records [90m(12.002448ms)[39m[39m
page 42 vector files exist ✓
[32m✔ tests/page42-vector.test.mjs [90m(255.10276ms)[39m[39m
[32m✔ at least 10 worksheet pages exist [90m(1.613229ms)[39m[39m
[32m✔ rules files exist [90m(1.429791ms)[39m[39m
[34mℹ tests 72[39m
[34mℹ suites 0[39m
[34mℹ pass 72[39m
[34mℹ fail 0[39m
[34mℹ cancelled 0[39m
[34mℹ skipped 0[39m
[34mℹ todo 0[39m
[34mℹ duration_ms 1147.08224[39m

## git status
 M PROJECT_RULES.md
 M RULES.md
 M tests/page42-vector.test.mjs
 M worksheets/deltoid/VECTOR_QA.md
 D worksheets/deltoid/exact_pages/page-09-vector.html
 M worksheets/deltoid/graphics-status.json
?? DELTOID_UNIFIED_BOOK_SHELL_20260315_093000.md
?? analysis/
?? deltoid_unified_book_shell_test_output.txt
?? tests/deltoid-unified-book-shell.test.mjs
?? tools/advance_deltoid_graphics_system.sh
?? tools/advance_deltoid_graphics_system_fix.sh
?? tools/build_deltoid_book_inventory.sh
?? tools/build_deltoid_chapter01_done_pages.sh
?? tools/build_deltoid_chapter02_vector_next.sh
?? tools/build_deltoid_chapter03_image_first.sh
?? tools/build_deltoid_image_inventory.sh
?? tools/build_deltoid_normalized_rebuild_plan.sh
?? tools/build_deltoid_unified_book_shell.sh
?? tools/build_deltoid_visual_page_map.sh
?? tools/inspect_page41_deep.sh
?? tools/power_upgrade_deltoid_repo.sh
?? tools/rebuild_deltoid_page41_svg_precise.sh
?? tools/rebuild_deltoid_page56_svg_precise.sh
?? tools/smart_cleanup_and_page56_inspect.sh
?? tools/vector_precision/
?? worksheets/deltoid/questions_catalog/
?? worksheets/deltoid/unified_book/
