# Deltoid theme overrides build

- time: 2026-03-15T17:03:25+02:00

## theme summary
{
  "direction": "rtl",
  "font": "Arial",
  "primary_color": "#1d4ed8"
}

## generated css
:root{
  --bg:#f4f7fb;
  --card:#ffffff;
  --text:#0f172a;
  --muted:#475569;
  --line:#dbe4ee;
  --blue:#1d4ed8;
  --blue-dark:#173b8f;
  --accent:#4f8df7;
  --radius:22px;
  --shadow:0 12px 30px rgba(15,23,42,.08);
  --font-main:Arial, sans-serif;
  --title-size:34px;
  --section-size:24px;
  --body-size:16px;
  --line-height:1.75;
}
body{
  direction:rtl;
  margin:0;
  font-family:var(--font-main);
  background:linear-gradient(180deg,#eef4fb 0%,var(--bg) 100%);
  color:var(--text);
  font-size:var(--body-size);
  line-height:var(--line-height);
}
.shell{
  max-width:1280px;
  margin:0 auto;
  padding:24px 16px 48px;
}
.hero{
  background:linear-gradient(135deg,var(--blue-dark) 0%,var(--blue) 55%,var(--accent) 100%);
  color:#fff;
  border-radius:28px;
  padding:28px 22px;
  box-shadow:var(--shadow);
}
.hero h1{margin:0 0 10px 0;font-size:var(--title-size)}
.hero p{margin:0;opacity:.96}
.toolbar{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(220px,1fr));
  gap:14px;
  margin-top:20px;
}
.tool{
  background:rgba(255,255,255,.14);
  border:1px solid rgba(255,255,255,.18);
  border-radius:18px;
  padding:14px;
}
.tool .label{font-size:13px;opacity:.9}
.tool .value{font-size:18px;font-weight:700;margin-top:6px}
.section-title{margin:28px 0 16px;font-size:var(--section-size)}
.grid{
  display:grid;
  grid-template-columns:repeat(auto-fit,minmax(300px,1fr));
  gap:18px;
}
.card{
  background:var(--card);
  border:1px solid var(--line);
  border-radius:var(--radius);
  padding:18px;
  box-shadow:var(--shadow);
}
.card h2{margin:0 0 10px 0;font-size:20px}
.card p{margin:0 0 14px 0;color:var(--muted)}
.actions{display:flex;flex-wrap:wrap;gap:10px}
.btn{
  display:inline-flex;
  align-items:center;
  justify-content:center;
  min-height:42px;
  padding:0 14px;
  border-radius:14px;
  text-decoration:none;
  font-weight:700;
  border:1px solid transparent;
}
.btn-primary{background:var(--blue);color:#fff}
.btn-secondary{background:#fff;color:var(--blue);border-color:#bfdbfe}
.config, .frame-wrap{
  margin-top:26px;
  background:#fff;
  border:1px solid var(--line);
  border-radius:26px;
  box-shadow:var(--shadow);
  padding:18px;
}
pre{
  margin:0;
  white-space:pre-wrap;
  word-break:break-word;
  font-size:13px;
  line-height:1.7;
  color:#0f172a;
}
.note{margin-top:18px;color:var(--muted);font-size:14px}
iframe{
  width:100%;
  height:78vh;
  border:0;
  display:block;
  border-radius:18px;
  background:#fff;
}
@media (max-width:700px){
  .hero h1{font-size:28px}
  iframe{height:68vh}
}

## tests

> test
> node --test

[32m✔ book inventory json exists [90m(4.00177ms)[39m[39m
[32m✔ book status markdown exists [90m(0.567187ms)[39m[39m
[32m✔ all 60 page text files exist [90m(1.175625ms)[39m[39m
[32m✔ inventory page count is 60 [90m(0.652292ms)[39m[39m
[32m✔ chapter manifest exists [90m(6.251302ms)[39m[39m
[32m✔ chapter index exists [90m(0.584062ms)[39m[39m
[32m✔ chapter book exists [90m(0.699219ms)[39m[39m
[32m✔ chapter contains 5 wrapped pages [90m(1.390937ms)[39m[39m
[32m✔ chapter manifest page count is 5 [90m(0.971511ms)[39m[39m
[32m✔ chapter 02 manifest exists [90m(1.557864ms)[39m[39m
[32m✔ chapter 02 index exists [90m(0.144687ms)[39m[39m
[32m✔ chapter 02 book exists [90m(0.154531ms)[39m[39m
[32m✔ chapter 02 contains wrapped pages [90m(0.438073ms)[39m[39m
[32m✔ chapter 02 manifest has vector-next bucket [90m(0.240312ms)[39m[39m
[32m✔ chapter 03 manifest exists [90m(1.520677ms)[39m[39m
[32m✔ chapter 03 index exists [90m(0.152448ms)[39m[39m
[32m✔ chapter 03 book exists [90m(0.133698ms)[39m[39m
[32m✔ chapter 03 contains wrapped pages [90m(0.447656ms)[39m[39m
[32m✔ chapter 03 manifest has image-first-next bucket [90m(0.272396ms)[39m[39m
[32m✔ graphics analysis file exists [90m(1.574114ms)[39m[39m
[32m✔ at least one enhanced page exists [90m(0.422969ms)[39m[39m
[32m✔ exact deltoid html pages exist [90m(1.747031ms)[39m[39m
[32m✔ exact deltoid png assets exist [90m(0.393646ms)[39m[39m
[32m✔ exact deltoid manifest exists [90m(0.169427ms)[39m[39m
[32m✔ exact deltoid png assets exist [90m(1.830833ms)[39m[39m
[32m✔ exact deltoid html pages exist [90m(0.334844ms)[39m[39m
[32m✔ exact deltoid manifest exists [90m(0.202239ms)[39m[39m
[32m✔ graphics status json exists [90m(2.818906ms)[39m[39m
[32m✔ vector qa markdown exists [90m(0.250625ms)[39m[39m
[32m✔ page 56 inspection assets exist [90m(0.38573ms)[39m[39m
[32m✔ image inventory json exists [90m(2.798125ms)[39m[39m
[32m✔ image gallery exists [90m(0.341458ms)[39m[39m
[32m✔ all 60 page images exist [90m(0.753802ms)[39m[39m
[32m✔ all 60 thumbnails exist [90m(0.426146ms)[39m[39m
[32m✔ normalized rebuild plan json exists [90m(2.561093ms)[39m[39m
[32m✔ normalized rebuild plan markdown exists [90m(0.160834ms)[39m[39m
[32m✔ normalized rebuild plan html exists [90m(0.121355ms)[39m[39m
[32m✔ normalized rebuild plan contains 60 records [90m(0.401979ms)[39m[39m
[32m✔ normalized rebuild plan has done bucket [90m(0.374323ms)[39m[39m
[32m✔ page 38 vector svg exists [90m(2.684948ms)[39m[39m
[32m✔ page 38 vector html exists [90m(0.607656ms)[39m[39m
[32m✔ page 38 vector html has no inline style [90m(0.971771ms)[39m[39m
[32m✔ page 41 inspection assets exist [90m(3.029636ms)[39m[39m
[32m✔ page 41 precise vector svg exists [90m(1.48375ms)[39m[39m
[32m✔ page 41 precise vector html exists [90m(0.151823ms)[39m[39m
[32m✔ page 41 precise vector html has no inline style [90m(0.204948ms)[39m[39m
[32m✔ page 42 enhanced asset exists [90m(1.467396ms)[39m[39m
[32m✔ page 42 html points to enhanced asset [90m(0.266042ms)[39m[39m
[32m✔ page 56 precise vector svg exists [90m(4.435729ms)[39m[39m
[32m✔ page 56 precise vector html exists [90m(0.257813ms)[39m[39m
[32m✔ page 56 precise vector html has no inline style [90m(2.179896ms)[39m[39m
[32m✔ page 9 enhanced asset exists [90m(2.695833ms)[39m[39m
[32m✔ page 9 html points to enhanced asset [90m(0.485416ms)[39m[39m
[32m✔ deltoid generated pages exist [90m(1.681354ms)[39m[39m
[32m✔ deltoid manifest exists [90m(0.195469ms)[39m[39m
[32m✔ precision lab json exists [90m(5.87276ms)[39m[39m
[32m✔ precision gallery exists [90m(0.306146ms)[39m[39m
[32m✔ precision lab source pages exist [90m(0.967344ms)[39m[39m
[32m✔ precision lab line maps exist [90m(0.338021ms)[39m[39m
[32m✔ graphics status json exists [90m(1.524115ms)[39m[39m
[32m✔ vector qa markdown exists [90m(0.152708ms)[39m[39m
[32m✔ page 56 inspection assets exist [90m(0.177968ms)[39m[39m
[32m✔ exact page count is 60 [90m(0.418646ms)[39m[39m
[32m✔ all vector html files have no inline style [90m(1.498438ms)[39m[39m
[32m✔ theme json exists [90m(2.275989ms)[39m[39m
[32m✔ generated theme css exists [90m(0.643802ms)[39m[39m
[32m✔ editable index links generated theme [90m(0.892292ms)[39m[39m
[32m✔ editable book links generated theme [90m(0.295ms)[39m[39m
[32m✔ unified book shell json exists [90m(3.837969ms)[39m[39m
[32m✔ unified book index exists [90m(0.271562ms)[39m[39m
[32m✔ unified book page exists [90m(0.285729ms)[39m[39m
[32m✔ unified book theme exists [90m(0.276615ms)[39m[39m
[32m✔ unified book has 3 chapters [90m(0.420468ms)[39m[39m
[32m✔ visual page map json exists [90m(1.473854ms)[39m[39m
[32m✔ visual page map markdown exists [90m(0.162865ms)[39m[39m
[32m✔ visual map html exists [90m(0.131458ms)[39m[39m
[32m✔ visual page map contains 60 records [90m(0.364791ms)[39m[39m
page 42 vector files exist ✓
[32m✔ tests/page42-vector.test.mjs [90m(168.708125ms)[39m[39m
[32m✔ at least 10 worksheet pages exist [90m(1.793125ms)[39m[39m
[32m✔ rules files exist [90m(1.377605ms)[39m[39m
[34mℹ tests 80[39m
[34mℹ suites 0[39m
[34mℹ pass 80[39m
[34mℹ fail 0[39m
[34mℹ cancelled 0[39m
[34mℹ skipped 0[39m
[34mℹ todo 0[39m
[34mℹ duration_ms 1044.103906[39m

## git status
 M deltoid_theme_overrides_test_output.txt
?? DELTOID_THEME_OVERRIDES_20260315_170323.md
?? analysis/
?? tools/connect_editable_theme_overrides.sh
