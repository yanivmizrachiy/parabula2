# Deltoid page 9 deep fix

- time: 2026-03-11T22:41:21+02:00
- source: sources/geometry/deltoid/source.pdf

## page 9 assets
-rw-------. 1 u0_a440 u0_a440 425K Mar 11 22:41 worksheets/deltoid/exact_assets/page-09-enhanced.png
-rw-------. 1 u0_a440 u0_a440 686K Mar 11 22:41 worksheets/deltoid/exact_assets/page-09-hires.png
-rw-------. 1 u0_a440 u0_a440 381K Mar 11 20:18 worksheets/deltoid/exact_assets/page-09.png

## tests

> test
> node --test

[32m✔ exact deltoid html pages exist [90m(3.176511ms)[39m[39m
[32m✔ exact deltoid png assets exist [90m(0.509583ms)[39m[39m
[32m✔ exact deltoid manifest exists [90m(0.314115ms)[39m[39m
[32m✔ exact deltoid png assets exist [90m(1.833282ms)[39m[39m
[32m✔ exact deltoid html pages exist [90m(3.710052ms)[39m[39m
[32m✔ exact deltoid manifest exists [90m(0.262708ms)[39m[39m
[32m✔ page 9 enhanced asset exists [90m(3.964114ms)[39m[39m
[32m✔ page 9 html points to enhanced asset [90m(0.548385ms)[39m[39m
[32m✔ deltoid generated pages exist [90m(1.773906ms)[39m[39m
[32m✔ deltoid manifest exists [90m(0.242708ms)[39m[39m
[32m✔ at least 10 worksheet pages exist [90m(1.682552ms)[39m[39m
[32m✔ rules files exist [90m(1.452864ms)[39m[39m
[34mℹ tests 12[39m
[34mℹ suites 0[39m
[34mℹ pass 12[39m
[34mℹ fail 0[39m
[34mℹ cancelled 0[39m
[34mℹ skipped 0[39m
[34mℹ todo 0[39m
[34mℹ duration_ms 342.323334[39m

## git status
 M PROJECT_RULES.md
 M RULES.md
 M styles/exact-facsimile.css
 M worksheets/deltoid/exact_pages/page-09.html
?? DELTOID_PAGE9_DEEP_FIX_20260311_224116.md
?? deltoid_page9_test_output.txt
?? tests/deltoid-page9.test.mjs
?? tools/fix_deltoid_page9_deep.sh
?? tools/run_deltoid_exact_mode.sh
?? tools/run_deltoid_preview_integration.sh
?? tools/run_exact_preview_publish_integration.sh
?? worksheets/deltoid/exact_assets/page-09-enhanced.png
?? worksheets/deltoid/exact_assets/page-09-hires.png
