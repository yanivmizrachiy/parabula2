# העלאת קבצי מקור לריפו

עודכן: 2026-06-10

קבצים שהתקבלו בשיחה ונרשמו:

- `סליחה על השאלה.mp4`
- `למי אני שייך.pptx`

## יעד בריפו

```text
end-year-grade9-party-2026/uploaded-files/05-slicha-al-hasheela.mp4
end-year-grade9-party-2026/uploaded-files/06-lemi-ani-shayach.pptx
```

## בדיקת תקינות

ערכי SHA-256 צפויים:

```text
05-slicha-al-hasheela.mp4
EB1939C7CB7E3F284DAB1E5E016E4FB3C4BAD3BCE14BDA3504409329DCB1F1BB

06-lemi-ani-shayach.pptx
DC98BB61801DB4D1ED338A0B0C777326BF413C2C55C18A1A30B8AA6D4C0339FB
```

## PowerShell – העלאה מהמחשב

להריץ מתוך תיקיית העבודה המקומית של הריפו:

```powershell
git lfs install
git pull origin main
New-Item -ItemType Directory -Force "end-year-grade9-party-2026/uploaded-files" | Out-Null
Copy-Item "C:\PATH\TO\סליחה על השאלה.mp4" "end-year-grade9-party-2026/uploaded-files/05-slicha-al-hasheela.mp4" -Force
Copy-Item "C:\PATH\TO\למי אני שייך.pptx" "end-year-grade9-party-2026/uploaded-files/06-lemi-ani-shayach.pptx" -Force
Get-FileHash "end-year-grade9-party-2026/uploaded-files/05-slicha-al-hasheela.mp4" -Algorithm SHA256
Get-FileHash "end-year-grade9-party-2026/uploaded-files/06-lemi-ani-shayach.pptx" -Algorithm SHA256
git add .gitattributes end-year-grade9-party-2026/uploaded-files/
git commit -m "Add source media for grade 9 end-year presentation"
git push origin main
```

## Termux / Linux – העלאה מהטלפון

```bash
git lfs install
git pull origin main
mkdir -p end-year-grade9-party-2026/uploaded-files
cp "/sdcard/Download/סליחה על השאלה.mp4" "end-year-grade9-party-2026/uploaded-files/05-slicha-al-hasheela.mp4"
cp "/sdcard/Download/למי אני שייך.pptx" "end-year-grade9-party-2026/uploaded-files/06-lemi-ani-shayach.pptx"
sha256sum "end-year-grade9-party-2026/uploaded-files/05-slicha-al-hasheela.mp4"
sha256sum "end-year-grade9-party-2026/uploaded-files/06-lemi-ani-shayach.pptx"
git add .gitattributes end-year-grade9-party-2026/uploaded-files/
git commit -m "Add source media for grade 9 end-year presentation"
git push origin main
```

## הערה חשובה

הריפו ציבורי. אם הקבצים כוללים שמות, תמונות, קולות או מידע אישי של תלמידים — עדיף להפוך את הריפו לפרטי או לפרסם רק גרסת מצגת מאושרת.
