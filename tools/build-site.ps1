param()
$ErrorActionPreference='Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$site = Join-Path $repoRoot 'site'
if(Test-Path $site){ Remove-Item $site -Recurse -Force }
New-Item -ItemType Directory -Path $site | Out-Null
Copy-Item (Join-Path $repoRoot 'styles') $site -Recurse -Force
Copy-Item (Join-Path $repoRoot 'assets') $site -Recurse -Force
Get-ChildItem $repoRoot -Filter 'עמוד-*.html' -File | ForEach-Object { Copy-Item $_.FullName $site -Force }
$pages = Get-ChildItem $site -Filter 'עמוד-*.html' -File | Sort-Object Name
$links = ($pages | ForEach-Object { "<li><a href='$($_.Name)'>$($_.Name)</a></li>" }) -join "`n"
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
<div class='question'><span class='q-bullet'></span><div>רשימת דפים שנבנו ל-site/</div></div>
<ul>
$links
</ul>
</section>
</main>
</body>
</html>
"@ | Set-Content (Join-Path $site 'index.html') -Encoding utf8
'' | Set-Content (Join-Path $site '.nojekyll') -Encoding utf8
Write-Host ("site built. page count: " + $pages.Count) -ForegroundColor Green
