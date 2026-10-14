import { fileURLToPath } from 'node:url';
import { PGlite } from '@electric-sql/pglite';
import { createServer } from 'pglite-server';
import { spawn } from 'node:child_process';
const root=fileURLToPath(new URL('../../services/api', import.meta.url));
const db=new PGlite(); await db.waitReady;
const server=createServer(db); await new Promise(r=>server.listen(55432,'127.0.0.1',r));
const test=new PGlite(); await test.waitReady;
const ts=createServer(test); await new Promise(r=>ts.listen(55433,'127.0.0.1',r));
async function php(args,env={}) { return await new Promise(r=>{const p=spawn(process.env.PHP_BIN || 'php',args,{cwd:root,env:{...process.env,DB_HOST:"127.0.0.1",DB_PORT:"55432",DB_DATABASE:"luxurious",APP_ENV:"local",...env},stdio:'inherit'});p.on('exit',r);}); }
let result=await php(['artisan','migrate','--seed','--force']);
if(result===0) result=await php(['vendor/bin/phpunit'],{DB_PORT:'55433',DB_DATABASE:'luxurious_test',APP_ENV:'testing'});
process.exit(result);
