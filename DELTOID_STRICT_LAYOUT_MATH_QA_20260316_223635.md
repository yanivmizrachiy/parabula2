# Deltoid strict layout and math QA

- time: 2026-03-16T22:36:45+02:00

## tests

> test
> node --test

[32m✔ book inventory json exists [90m(1.674635ms)[39m[39m
[32m✔ book status markdown exists [90m(0.179636ms)[39m[39m
[32m✔ all 60 page text files exist [90m(0.545052ms)[39m[39m
[32m✔ inventory page count is 60 [90m(0.40625ms)[39m[39m
[32m✔ chapter manifest exists [90m(1.71875ms)[39m[39m
[32m✔ chapter index exists [90m(0.166614ms)[39m[39m
[32m✔ chapter book exists [90m(0.158333ms)[39m[39m
[32m✔ chapter contains 5 wrapped pages [90m(0.359271ms)[39m[39m
[32m✔ chapter manifest page count is 5 [90m(0.594375ms)[39m[39m
[32m✔ chapter 02 manifest exists [90m(5.780833ms)[39m[39m
[32m✔ chapter 02 index exists [90m(0.321875ms)[39m[39m
[32m✔ chapter 02 book exists [90m(0.595156ms)[39m[39m
[32m✔ chapter 02 contains wrapped pages [90m(1.76849ms)[39m[39m
[32m✔ chapter 02 manifest has vector-next bucket [90m(4.549479ms)[39m[39m
[32m✔ chapter 03 manifest exists [90m(7.63724ms)[39m[39m
[32m✔ chapter 03 index exists [90m(0.362344ms)[39m[39m
[32m✔ chapter 03 book exists [90m(1.096719ms)[39m[39m
[32m✔ chapter 03 contains wrapped pages [90m(0.74776ms)[39m[39m
[32m✔ chapter 03 manifest has image-first-next bucket [90m(11.778906ms)[39m[39m
[32m✔ graphics analysis file exists [90m(1.621198ms)[39m[39m
[32m✔ at least one enhanced page exists [90m(0.411041ms)[39m[39m
[32m✔ exact deltoid html pages exist [90m(1.921875ms)[39m[39m
[32m✔ exact deltoid png assets exist [90m(0.39224ms)[39m[39m
[32m✔ exact deltoid manifest exists [90m(0.246042ms)[39m[39m
[32m✔ exact deltoid png assets exist [90m(5.061667ms)[39m[39m
[32m✔ exact deltoid html pages exist [90m(0.615729ms)[39m[39m
[32m✔ exact deltoid manifest exists [90m(0.395364ms)[39m[39m
[32m✔ batch 01 audit json exists [90m(3.141459ms)[39m[39m
[32m✔ batch 01 audit report exists [90m(0.302864ms)[39m[39m
[32m✔ batch 01 audit has 5 records [90m(0.475625ms)[39m[39m
[32m✔ page 09 still has bullet layout and page number [90m(0.416094ms)[39m[39m
[32m✔ refined batch index exists [90m(3.114063ms)[39m[39m
[32m✔ refined batch manifest exists [90m(0.340625ms)[39m[39m
[32m✔ refined batch has 5 pages [90m(0.606562ms)[39m[39m
[32m✔ refined page keeps bullet layout and page number [90m(0.608593ms)[39m[39m
[32m✔ final batch 01 index exists [90m(1.682291ms)[39m[39m
[32m✔ final batch 01 manifest exists [90m(0.159479ms)[39m[39m
[32m✔ final batch 01 has 5 pages [90m(0.35474ms)[39m[39m
[32m✔ final page has blue page number and no numbered question labels [90m(0.354167ms)[39m[39m
[32m✔ batch 02 index exists [90m(5.247396ms)[39m[39m
[32m✔ batch 02 manifest exists [90m(0.312344ms)[39m[39m
[32m✔ batch 02 has 5 pages [90m(0.672709ms)[39m[39m
[32m✔ batch 03 repair manifest exists [90m(3.79375ms)[39m[39m
[32m✔ batch 03 repaired pages keep bullet layout and page number [90m(1.024687ms)[39m[39m
[32m✔ graphics status json exists [90m(3.085208ms)[39m[39m
[32m✔ vector qa markdown exists [90m(0.314896ms)[39m[39m
[32m✔ page 56 inspection assets exist [90m(0.599792ms)[39m[39m
[32m✔ image inventory json exists [90m(1.688178ms)[39m[39m
[32m✔ image gallery exists [90m(0.159948ms)[39m[39m
[32m✔ all 60 page images exist [90m(0.460938ms)[39m[39m
[32m✔ all 60 thumbnails exist [90m(0.287344ms)[39m[39m
[32m✔ normalized rebuild plan json exists [90m(2.974011ms)[39m[39m
[32m✔ normalized rebuild plan markdown exists [90m(0.197396ms)[39m[39m
[32m✔ normalized rebuild plan html exists [90m(0.956146ms)[39m[39m
[32m✔ normalized rebuild plan contains 60 records [90m(0.708698ms)[39m[39m
[32m✔ normalized rebuild plan has done bucket [90m(0.394635ms)[39m[39m
[32m✔ page 38 vector svg exists [90m(1.658385ms)[39m[39m
[32m✔ page 38 vector html exists [90m(0.160573ms)[39m[39m
[32m✔ page 38 vector html has no inline style [90m(0.219583ms)[39m[39m
[32m✔ page 41 inspection assets exist [90m(3.154167ms)[39m[39m
[32m✔ page 41 precise vector svg exists [90m(3.581511ms)[39m[39m
[32m✔ page 41 precise vector html exists [90m(0.290417ms)[39m[39m
[32m✔ page 41 precise vector html has no inline style [90m(0.435989ms)[39m[39m
[32m✔ page 42 enhanced asset exists [90m(4.008906ms)[39m[39m
[32m✔ page 42 html points to enhanced asset [90m(1.988907ms)[39m[39m
[32m✔ page 56 precise vector svg exists [90m(2.514948ms)[39m[39m
[32m✔ page 56 precise vector html exists [90m(0.302865ms)[39m[39m
[32m✔ page 56 precise vector html has no inline style [90m(0.441979ms)[39m[39m
[32m✔ page 9 enhanced asset exists [90m(5.43599ms)[39m[39m
[32m✔ page 9 html points to enhanced asset [90m(0.575572ms)[39m[39m
[32m✔ deltoid generated pages exist [90m(3.430208ms)[39m[39m
[32m✔ deltoid manifest exists [90m(0.966875ms)[39m[39m
[32m✔ precision lab json exists [90m(3.091354ms)[39m[39m
[32m✔ precision gallery exists [90m(0.319479ms)[39m[39m
[32m✔ precision lab source pages exist [90m(0.741146ms)[39m[39m
[32m✔ precision lab line maps exist [90m(0.37349ms)[39m[39m
[32m✔ rebuild v2 source_text dir exists [90m(2.960781ms)[39m[39m
[32m✔ rebuild v2 has 60 source text files [90m(0.723437ms)[39m[39m
[32m✔ content queue exists [90m(0.365156ms)[39m[39m
[32m✔ page 01 contains extracted source text block [90m(0.507917ms)[39m[39m
[32m✔ graphics status json exists [90m(1.685885ms)[39m[39m
[32m✔ vector qa markdown exists [90m(0.151615ms)[39m[39m
[32m✔ page 56 inspection assets exist [90m(0.187864ms)[39m[39m
[32m✔ exact page count is 60 [90m(0.433854ms)[39m[39m
[32m✔ all vector html files have no inline style [90m(0.507917ms)[39m[39m
[32m✔ strict qa tool exists [90m(2.161979ms)[39m[39m
[32m✔ theme json exists [90m(1.708021ms)[39m[39m
[32m✔ generated theme css exists [90m(0.199844ms)[39m[39m
[32m✔ editable index links generated theme [90m(0.268334ms)[39m[39m
[32m✔ editable book links generated theme [90m(0.145729ms)[39m[39m
[32m✔ unified book shell json exists [90m(2.052812ms)[39m[39m
[32m✔ unified book index exists [90m(0.192395ms)[39m[39m
[32m✔ unified book page exists [90m(0.151302ms)[39m[39m
[32m✔ unified book theme exists [90m(0.143906ms)[39m[39m
[32m✔ unified book has 3 chapters [90m(0.244792ms)[39m[39m
[32m✔ visual page map json exists [90m(3.123178ms)[39m[39m
[32m✔ visual page map markdown exists [90m(0.359479ms)[39m[39m
[32m✔ visual map html exists [90m(0.336094ms)[39m[39m
[32m✔ visual page map contains 60 records [90m(0.723698ms)[39m[39m
page 42 vector files exist ✓
[32m✔ tests/page42-vector.test.mjs [90m(145.553698ms)[39m[39m
[32m✔ at least 10 worksheet pages exist [90m(1.816406ms)[39m[39m
TEST OK
[32m✔ tests/rebuild_v2.test.mjs [90m(166.444062ms)[39m[39m
[32m✔ rules files exist [90m(1.550469ms)[39m[39m
[34mℹ tests 103[39m
[34mℹ suites 0[39m
[34mℹ pass 103[39m
[34mℹ fail 0[39m
[34mℹ cancelled 0[39m
[34mℹ skipped 0[39m
[34mℹ todo 0[39m
[34mℹ duration_ms 1427.846406[39m

## git status
 M deltoid_strict_layout_math_qa_test_output.txt
 M worksheets/deltoid/final_pages_batch_01/pages/page-09.html
 M worksheets/deltoid/final_pages_batch_01_refined/pages/page-09.html
 M worksheets/deltoid/final_pages_batch_02/pages/page-12.html
 M worksheets/deltoid/final_pages_batch_03/pages/page-15.html
 M worksheets/deltoid/final_pages_batch_03/pages/page-16.html
 M worksheets/deltoid/final_pages_batch_03/pages/page-17.html
 M worksheets/deltoid/final_pages_batch_03/pages/page-18.html
 M worksheets/deltoid/final_pages_batch_03/pages/page-19.html
 M worksheets/deltoid/pages/page-02.html
 M worksheets/deltoid/pages/page-03.html
 M worksheets/deltoid/pages/page-04.html
 M worksheets/deltoid/pages/page-05.html
 M worksheets/deltoid/pages/page-06.html
 M worksheets/deltoid/pages/page-08.html
 M worksheets/deltoid/rebuild_v2/pages/page-03.html
 M worksheets/deltoid/rebuild_v2/pages/page-06.html
 M worksheets/deltoid/rebuild_v2/pages/page-09.html
 M worksheets/deltoid/rebuild_v2/pages/page-12.html
 M worksheets/deltoid/rebuild_v2/pages/page-19.html
 M worksheets/deltoid/rebuild_v2/pages/page-20.html
 M worksheets/deltoid/rebuild_v2/pages/page-31.html
 M worksheets/deltoid/rebuild_v2/pages/page-52.html
?? DELTOID_STRICT_LAYOUT_MATH_QA_20260316_223635.md
?? analysis/
?? deltoid_batch_03_repair_test_output.txt
?? deltoid_pdf_analysis/
?? styles/deltoid-book.css
?? tests/deltoid-final-pages-batch-03-repair.test.mjs
?? tools/deltoid_auto_math_symbols.sh
?? worksheets/deltoid/final_pages_batch_03/batch_03_repair_manifest.json
?? worksheets/deltoid/page_preview/
?? worksheets/deltoid/templates/
