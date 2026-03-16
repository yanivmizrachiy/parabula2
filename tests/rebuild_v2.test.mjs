import fs from "fs"

if(!fs.existsSync("styles/deltoid-rebuild-v2.css")) throw "css missing"

let pages=fs.readdirSync("worksheets/deltoid/rebuild_v2/pages")
if(pages.length!=60) throw "pages not 60"

console.log("TEST OK")
