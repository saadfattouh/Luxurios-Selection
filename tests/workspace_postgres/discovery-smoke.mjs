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

const output=root+'/docs/evidence/phase-02'; mkdirSync(output,{recursive:true});
const report=[];
try {
 for(const [path,expected,file] of [
  ['health',200],['ready',200],['home/curation',200],
  ['collections/landscape',200,'collection.json'],
  ['exhibitions/beyond-the-horizon/artworks?per_page=2',200,'stream.json'],
  ['artworks/where-silence-rises',200,'artwork.json'],
  ['photographers/layla-noor',200,'photographer.json'],
  ['collections/landscape/artworks?orientation=diagonal',422],['artworks/missing',404]
 ]) {
  const response=await fetch('http://127.0.0.1:8000/api/v1/'+path);const body=await response.json();
  if(response.status!==expected) throw Error(`${path}: expected ${expected}, got ${response.status}`);
  report.push({path,status:response.status});
  if(file)writeFileSync(output+'/'+file,JSON.stringify(body,null,2));
  if(file==='stream.json') {
   const next=await fetch('http://127.0.0.1:8000/api/v1/exhibitions/beyond-the-horizon/artworks?per_page=2&cursor='+encodeURIComponent(body.meta.next_cursor));
   const page=await next.json();if(!next.ok || page.data.some(a=>body.data.some(b=>a.id===b.id)))throw Error('Paging overlap');
   report.push({path:'next cursor',status:next.status,distinct:true});
  }
  if(file==='artwork.json') {
   const cached=await fetch('http://127.0.0.1:8000/api/v1/'+path,{headers:{'If-None-Match':response.headers.get('etag')}});
   if(cached.status!==304)throw Error('ETag revalidation failed'); report.push({path:'conditional detail',status:cached.status});
   for(const [kind,variant] of Object.entries(body.data.media[0].renditions)) {
    const image=await fetch(variant.url,{headers:{Origin:'http://localhost:8080'}});
    if(!image.ok || image.headers.get('access-control-allow-origin')!=='http://localhost:8080')throw Error('Rendition/CORS failed');
    report.push({path:kind,status:image.status,bytes:(await image.arrayBuffer()).byteLength,width:variant.width,height:variant.height});
   }
  }
 }
 writeFileSync(output+'/http-smoke.json',JSON.stringify(report,null,2));console.log(report);
} finally { api.kill(); await new Promise(r=>api.once('exit',r)); server.close(); await db.close(); }
process.exit(0);
