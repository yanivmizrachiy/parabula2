param()
$ErrorActionPreference='Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$site = Join-Path $repoRoot 'site'

if(Test-Path $site){ Remove-Item $site -Recurse -Force }
New-Item -ItemType Directory -Path $site | Out-Null

Copy-Item (Join-Path $repoRoot 'styles') $site -Recurse -Force
Copy-Item (Join-Path $repoRoot 'assets') $site -Recurse -Force

Get-ChildItem $repoRoot -Filter 'עמוד-*.html' -File | ForEach-Object {
  Copy-Item $_.FullName $site -Force
}

$worksheetPages = Get-ChildItem (Join-Path $repoRoot 'worksheets') -Recurse -File -Filter 'page-*.html' -ErrorAction SilentlyContinue
foreach($page in $worksheetPages){
  $relative = $page.FullName.Substring($repoRoot.Length).TrimStart('\').Replace('\','/')
  $target = Join-Path $site $relative.Replace('/','\')
  $targetDir = Split-Path $target -Parent
  if(!(Test-Path $targetDir)){ New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
  Copy-Item $page.FullName $target -Force
}

$rootPages = Get-ChildItem $site -Filter 'עמוד-*.html' -File | Sort-Object Name
$topicPages = Get-ChildItem (Join-Path $site 'worksheets') -Recurse -File -Filter 'page-*.html' -ErrorAction SilentlyContinue | Sort-Object FullName

$rootLinks = ($rootPages | ForEach-Object { "<li><a href='$($_.Name)'>$($_.Name)</a></li>" }) -join "`n"
$topicLinks = ($topicPages | ForEach-Object {
  $rel = $_.FullName.Substring($site.Length).TrimStart('\').Replace('\','/')
  "<li><a href='$rel'>$rel</a></li>"
}) -join "`n"

@"
<!DOCTYPE html>
<html lang='he' dir='rtl'>
<head>
<meta charset='utf-8'>
<meta name='viewport' content='width=device-width, initial-scale=1.0'>
<title>parabula2</title>
<link rel='stylesheet' href='styles/worksheet.css'>
</head>
<body>
<main class='a4-page'>
<header class='worksheet-header'>
<h1 class='page-title'>parabula2</h1>
<div class='page-number'>1</div>
</header>
<section class='questions'>
<div class='question'><span class='q-bullet'></span><div>דפי שורש</div></div>
<ul>
$rootLinks
</ul>
<div class='question'><span class='q-bullet'></span><div>דפי דלתון שנוצרו אוטומטית</div></div>
<ul>
$topicLinks
</ul>
</section>
</main>
</body>
</html>
"@ | Set-Content (Join-Path $site 'index.html') -Encoding utf8

'' | Set-Content (Join-Path $site '.nojekyll') -Encoding utf8
Write-Host ("site built. root pages: " + $rootPages.Count + " | worksheet pages: " + $topicPages.Count) -ForegroundColor Green
