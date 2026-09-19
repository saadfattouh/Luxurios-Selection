import { fileURLToPath } from 'node:url';
import { PGlite } from '@electric-sql/pglite';
import { createServer } from 'pglite-server';
import { spawn } from 'node:child_process';
import { writeFileSync, mkdirSync } from 'node:fs';
const root=fileURLToPath(new URL('../../', import.meta.url)).replace(/\/$/, '');
const db=new PGlite(); await db.waitReady;
const server=createServer(db); await new Promise(r=>server.listen(55432,'127.0.0.1',r));
const p=spawn(process.env.PHP_BIN || 'php',['artisan','migrate','--seed','--force'],{cwd:root+'/services/api',env:{...process.env,DB_HOST:'127.0.0.1',DB_PORT:'55432',DB_DATABASE:'luxurious',APP_ENV:'local'},stdio:'inherit'});
const result=await new Promise(r=>p.on('exit',r));if(result!==0)process.exit(result);
const api=spawn(process.env.PHP_BIN || 'php',['-S','127.0.0.1:8000','../vendor/laravel/framework/src/Illuminate/Foundation/resources/server.php'],{cwd:root+'/services/api/public',env:{...process.env,DB_HOST:'127.0.0.1',DB_PORT:'55432',DB_DATABASE:'luxurious',APP_ENV:'local'},stdio:'inherit'});
await new Promise((resolve,reject)=>{let n=0;const timer=setInterval(async()=>{try {if((await fetch('http://127.0.0.1:8000/api/v1/health')).ok){clearInterval(timer);resolve();}}catch{}if(++n>20){clearInterval(timer);reject(new Error('Server did not start'));}},100);});
mkdirSync(root+'/docs/evidence',{recursive:true});
const report=[];
for(const path of ['health','ready','exhibitions','exhibitions/beyond-the-horizon','collections','home/curation','exhibitions?per_page=99','missing']){
 const response=await fetch('http://127.0.0.1:8000/api/v1/'+path);const body=await response.json();
 report.push({path,status:response.status,contentType:response.headers.get('content-type')});
 if(path==='home/curation'){
 writeFileSync(root+'/docs/evidence/curation.json',JSON.stringify(body,null,2));
 mkdirSync(root+'/apps/collector_app/test/fixtures',{recursive:true});
 writeFileSync(root+'/apps/collector_app/test/fixtures/curation.json',JSON.stringify(body,null,2));
 const image=await fetch(body.data.current_exhibitions[0].hero_artwork.media[0].url);if(!image.ok)throw Error('Media failed');
 report.push({path:'hero media',status:image.status,contentType:image.headers.get('content-type')});
 }
}
writeFileSync(root+'/docs/evidence/http-smoke.json',JSON.stringify(report,null,2));
console.log(report);api.kill();process.exit(0);
