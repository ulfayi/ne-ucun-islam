import test from 'node:test';import assert from 'node:assert/strict';import {readFile} from 'node:fs/promises';
test('əsas statik fayllar mövcuddur',async()=>{for(const f of ['index.html','app.js','styles.css','public/content.json','public/source-audit.json'])assert.ok((await readFile(f,'utf8')).length>20)});
